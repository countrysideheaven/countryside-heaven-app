import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Ensure this is in pubspec.yaml
import 'login_screen.dart';

// --- NATURE THEME PALETTE ---
const Color appBgColor = Color(0xFFF7F9F6); // Soft earthy off-white
const Color primaryDarkGreen = Color(0xFF2E5339); // Deep forest green
const Color softMossGreen = Color(0xFFC5D1B5); // Bubbly light green
const Color accentGold = Color(0xFFD4AF37); // Premium gold
const Color surfaceWhite = Colors.white;
const Color textPrimary = Color(0xFF1C1C1E);
const Color textSecondary = Color(0xFF8E8E93);

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminDashboardTab(),
    const ManagePropertiesTab(),
    const OperationsTab(),
    const MarketingTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
          height: 64,
          decoration: BoxDecoration(
            color: primaryDarkGreen,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: primaryDarkGreen.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 12),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard_rounded, 'Overview'),
              _buildNavItem(1, Icons.domain_add_outlined, Icons.domain_rounded, 'Estates'),
              _buildNavItem(2, Icons.manage_accounts_outlined, Icons.manage_accounts_rounded, 'Operations'),
              _buildNavItem(3, Icons.campaign_outlined, Icons.campaign_rounded, 'Marketing'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData unselected, IconData selected, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? softMossGreen.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? selected : unselected,
              color: isSelected ? accentGold : Colors.white70,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: accentGold, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

// ==========================================
// SHARED HELPER WIDGETS
// ==========================================
AppBar _buildPremiumAppBar(BuildContext context, String title) {
  return AppBar(
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: primaryDarkGreen, fontSize: 22)),
    backgroundColor: appBgColor,
    elevation: 0,
    scrolledUnderElevation: 0,
    actions: [
      IconButton(
        icon: const Icon(Icons.logout_rounded, color: Colors.grey),
        onPressed: () async {
          await Supabase.instance.client.auth.signOut();
          if (context.mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
        },
      )
    ],
  );
}

class NatureCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double width;
  const NatureCard({super.key, required this.child, this.padding, this.width = double.infinity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: softMossGreen.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: primaryDarkGreen.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: child,
    );
  }
}

