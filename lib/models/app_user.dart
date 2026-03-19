enum UserRole { admin, salesAgent, channelPartner, customer }

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String myReferralCode;
  final String? referredByCode; // The code they used to sign up
  final String? assignedToId; // If customer is assigned to a specific partner/agent

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.myReferralCode,
    this.referredByCode,
    this.assignedToId,
  });

  // Automatically defaults to admin code if none provided
  factory AppUser.createNew({
    required String id,
    required String name,
    required String email,
    required UserRole role,
    String? enteredReferralCode,
  }) {
    return AppUser(
      id: id,
      name: name,
      email: email,
      role: role,
      myReferralCode: '${name.substring(0, 3).toUpperCase()}${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
      referredByCode: enteredReferralCode?.isEmpty ?? true ? 'ADMIN_DEFAULT' : enteredReferralCode,
    );
  }
}