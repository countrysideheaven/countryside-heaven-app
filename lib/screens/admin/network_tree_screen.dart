import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/app_user.dart';
import 'client_portfolio_screen.dart'; // <--- Added import

class NetworkTreeScreen extends StatelessWidget {
  const NetworkTreeScreen({Key? key}) : super(key: key);

  final Color bgLight = const Color(0xFFF7F7F9);
  final Color textDark = const Color(0xFF111111);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final rootUser = authProvider.currentUser!;

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child),
        );
      },
      child: Scaffold(
        backgroundColor: bgLight,
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Network Tree 🌳', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -1)),
              const SizedBox(height: 8),
              Text('Track agents, partners, and clients. Tap a card to view their Portfolio.', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
              const SizedBox(height: 32),
              
              _NetworkNode(
                user: rootUser,
                provider: authProvider,
                isRoot: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetworkNode extends StatefulWidget {
  final AppUser user;
  final AuthProvider provider;
  final bool isRoot;

  const _NetworkNode({
    Key? key,
    required this.user,
    required this.provider,
    this.isRoot = false,
  }) : super(key: key);

  @override
  State<_NetworkNode> createState() => _NetworkNodeState();
}

class _NetworkNodeState extends State<_NetworkNode> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isRoot; 
  }

  @override
  Widget build(BuildContext context) {
    final downlines = widget.provider.getDownline(widget.user.myReferralCode);
    final hasTeam = downlines.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Tapping the whole card navigates to the Portfolio Screen
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ClientPortfolioScreen(user: widget.user)),
            );
          }, 
          child: _buildUserCard(widget.user, downlines.length, isRoot: widget.isRoot, hasTeam: hasTeam),
        ),
        
        // 2. The Animated Branch
        AnimatedSize(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: (!hasTeam || !_isExpanded)
              ? const SizedBox(width: double.infinity) 
              : IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 28),
                        width: 3,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: downlines.map((childUser) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: _NetworkNode(
                                user: childUser,
                                provider: widget.provider,
                                isRoot: false,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildUserCard(AppUser user, int downlineCount, {bool isRoot = false, required bool hasTeam}) {
    final vibrantAccent = const Color(0xFFFF5E5E);
    final textDark = const Color(0xFF111111);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isRoot ? textDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isRoot) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8)),
          if (isRoot) BoxShadow(color: textDark.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: isRoot ? Colors.white.withOpacity(0.1) : const Color(0xFFE0E7FF),
            child: Icon(_getRoleIcon(user.role), color: isRoot ? Colors.white : const Color(0xFF6366F1)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(user.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isRoot ? Colors.white : textDark)),
                    _buildRoleTag(user.role),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Code: ${user.myReferralCode}', style: TextStyle(fontSize: 13, color: isRoot ? Colors.white70 : Colors.grey.shade600, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          // Interactive Downline Pill - Tapping this expands/collapses the tree
          if (hasTeam)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.only(left: 16, right: 12, top: 12, bottom: 12),
                decoration: BoxDecoration(
                  color: isRoot ? vibrantAccent.withOpacity(0.2) : const Color(0xFFDCFCE7), 
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text('$downlineCount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: isRoot ? vibrantAccent : const Color(0xFF22C55E), height: 1)),
                        Text('Team', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isRoot ? vibrantAccent : const Color(0xFF22C55E))),
                      ],
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0, 
                      duration: const Duration(milliseconds: 300),
                      child: Icon(Icons.keyboard_arrow_down_rounded, color: isRoot ? vibrantAccent : const Color(0xFF22C55E)),
                    )
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildRoleTag(UserRole role) {
    String label = '';
    Color color = Colors.grey;
    final vibrantAccent = const Color(0xFFFF5E5E);
    
    switch (role) {
      case UserRole.admin: label = 'Admin'; color = vibrantAccent; break;
      case UserRole.channelPartner: label = 'Partner'; color = const Color(0xFF6366F1); break;
      case UserRole.salesAgent: label = 'Sales'; color = const Color(0xFFCA8A04); break;
      case UserRole.customer: label = 'Client'; color = const Color(0xFF22C55E); break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color)),
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin: return Icons.security_rounded;
      case UserRole.channelPartner: return Icons.handshake_rounded;
      case UserRole.salesAgent: return Icons.headset_mic_rounded;
      case UserRole.customer: return Icons.person_rounded;
    }
  }
}