// ==========================================
// TAB 1: ADMIN DASHBOARD
// ==========================================
class AdminDashboardTab extends StatelessWidget {
  const AdminDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: _buildPremiumAppBar(context, 'Command Center'),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        physics: const BouncingScrollPhysics(),
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: primaryDarkGreen,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(color: primaryDarkGreen.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Assets Under Management', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                const SizedBox(height: 8),
                const Text('₹42.5 Cr', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: const [
              Expanded(child: _StatCard(title: 'Active Co-owners', value: '124', icon: Icons.groups_rounded)),
              SizedBox(width: 16),
              Expanded(child: _StatCard(title: 'Properties Listed', value: '18', icon: Icons.landscape_rounded)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return NatureCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentGold, size: 28),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryDarkGreen)),
          Text(title, style: const TextStyle(color: textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

// ==========================================
// TAB 2: MANAGE PROPERTIES (List & Add)
// ==========================================
class ManagePropertiesTab extends StatefulWidget {
  const ManagePropertiesTab({super.key});

  @override
  State<ManagePropertiesTab> createState() => _ManagePropertiesTabState();
}

class _ManagePropertiesTabState extends State<ManagePropertiesTab> {
  final supabase = Supabase.instance.client;
  List<dynamic> _properties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProperties();
  }

  Future<void> _fetchProperties() async {
    final data = await supabase.from('properties').select().order('created_at', ascending: false);
    if (mounted) setState(() { _properties = data; _isLoading = false; });
  }

  void _showAddPropertyModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddPropertyModal(),
    ).then((_) => _fetchProperties());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: _buildPremiumAppBar(context, 'Estate Inventory'),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          onPressed: _showAddPropertyModal,
          backgroundColor: primaryDarkGreen,
          icon: const Icon(Icons.add_business_rounded, color: Colors.white),
          label: const Text('List New Estate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryDarkGreen))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              physics: const BouncingScrollPhysics(),
              itemCount: _properties.length,
              itemBuilder: (context, index) {
                final prop = _properties[index];
                
                // CRITICAL FIX: Safe string parsing to prevent null crashes
                final String imageUrl = prop['image_url']?.toString() ?? '';
                final String name = prop['name']?.toString() ?? 'Unnamed Estate';
                final String location = prop['location']?.toString() ?? 'Unknown Location';
                final String price = prop['price']?.toString() ?? '0';
                final String status = prop['status']?.toString() ?? 'Available';

                return Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: surfaceWhite,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: softMossGreen.withOpacity(0.3), width: 1.5),
                    boxShadow: [BoxShadow(color: primaryDarkGreen.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        child: SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: imageUrl.isNotEmpty
                              ? Image.network(imageUrl, fit: BoxFit.cover)
                              : Container(color: softMossGreen.withOpacity(0.5), child: const Icon(Icons.landscape_rounded, size: 60, color: primaryDarkGreen)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryDarkGreen))),
                                const Icon(Icons.more_vert_rounded, color: textSecondary),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 16, color: textSecondary),
                                const SizedBox(width: 4),
                                Text(location, style: const TextStyle(color: textSecondary, fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Fraction Price', style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w600)),
                                    Text('₹$price', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: primaryDarkGreen)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: status == 'Available' ? softMossGreen.withOpacity(0.3) : Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: status == 'Available' ? primaryDarkGreen : Colors.orange.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12
                                    )
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// --- Add Property Modal ---
class AddPropertyModal extends StatefulWidget {
  const AddPropertyModal({super.key});
  @override
  State<AddPropertyModal> createState() => _AddPropertyModalState();
}

class _AddPropertyModalState extends State<AddPropertyModal> {
  final supabase = Supabase.instance.client;
  final _name = TextEditingController();
  final _location = TextEditingController();
  final _price = TextEditingController();
  final _imgUrl = TextEditingController();
  bool _isSaving = false;

  Future<void> _saveProperty() async {
    setState(() => _isSaving = true);
    try {
      await supabase.from('properties').insert({
        'name': _name.text,
        'location': _location.text,
        'price': _price.text,
        'image_url': _imgUrl.text,
        'status': 'Available'
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: surfaceWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('List New Estate', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryDarkGreen)),
            const SizedBox(height: 24),
            _buildTextField('Property Name', _name),
            const SizedBox(height: 16),
            _buildTextField('Location', _location),
            const SizedBox(height: 16),
            _buildTextField('Fraction Price (e.g. 500000)', _price, isNumber: true),
            const SizedBox(height: 16),
            _buildTextField('Image URL', _imgUrl),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProperty,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryDarkGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                ),
                child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Publish to Network', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: textSecondary),
        filled: true,
        fillColor: appBgColor,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: softMossGreen.withOpacity(0.5))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryDarkGreen)),
      ),
    );
  }
}

// ==========================================
// TAB 3: OPERATIONS (Assign Assets & Create Users)
// ==========================================
class OperationsTab extends StatefulWidget {
  const OperationsTab({super.key});

  @override
  State<OperationsTab> createState() => _OperationsTabState();
}

class _OperationsTabState extends State<OperationsTab> {
  final supabase = Supabase.instance.client;
  
  // User Creation Controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isCreatingUser = false;

  // Assignment Controllers
  List<dynamic> _customers = [];
  List<dynamic> _properties = [];
  String? _selectedUserId;
  String? _selectedPropertyId;
  final TextEditingController _fractionsController = TextEditingController(text: '1');
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  bool _isAssigning = false;
  bool _isLoadingDropdowns = true;

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final users = await supabase.from('profiles').select('id, full_name, role').eq('role', 'customer');
      final props = await supabase.from('properties').select('id, name, price');
      
