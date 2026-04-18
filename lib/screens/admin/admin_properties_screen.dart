import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/property_models.dart';
import '../../models/app_user.dart'; // 👉 NEW: Added to access UserRole
import '../add_property_screen.dart';

class AdminPropertiesScreen extends StatefulWidget {
  const AdminPropertiesScreen({Key? key}) : super(key: key);

  @override
  State<AdminPropertiesScreen> createState() => _AdminPropertiesScreenState();
}

class _AdminPropertiesScreenState extends State<AdminPropertiesScreen> {
  static const Color textDark = Color(0xFF111111);
  static const Color vibrantAccent = Color(0xFFFF5E5E);
  static const Color availableColor = Color(0xFFE0E7FF);
  static const Color assignedColor = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final properties = propertyProvider.properties;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Wrap the text in Expanded so it flexes to fit the screen
                const Expanded(
                  child: Text(
                    'Asset Registry 🏢',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -1),
                    maxLines: 1, // Keeps it on one line
                    overflow: TextOverflow.ellipsis, // Adds ... if the screen is super tiny
                  ),
                ),
                const SizedBox(width: 16), // Add a little breathing room
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddPropertyScreen()),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('New Asset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: textDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Full control over properties, units, and fractional co-ownership.', // 👉 UPDATED Terminology
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),

            if (properties.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.landscape_rounded,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Assets Found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    Text(
                      'Click "New Asset" to build your portfolio.',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  return TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(milliseconds: 400 + (index * 100)),
                    curve: Curves.easeOutCubic,
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, 50 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: _buildPropertyCard(properties[index], context),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyCard(Property property, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // GORGEOUS IMAGE BANNER WITH FALLBACK
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              image: DecorationImage(
                image: property.imageUrls.isNotEmpty
                    ? (property.imageUrls.first.startsWith('http')
                        ? NetworkImage(property.imageUrls.first) as ImageProvider
                        : (kIsWeb
                            ? NetworkImage(property.imageUrls.first)
                            : FileImage(File(property.imageUrls.first)) as ImageProvider))
                    // If no image is provided, show this gorgeous real estate placeholder
                    : const NetworkImage(
                        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=2075&auto=format&fit=crop',
                      ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // THE CARD CONTENT
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 8,
              ),
              childrenPadding: const EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: 24,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      property.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: textDark,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz_rounded, color: textDark),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditPropertyDialog(context, property);
                      } else if (value == 'delete') {
                        _showConfirmDeleteDialog(
                          context: context,
                          title: 'Delete Property',
                          content: 'Are you sure? This will delete all units and fractions inside ${property.name}.',
                          onConfirm: () => Provider.of<PropertyProvider>(
                            context,
                            listen: false,
                          ).deleteProperty(property.id),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('Edit Details'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_forever_rounded,
                              size: 18,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Delete Property',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              subtitle: Text(
                '${property.location} • ${property.units.length} Units',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: [
                if (property.description.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About this Asset',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: textDark,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          property.description,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                ...property.units
                    .map((unit) => _buildUnitSection(property, unit, context))
                    .toList(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddUnitDialog(context, property.id),
                    icon: const Icon(Icons.add_home_work_rounded),
                    label: const Text(
                      'Add Custom Unit',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textDark,
                      side: BorderSide(color: Colors.grey.shade300, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitSection(Property property, Unit unit, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${unit.fractionPrice.toStringAsFixed(0)} / fraction', // 👉 UPDATED: Cleaned up symbol
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditUnitDialog(context, property.id, unit);
                  } else if (value == 'delete') {
                    _showConfirmDeleteDialog(
                      context: context,
                      title: 'Delete Unit',
                      content: 'Are you sure you want to delete ${unit.name}?',
                      onConfirm: () => Provider.of<PropertyProvider>(
                        context,
                        listen: false,
                      ).deleteUnit(property.id, unit.id),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Edit Unit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_forever_rounded,
                          size: 18,
                          color: Colors.red,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Delete Unit',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            '${unit.fractions.length} Fractions',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: unit.fractions.asMap().entries.map((entry) {
              int index = entry.key;
              Fraction fraction = entry.value;
              bool isAssigned = fraction.ownerId != null;

              return GestureDetector(
                onTap: () {
                  if (!isAssigned) {
                    _showAssignFractionDialog(
                      context,
                      property.id,
                      unit.id,
                      fraction.id,
                    );
                  } else {
                    _showManageAssignedFractionDialog(
                      context,
                      property.id,
                      unit.id,
                      fraction,
                    );
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: isAssigned ? assignedColor : availableColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      if (!isAssigned)
                        BoxShadow(
                          color: availableColor.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Center(
                    child: isAssigned
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 20,
                          )
                        : Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Color(0xFF6366F1),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- DIALOGS ---

  void _showEditPropertyDialog(BuildContext context, Property property) {
    final nameCtrl = TextEditingController(text: property.name);
    final locCtrl = TextEditingController(text: property.location);
    final descCtrl = TextEditingController(text: property.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Property Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: locCtrl,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<PropertyProvider>(
                context,
                listen: false,
              ).updateProperty(property.id, nameCtrl.text, locCtrl.text);
              property.description = descCtrl.text;
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: textDark,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddUnitDialog(BuildContext context, String propId) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Custom Unit',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: textDark,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Unit Name (e.g. Penthouse A)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.meeting_room_rounded),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Fraction Price (₹)', // 👉 UPDATED
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee_rounded), // 👉 UPDATED
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: textDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                    Provider.of<PropertyProvider>(
                      context,
                      listen: false,
                    ).addUnitToProperty(
                      propId,
                      nameCtrl.text,
                      double.tryParse(priceCtrl.text) ?? 0,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Add Unit & Generate 11 Fractions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showEditUnitDialog(BuildContext context, String propId, Unit unit) {
    final nameCtrl = TextEditingController(text: unit.name);
    final priceCtrl = TextEditingController(
      text: unit.fractionPrice.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Unit Name'),
            ),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Fraction Price (₹)', // 👉 UPDATED
                prefixText: '₹ ', // 👉 UPDATED
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<PropertyProvider>(
                context,
                listen: false,
              ).updateUnitDetails(
                propId,
                unit.id,
                nameCtrl.text,
                double.parse(priceCtrl.text),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: textDark,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showConfirmDeleteDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAssignFractionDialog(
    BuildContext context,
    String propId,
    String unitId,
    String fractionId,
  ) {
    // 👉 STRICT FILTER: Pull all users, explicitly block Admin/Partner/Sales, only keep genuine Customers
    final allUsers = Provider.of<AuthProvider>(context, listen: false).allUsers;
    
    final customers = allUsers.where((u) => 
      u.role == UserRole.customer && 
      u.role != UserRole.admin && 
      u.role != UserRole.channelPartner && 
      u.role != UserRole.salesAgent
    ).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assign Fraction',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (customers.isEmpty)
              const Text(
                'No customer accounts found. Ensure users are registered with the Customer role.',
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: customers.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: vibrantAccent.withOpacity(0.1),
                      child: const Icon(Icons.person, color: vibrantAccent),
                    ),
                    title: Text(
                      customers[index].name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // 👉 VISUAL CONFIRMATION: The subtitle now displays the exact role assigned in the database
                    subtitle: Text('${customers[index].email} • Role: ${customers[index].role.name.toUpperCase()}'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Provider.of<PropertyProvider>(
                          context,
                          listen: false,
                        ).assignFraction(
                          propId,
                          unitId,
                          fractionId,
                          customers[index].id,
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: textDark,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Assign'),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showManageAssignedFractionDialog(
    BuildContext context,
    String propId,
    String unitId,
    Fraction fraction,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Fraction'),
        content: const Text(
          'This fraction is already assigned to a user. Do you want to revoke their co-ownership?', // 👉 UPDATED
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<PropertyProvider>(
                context,
                listen: false,
              ).unassignFraction(propId, unitId, fraction.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Revoke Co-ownership'), // 👉 UPDATED
          ),
        ],
      ),
    );
  }
}