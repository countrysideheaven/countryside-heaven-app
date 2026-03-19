import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  
  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  List<AppUser> _allUsers = [];

  AuthProvider() {
    _currentUser = null;
    _fetchAllUsers(); // Load users in the background
  }

  Future<void> _fetchAllUsers() async {
    try {
      final response = await _supabase.from('users').select();
      _allUsers = response.map<AppUser>((u) => AppUser(
        id: u['id'],
        name: u['name'],
        email: u['email'],
        role: _parseRole(u['role']),
        myReferralCode: u['my_referral_code'],
        referredByCode: u['referred_by_code'],
      )).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching users: $e');
    }
  }

  Future<void> login(String email) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Brief UI pause
    
    try {
      // Fetch user from live DB
      final response = await _supabase.from('users').select().eq('email', email).maybeSingle();
      
      if (response == null) throw Exception('User not found');
      
      _currentUser = AppUser(
        id: response['id'],
        name: response['name'],
        email: response['email'],
        role: _parseRole(response['role']),
        myReferralCode: response['my_referral_code'],
        referredByCode: response['referred_by_code'],
      );
      
      // Refresh user list on login
      await _fetchAllUsers();
      notifyListeners();
    } catch (e) {
      throw Exception('Login Failed: ${e.toString()}');
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // --- NEW: Live Supabase User Registration ---
  Future<void> registerUser(String name, String email, UserRole role, {String? enteredReferralCode}) async {
    // Generate a unique code: First 3 letters of name + random numbers
    final String generatedCode = '${name.length >= 3 ? name.substring(0, 3).toUpperCase() : name.toUpperCase()}${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
    
    // Default to admin code if they leave it blank
    final String finalReferralCode = (enteredReferralCode == null || enteredReferralCode.trim().isEmpty) 
        ? 'ADMIN123' 
        : enteredReferralCode.trim();

    // Convert Enum to String for the database
    String roleStr;
    switch (role) {
      case UserRole.admin: roleStr = 'admin'; break;
      case UserRole.channelPartner: roleStr = 'partner'; break;
      case UserRole.salesAgent: roleStr = 'sales'; break;
      case UserRole.customer: roleStr = 'customer'; break;
    }

    try {
      // Insert into Supabase
      await _supabase.from('users').insert({
        'name': name.trim(),
        'email': email.trim(),
        'role': roleStr,
        'my_referral_code': generatedCode,
        'referred_by_code': finalReferralCode,
      });

      // Refresh the local list so the UI updates immediately
      await _fetchAllUsers();
      
    } catch (e) {
      throw Exception('Failed to create user. Ensure the email is unique. Error: $e');
    }
  }

  List<AppUser> getDownline(String referralCode) {
    return _allUsers.where((user) => user.referredByCode == referralCode && user.id != _currentUser?.id).toList();
  }

  UserRole _parseRole(String roleStr) {
    switch (roleStr) {
      case 'admin': return UserRole.admin;
      case 'partner': return UserRole.channelPartner;
      case 'sales': return UserRole.salesAgent;
      default: return UserRole.customer;
    }
  }
}