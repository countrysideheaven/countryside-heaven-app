import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  List<AppUser> _allUsers = [];
  List<AppUser> get allUsers => _allUsers;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await _fetchCurrentUser(session.user.id);
      await fetchAllUsers();
    }
  }

  // ==========================================
  // AUTHENTICATION & USER CREATION
  // ==========================================
  
  // ✅ This method needs email and password to work with Supabase
  Future<void> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(email: email, password: password);
      if (response.user != null) {
        await _fetchCurrentUser(response.user!.id);
        await fetchAllUsers();
      }
    } catch (e) {
      debugPrint('Login Error: $e');
      rethrow;
    }
  }

  // ✅ Matches add_user_screen.dart
  Future<void> registerUser(String name, String email, UserRole role, {String? enteredReferralCode}) async {
    try {
      final String tempPassword = 'Password123!';
      final response = await _supabase.auth.signUp(email: email, password: tempPassword);
      
      if (response.user != null) {
        final String safeName = name.length >= 3 ? name.substring(0, 3).toUpperCase() : name.toUpperCase().padRight(3, 'X');
        final myCode = '$safeName${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
        
        await _supabase.from('users').insert({
          'id': response.user!.id,
          'name': name,
          'email': email,
          'role': role.name,
          'my_referral_code': myCode,
          'referred_by_code': enteredReferralCode, 
          'created_at': DateTime.now().toIso8601String(),
        });
        
        await fetchAllUsers();
      }
    } catch (e) {
      debugPrint('Registration Error: $e');
      rethrow;
    }
  }

  // ==========================================
  // DATA FETCHING & UPDATES
  // ==========================================

  Future<void> _fetchCurrentUser(String id) async {
    try {
      final data = await _supabase.from('users').select().eq('id', id).single();
      _currentUser = AppUser.fromJson(data);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching current user: $e');
    }
  }

  Future<void> fetchAllUsers() async {
    try {
      final List<dynamic> data = await _supabase.from('users').select();
      _allUsers = data.map((json) => AppUser.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching all users: $e');
    }
  }

  List<AppUser> getDownline(String referralCode) {
    return _allUsers.where((u) => u.referredByCode == referralCode).toList();
  }

  Future<void> updateBrandingDetails(String companyName, String phone) async {
    if (_currentUser == null) return;
    try {
      await _supabase.from('users').update({
        'company_name': companyName,
        'phone_number': phone,
      }).eq('id', _currentUser!.id);

      _currentUser!.companyName = companyName;
      _currentUser!.phoneNumber = phone;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating branding: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    _currentUser = null;
    _allUsers = [];
    notifyListeners();
  }
}