import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <--- Handles .env variables
import 'package:minio/minio.dart'; // <--- Connects to Cloudflare R2
import '../models/property_models.dart';

class PropertyProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<Property> _properties = [];
  List<Property> get properties => _properties;

  List<UserDocument> _documents = [];
  List<UserDocument> get documents => _documents;
  
  List<Booking> _bookings = [];
  List<Booking> get bookings => _bookings;

  PropertyProvider() {
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      await Future.wait([
        _fetchProperties(),
        _fetchDocuments(),
        _fetchBookings(),
      ]);
      notifyListeners();
    } catch (e) {
      debugPrint('🚨 Error fetching data from Supabase: $e');
    }
  }

  Future<void> _fetchProperties() async {
    final response = await _supabase.from('properties').select('*, units(*, fractions(*))');
    
    _properties = (response as List).map((propMap) {
      List<Unit> units = (propMap['units'] as List).map((unitMap) {
        List<Fraction> fractions = (unitMap['fractions'] as List).map((fracMap) {
          return Fraction(id: fracMap['id'], ownerId: fracMap['owner_id']);
        }).toList();

        fractions.sort((a, b) => (unitMap['fractions'].firstWhere((f) => f['id'] == a.id)['fraction_index'] as int)
            .compareTo(unitMap['fractions'].firstWhere((f) => f['id'] == b.id)['fraction_index'] as int));

        return Unit(
          id: unitMap['id'],
          name: unitMap['name'],
          fractionPrice: (unitMap['fraction_price'] as num).toDouble(),
          fractions: fractions,
        );
      }).toList();

      return Property(id: propMap['id'], name: propMap['name'], location: propMap['location'], units: units);
    }).toList();
  }

  Future<void> _fetchDocuments() async {
    final response = await _supabase.from('documents').select('*, users(name)');
    _documents = (response as List).map((doc) {
      return UserDocument(
        id: doc['id'],
        userId: doc['users'] != null ? doc['users']['name'] : 'Unknown User',
        fileName: doc['file_name'],
        fileUrl: doc['file_url'], // FETCH R2 URL FROM DB
        status: doc['status'],
      );
    }).toList();
  }

  Future<void> _fetchBookings() async {
    final response = await _supabase.from('bookings').select('*, units(name), fractions(fraction_index), users(name)');
    
    _bookings = (response as List).map((b) {
      return Booking(
        id: b['id'], unitId: b['unit_id'], unitName: b['units'] != null ? b['units']['name'] : 'Unknown Unit',
        fractionId: b['fraction_id'], fractionName: b['fractions'] != null ? 'Fraction ${b['fractions']['fraction_index']}' : 'Unknown',
        userId: b['user_id'] ?? 'outside', userName: b['users'] != null ? b['users']['name'] : 'Outside Guest',
        startDate: DateTime.parse(b['start_date']).toLocal(), endDate: DateTime.parse(b['end_date']).toLocal(),
        type: b['type'], isOutsideBooking: b['is_outside_booking'] ?? false, guestName: b['guest_name'],
      );
    }).toList();
  }

  // --- 🚀 CLOUDFLARE R2 UPLOAD LOGIC 🚀 ---
  Future<void> uploadAdminDocument(String userId, String documentName, Uint8List fileBytes, String extension) async {
    try {
      final uniqueFileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      
      // 1. Grab variables from .env file (Change these names to perfectly match your .env file)
      final accountId = dotenv.env['R2_ACCOUNT_ID']!; // E.g., '12345abcde...'
      final accessKey = dotenv.env['R2_ACCESS_KEY_ID']!;
      final secretKey = dotenv.env['R2_SECRET_ACCESS_KEY']!;
      final bucketName = dotenv.env['R2_BUCKET_NAME']!;
      final publicUrlBase = dotenv.env['R2_PUBLIC_DEV_URL'] ?? dotenv.env['R2_PUBLIC_URL']!; // E.g., 'https://pub-xxxx.r2.dev'

      // Minio requires the endpoint without "https://"
      final r2Endpoint = '$accountId.r2.cloudflarestorage.com'; 

      // 2. Initialize the Minio/R2 client
      final minio = Minio(
        endPoint: r2Endpoint,
        accessKey: accessKey,
        secretKey: secretKey,
        region: 'auto', // R2 requires 'auto' region
        useSSL: true,
      );

      // 3. Stream the file directly to your R2 bucket
      await minio.putObject(
        bucketName,
        uniqueFileName,
        Stream.value(fileBytes), 
        size: fileBytes.length,
      );

      // 4. Build the final public URL
      final String r2FileUrl = publicUrlBase.endsWith('/') 
          ? '$publicUrlBase$uniqueFileName' 
          : '$publicUrlBase/$uniqueFileName';

      // 5. Save the record in Supabase (Auto-approved)
      await _supabase.from('documents').insert({
        'user_id': userId,
        'file_name': documentName,
        'file_url': r2FileUrl,
        'status': 'approved', 
      });
      
      await fetchData(); // Refresh the Vault UI
    } catch (e) {
      debugPrint('🚨 Error uploading document to R2: $e');
      rethrow;
    }
  }

  // --- CRUD Operations ---
  Future<void> addProperty(String name, String location, int unitCount, double initialFractionPrice) async {
    final propResp = await _supabase.from('properties').insert({'name': name, 'location': location}).select().single();
    final String propertyId = propResp['id'];
    for (int i = 0; i < unitCount; i++) {
      final unitResp = await _supabase.from('units').insert({'property_id': propertyId, 'name': 'Unit ${i + 1}', 'fraction_price': initialFractionPrice}).select().single();
      await _supabase.from('fractions').insert(List.generate(11, (index) => {'unit_id': unitResp['id'], 'fraction_index': index + 1}));
    }
    await fetchData(); 
  }

  Future<void> addUnitToProperty(String propertyId, String customUnitName, double fractionPrice) async {
    final unitResp = await _supabase.from('units').insert({'property_id': propertyId, 'name': customUnitName, 'fraction_price': fractionPrice}).select().single();
    await _supabase.from('fractions').insert(List.generate(11, (index) => {'unit_id': unitResp['id'], 'fraction_index': index + 1}));
    await fetchData();
  }

  Future<void> updateProperty(String propertyId, String newName, String newLocation) async { await _supabase.from('properties').update({'name': newName, 'location': newLocation}).eq('id', propertyId); await fetchData(); }
  Future<void> deleteProperty(String propertyId) async { await _supabase.from('properties').delete().eq('id', propertyId); await fetchData(); }
  Future<void> updateUnitDetails(String propertyId, String unitId, String newName, double newPrice) async { await _supabase.from('units').update({'name': newName, 'fraction_price': newPrice}).eq('id', unitId); await fetchData(); }
  Future<void> deleteUnit(String propertyId, String unitId) async { await _supabase.from('units').delete().eq('id', unitId); await fetchData(); }
  Future<void> assignFraction(String propertyId, String unitId, String fractionId, String userId) async { await _supabase.from('fractions').update({'owner_id': userId}).eq('id', fractionId); await fetchData(); }
  Future<void> unassignFraction(String propertyId, String unitId, String fractionId) async { await _supabase.from('fractions').update({'owner_id': null}).eq('id', fractionId); await fetchData(); }
  Future<void> updateDocumentStatus(String docId, String newStatus) async { await _supabase.from('documents').update({'status': newStatus}).eq('id', docId); await fetchData(); }
  
  Future<void> addBooking(Booking booking) async {
    await _supabase.from('bookings').insert({
      'unit_id': booking.unitId, 'fraction_id': booking.fractionId, 
      'user_id': booking.isOutsideBooking ? null : booking.userId, 
      'start_date': booking.startDate.toIso8601String(), 'end_date': booking.endDate.toIso8601String(),
      'type': booking.type, 'is_outside_booking': booking.isOutsideBooking, 'guest_name': booking.guestName,
    });
    await fetchData();
  }

  Future<void> deleteBooking(String bookingId) async { await _supabase.from('bookings').delete().eq('id', bookingId); await fetchData(); }
}