enum UserRole { admin, customer, salesAgent, channelPartner }

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String myReferralCode;
  final String? referredByCode;
  final DateTime createdAt;
  
  // Co-Branding Fields
  String? companyName;
  String? phoneNumber;
  String? logoUrl;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.myReferralCode,
    this.referredByCode,
    required this.createdAt,
    this.companyName,
    this.phoneNumber,
    this.logoUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    // 👉 THE FIX: Bulletproof, case-insensitive role parsing
    UserRole parsedRole = UserRole.customer;
    final String dbRole = (json['role'] ?? '').toString().toLowerCase();

    // Accurately maps any database string variation to the correct Flutter enum
    if (dbRole.contains('admin')) {
      parsedRole = UserRole.admin;
    } else if (dbRole.contains('sales')) {
      parsedRole = UserRole.salesAgent;
    } else if (dbRole.contains('partner')) {
      parsedRole = UserRole.channelPartner;
    } else {
      parsedRole = UserRole.customer;
    }

    return AppUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: parsedRole,
      myReferralCode: json['my_referral_code'],
      referredByCode: json['referred_by_code'],
      createdAt: DateTime.parse(json['created_at']),
      companyName: json['company_name'],
      phoneNumber: json['phone_number'],
      logoUrl: json['logo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name, // Will securely save back as 'salesAgent', 'customer', etc.
      'my_referral_code': myReferralCode,
      'referred_by_code': referredByCode,
      'created_at': createdAt.toIso8601String(),
      'company_name': companyName,
      'phone_number': phoneNumber,
      'logo_url': logoUrl,
    };
  }
}