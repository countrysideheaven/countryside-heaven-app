import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

import 'admin/admin_dashboard_screen.dart';
import 'admin/admin_properties_screen.dart';
import 'admin/network_tree_screen.dart';
import 'admin/admin_documents_screen.dart'; // <--- NEW
import 'admin/admin_calendar_screen.dart'; // <--- NEW

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({Key? key}) : super(key: key);

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  final Color bgLight = const Color(0xFFF7F7F9);
  final Color vibrantAccent = const Color(0xFFFF5E5E);
  final Color textDark = const Color(0xFF111111);

  // All 5 core tabs are now fully built!
  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const AdminPropertiesScreen(),
    const NetworkTreeScreen(),
    const AdminCalendarScreen(),
    const AdminDocumentsScreen(),
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {'label': 'Home', 'icon': Icons.bolt_rounded},
    {'label': 'Assets', 'icon': Icons.apartment_rounded},
    {'label': 'Network', 'icon': Icons.groups_rounded},
    {
      'label': 'Calendar',
      'icon': Icons.calendar_month_rounded,
    }, // <--- Added Calendar
    {'label': 'Vault', 'icon': Icons.folder_zip_rounded},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleLogout(BuildContext context) {
    Provider.of<AuthProvider>(context, listen: false).logout();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: bgLight,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: bgLight,
              elevation: 0,
              iconTheme: IconThemeData(color: textDark),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. The Company Logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/logo.png', // Updated to .png!
                      height: 32,
                      width: 32,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 2. The Full Company Name (Wrapped in Flexible to prevent overflow)
                  Flexible(
                    child: Text(
                      'Countryside Heaven',
                      style: const TextStyle(
                        fontSize:
                            20, // Slightly reduced font size to help it fit better
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111111),
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow
                          .ellipsis, // Adds "..." if it runs out of space
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.logout_rounded, color: textDark),
                  onPressed: () => _handleLogout(context),
                  tooltip: 'Log Out',
                ),
                const SizedBox(width: 8),
              ],
            ),
      drawer: isDesktop ? null : _buildMobileDrawer(context),
      body: Stack(
        children: [
          Row(
            children: [
              if (isDesktop) _buildDesktopSidebar(context),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return ScaleTransition(
                          scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutBack,
                            ),
                          ),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                  child: Container(
                    key: ValueKey<int>(_selectedIndex),
                    child: _screens[_selectedIndex],
                  ),
                ),
              ),
            ],
          ),
          if (!isDesktop)
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: _buildFloatingBottomNav(),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar(BuildContext context) {
    return Container(
      width: 260,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.rocket_launch_rounded, color: vibrantAccent, size: 28),
              const SizedBox(width: 8),
              Text(
                'Countryside',
                style: TextStyle(
                  color: textDark,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          ...List.generate(
            _menuItems.length,
            (index) => _buildSidebarItem(index),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: InkWell(
              onTap: () => _handleLogout(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: vibrantAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: vibrantAccent, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Log Out',
                      style: TextStyle(
                        color: vibrantAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? textDark : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                _menuItems[index]['icon'],
                color: isSelected ? Colors.white : Colors.grey.shade500,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                _menuItems[index]['label'],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: textDark,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: vibrantAccent.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_menuItems.length, (index) {
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () => _onItemTapped(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 16 : 8,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Icon(
                    _menuItems[index]['icon'],
                    color: isSelected ? Colors.white : Colors.grey.shade500,
                    size: 22,
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Text(
                      _menuItems[index]['label'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: bgLight,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 40),
                Text(
                  'Menu ⚡️',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 32),
                ...List.generate(_menuItems.length, (index) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(_menuItems[index]['icon'], color: textDark),
                    ),
                    title: Text(
                      _menuItems[index]['label'],
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: textDark,
                      ),
                    ),
                    onTap: () {
                      _onItemTapped(index);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: vibrantAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.logout_rounded, color: vibrantAccent),
              ),
              title: Text(
                'Log Out',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: vibrantAccent,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _handleLogout(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
