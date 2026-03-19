import 'package:flutter/material.dart';

class AdminResponsiveLayout extends StatefulWidget {
  final Widget child;
  const AdminResponsiveLayout({Key? key, required this.child}) : super(key: key);

  @override
  State<AdminResponsiveLayout> createState() => _AdminResponsiveLayoutState();
}

class _AdminResponsiveLayoutState extends State<AdminResponsiveLayout> {
  int _selectedIndex = 0;

  final List<String> _menuItems = [
    'Dashboard',
    'Properties',
    'Network Tree',
    'Documents',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // TODO: Implement GoRouter navigation here based on index
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: isDesktop ? null : AppBar(title: Text(_menuItems[_selectedIndex])),
      drawer: isDesktop ? null : Drawer(
        child: ListView(
          children: _buildMenuItems(),
        ),
      ),
      body: Row(
        children: [
          if (isDesktop)
            Container(
              width: 250,
              color: Colors.blueGrey.shade900,
              child: ListView(
                children: [
                  const DrawerHeader(
                    child: Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 24)),
                  ),
                  ..._buildMenuItems(isDesktop: true),
                ],
              ),
            ),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.domain), label: 'Properties'),
          BottomNavigationBarItem(icon: Icon(Icons.account_tree), label: 'Network'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Docs'),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems({bool isDesktop = false}) {
    final textColor = isDesktop ? Colors.white70 : Colors.black87;
    return List.generate(_menuItems.length, (index) {
      return ListTile(
        title: Text(_menuItems[index], style: TextStyle(color: textColor)),
        selected: _selectedIndex == index,
        onTap: () {
          _onItemTapped(index);
          if (!isDesktop) Navigator.pop(context); // Close drawer on mobile
        },
      );
    });
  }
}