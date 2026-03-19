import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/app_user.dart';

class SalesMainScreen extends StatefulWidget {
  const SalesMainScreen({Key? key}) : super(key: key);

  @override
  State<SalesMainScreen> createState() => _SalesMainScreenState();
}

class _SalesMainScreenState extends State<SalesMainScreen> {
  int _selectedIndex = 0;

  // Upgraded to static const to prevent any "const context" squiggles from the IDE
  static const Color bgLight = Color(0xFFF7F7F9);
  static const Color textDark = Color(0xFF111111);
  static const Color salesAccent = Color(0xFFF59E0B); // Energetic Amber/Gold
  static const Color vibrantAccent = Color(0xFFFF5E5E);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) return const SizedBox.shrink();

    // Get the clients invited directly by this Sales Agent
    final myClients = authProvider.getDownline(user.myReferralCode);

    final List<Widget> screens = [
      _buildDashboardContent(user, myClients, context),
      const Center(child: Text('🏢 Available Assets Coming Soon', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
      const Center(child: Text('👥 Client CRM Coming Soon', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
    ];

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: salesAccent.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.headset_mic_rounded, color: salesAccent, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Sales Hub', style: TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: textDark),
            onPressed: () => authProvider.logout(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey<int>(_selectedIndex),
          child: screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24, top: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, -5))],
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            backgroundColor: textDark,
            selectedItemColor: salesAccent,
            unselectedItemColor: Colors.grey.shade600,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.speed_rounded), label: 'Performance'),
              BottomNavigationBarItem(icon: Icon(Icons.apartment_rounded), label: 'Assets'),
              BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Clients'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(AppUser user, List<AppUser> myClients, BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.scale(scale: 0.95 + (0.05 * value), child: child),
        );
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text('Ready to close deals,', style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
            Text('${user.name}? 🎯', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -1)),
            const SizedBox(height: 32),

            // Share Link / Code
            _buildInviteCard(user.myReferralCode, context),
            const SizedBox(height: 32),

            // Sales Bento Box
            const Text('Your Pipeline 📈', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildBentoCard('Total Sales', '\$125K', '+15% this wk', textDark, Colors.white),
                _buildBentoCard('Commissions', '\$2,500', 'Pending payout', const Color(0xFFFEF3C7), salesAccent),
                _buildBentoCard('Active Clients', '${myClients.length}', 'In your portfolio', const Color(0xFFE0E7FF), const Color(0xFF6366F1)),
                _buildBentoCard('Close Rate', '24%', 'Top 10% agent', const Color(0xFFDCFCE7), const Color(0xFF22C55E)),
              ],
            ),
            const SizedBox(height: 40),

            // Client CRM Snapshot
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Clients 🤝', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
                TextButton(
                  onPressed: () {},
                  child: const Text('View CRM', style: TextStyle(color: salesAccent, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (myClients.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade200)),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.person_add_disabled_rounded, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('No clients yet', style: TextStyle(fontWeight: FontWeight.bold, color: textDark, fontSize: 16)),
                      Text('Share your code to onboard buyers.', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myClients.length,
                itemBuilder: (context, index) {
                  final client = myClients[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: salesAccent.withOpacity(0.1),
                          child: Text(client.name[0].toUpperCase(), style: const TextStyle(color: salesAccent, fontWeight: FontWeight.w900)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold, color: textDark, fontSize: 16)),
                              Text('Joined recently', style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(12)),
                          child: const Text('Contact', style: TextStyle(color: textDark, fontSize: 12, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteCard(String code, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [salesAccent, Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: salesAccent.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.qr_code_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Client Invite Code', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(code, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2)),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invite code copied! 📋', style: TextStyle(fontWeight: FontWeight.bold)),
                      backgroundColor: Color(0xFF111111),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, color: salesAccent),
                style: IconButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.all(12)),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBentoCard(String title, String value, String subtitle, Color bgColor, Color textColor) {
    bool isDark = bgColor == textDark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isDark) BoxShadow(color: bgColor.withOpacity(0.5), blurRadius: 16, offset: const Offset(0, 8)),
          if (isDark) BoxShadow(color: bgColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: isDark ? Colors.white70 : textColor.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w700)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: isDark ? Colors.white : textDark, letterSpacing: -1)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(subtitle, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white : textDark)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}