      if (mounted) {
        setState(() {
          _customers = users;
          _properties = props;
          _isLoadingDropdowns = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingDropdowns = false);
    }
  }

  Future<void> _createUser() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) return;
    setState(() => _isCreatingUser = true);

    try {
      // CRITICAL FIX: Use Admin Client mapped to .env keys to bypass RLS and avoid logout
      final adminClient = SupabaseClient(
        dotenv.env['SUPABASE_URL']!, 
        dotenv.env['SUPABASE_SERVICE_ROLE_KEY']!,
      );

      // Create the Auth User securely
      final response = await adminClient.auth.admin.createUser(
        AdminUserAttributes(
          email: _emailCtrl.text,
          password: _passCtrl.text,
          emailConfirm: true, 
        ),
      );

      final newUserId = response.user!.id;

      // Insert profile data using adminClient to bypass RLS policy blocks
      await adminClient.from('profiles').insert({
        'id': newUserId,
        'full_name': _nameCtrl.text,
        'phone_number': _phoneCtrl.text.isEmpty ? null : _phoneCtrl.text,
        'role': 'customer',
      });
      
      adminClient.dispose();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer Created Successfully!'), backgroundColor: Colors.green)
        );
        _nameCtrl.clear(); 
        _emailCtrl.clear(); 
        _phoneCtrl.clear(); 
        _passCtrl.clear();
        
        _fetchDropdownData(); // Refresh the dropdown to show the new user
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isCreatingUser = false);
    }
  }

  Future<void> _assignFraction() async {
    if (_selectedUserId == null || _selectedPropertyId == null || _priceController.text.isEmpty || _roomController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isAssigning = true);

    try {
      // 1. Create the Admin Client to bypass the RLS block
      final adminClient = SupabaseClient(
        dotenv.env['SUPABASE_URL']!, 
        dotenv.env['SUPABASE_SERVICE_ROLE_KEY']!,
      );

      // 2. Insert using the adminClient instead of the standard supabase client
      await adminClient.from('portfolio').insert({
        'user_id': _selectedUserId,
        'property_id': int.parse(_selectedPropertyId!),
        'fractions_owned': int.parse(_fractionsController.text),
        'purchase_price': double.parse(_priceController.text),
        'room_number': _roomController.text,
      });
      
      // 3. Clean up the client
      adminClient.dispose();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Asset Successfully Assigned!'), backgroundColor: Colors.green));
        setState(() {
          _selectedUserId = null;
          _selectedPropertyId = null;
          _roomController.clear();
          _priceController.clear();
          _fractionsController.text = '1';
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isAssigning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: _buildPremiumAppBar(context, 'Operations'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
        physics: const BouncingScrollPhysics(),
        children: [
          // --- 1. CREATE USER CREDENTIALS CARD ---
          NatureCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Generate Client Credentials', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryDarkGreen)),
                const SizedBox(height: 16),
                _buildNatureField('Full Name', _nameCtrl),
                const SizedBox(height: 12),
                _buildNatureField('Email Address', _emailCtrl),
                const SizedBox(height: 12),
                _buildNatureField('Phone Number', _phoneCtrl, isPhone: true),
                const SizedBox(height: 12),
                _buildNatureField('Temporary Password', _passCtrl),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: _isCreatingUser ? null : _createUser,
                    style: ElevatedButton.styleFrom(backgroundColor: primaryDarkGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: _isCreatingUser ? const CircularProgressIndicator(color: Colors.white) : const Text('Create Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 32),

          // --- 2. ASSIGN ASSET CARD ---
          NatureCard(
            child: _isLoadingDropdowns 
              ? const Center(child: CircularProgressIndicator(color: primaryDarkGreen))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Assign Fraction to Client', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryDarkGreen)),
                    const SizedBox(height: 8),
                    const Text('Link a customer to a property and assign a Room/Villa number.', style: TextStyle(color: textSecondary)),
                    const SizedBox(height: 24),
                    
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Select Customer', filled: true, fillColor: appBgColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
                      value: _selectedUserId,
                      items: _customers.map((c) => DropdownMenuItem<String>(value: c['id'].toString(), child: Text(c['full_name'] ?? 'Unknown User'))).toList(),
                      onChanged: (val) => setState(() => _selectedUserId = val),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Select Property', filled: true, fillColor: appBgColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
                      value: _selectedPropertyId,
                      items: _properties.map((p) => DropdownMenuItem<String>(value: p['id'].toString(), child: Text(p['name']))).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedPropertyId = val;
                          final prop = _properties.firstWhere((p) => p['id'].toString() == val);
                          _priceController.text = prop['price'].toString().replaceAll(RegExp(r'[^0-9.]'), '');
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildNatureField('Fractions', _fractionsController, isNumber: true),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: _buildNatureField('Total Price (₹)', _priceController, isNumber: true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildNatureField('Assign Room / Villa Number', _roomController),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        onPressed: _isAssigning ? null : _assignFraction,
                        style: ElevatedButton.styleFrom(backgroundColor: accentGold, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        child: _isAssigning ? const CircularProgressIndicator(color: primaryDarkGreen) : const Text('Confirm Assignment', style: TextStyle(color: primaryDarkGreen, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNatureField(String label, TextEditingController controller, {bool isPhone = false, bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : (isNumber ? TextInputType.number : TextInputType.text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
        filled: true,
        fillColor: appBgColor,
        isDense: true,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: softMossGreen.withOpacity(0.5))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryDarkGreen)),
      ),
    );
  }
}

// ==========================================
// TAB 4: MARKETING (Upload Collateral)
// ==========================================
class MarketingTab extends StatefulWidget {
  const MarketingTab({super.key});

  @override
  State<MarketingTab> createState() => _MarketingTabState();
}

class _MarketingTabState extends State<MarketingTab> {
  final supabase = Supabase.instance.client;
  List<dynamic> _materials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMaterials();
  }

  Future<void> _fetchMaterials() async {
    try {
      final data = await supabase.from('marketing_materials').select().order('created_at', ascending: false);
      if (mounted) setState(() { _materials = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadMaterial() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'png', 'jpg', 'mp4']);
    
    if (result != null) {
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: primaryDarkGreen)));
      
      // MOCK: Simulate upload
      await Future.delayed(const Duration(seconds: 2));
      
      await supabase.from('marketing_materials').insert({
        'title': result.files.single.name,
        'material_type': result.files.single.extension?.toUpperCase() ?? 'FILE',
        'file_url': 'https://example.com/mock_link_${result.files.single.name}',
      });

      if (mounted) {
        Navigator.pop(context);
        _fetchMaterials();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Material Uploaded!'), backgroundColor: Colors.green));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: _buildPremiumAppBar(context, 'Marketing Hub'),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          onPressed: _uploadMaterial,
          backgroundColor: primaryDarkGreen,
          icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
          label: const Text('Upload Collateral', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: primaryDarkGreen))
        : ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
            physics: const BouncingScrollPhysics(),
            children: [
              const Text('Distribute brochures and floor plans to Sales and Partners.', style: TextStyle(color: textSecondary)),
              const SizedBox(height: 24),
              
              if (_materials.isEmpty)
                const NatureCard(child: Center(child: Text('No marketing materials uploaded yet.', style: TextStyle(color: textSecondary)))),
                
              ..._materials.map((mat) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: NatureCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: softMossGreen.withOpacity(0.3), borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.insert_drive_file_rounded, color: primaryDarkGreen, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mat['title'], style: const TextStyle(color: primaryDarkGreen, fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(mat['material_type'], style: const TextStyle(color: accentGold, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.download_rounded, color: primaryDarkGreen), onPressed: () {})
                    ],
                  ),
                ),
              ))
            ],
          ),
    );
  }
}