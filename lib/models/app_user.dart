enum UserRole { admin, customer, salesAgent, channelPartner }

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String myReferralCode;
  final String? referredByCode;
  final DateTime createdAt;
  
  // Co-Branding Fields (Optional so they don't break existing user creation)
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
    return AppUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      // Fallback to customer if role parsing fails
      role: UserRole.values.firstWhere((e) => e.name == json['role'], orElse: () => UserRole.customer),
      myReferralCode: json['my_referral_code'],
      referredByCode: json['referred_by_code'],
      createdAt: DateTime.parse(json['created_at']),
      // New branding fields parsed safely
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
      'role': role.name,
      'my_referral_code': myReferralCode,
      'referred_by_code': referredByCode,
      'created_at': createdAt.toIso8601String(),
      'company_name': companyName,
      'phone_number': phoneNumber,
      'logo_url': logoUrl,
    };
  }
}