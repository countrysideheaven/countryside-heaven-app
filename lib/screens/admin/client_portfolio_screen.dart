import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/app_user.dart';
import '../../models/property_models.dart';
import '../../providers/property_provider.dart';

class ClientPortfolioScreen extends StatelessWidget {
  final AppUser user;
  
  const ClientPortfolioScreen({Key? key, required this.user}) : super(key: key);

  final Color bgLight = const Color(0xFFF7F7F9);
  final Color textDark = const Color(0xFF111111);
  final Color vibrantAccent = const Color(0xFFFF5E5E);

  Future<void> _openDocument(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open document link.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PropertyProvider>(context);

    // 1. Gather Owned Fractions
    List<Map<String, dynamic>> ownedFractions = [];
    for (var prop in provider.properties) {
      for (var unit in prop.units) {
        for (var frac in unit.fractions) {
          if (frac.ownerId == user.id) {
            ownedFractions.add({'property': prop, 'unit': unit, 'fraction': frac});
          }
        }
      }
    }

    // 2. Gather User Bookings
    final userBookings = provider.bookings.where((b) => b.userId == user.id).toList();

    // 3. Gather User Documents (Note: Provider currently maps user_id to the user's name for display, so we check by name or ID)
    final userDocs = provider.documents.where((d) => d.userId == user.name || d.userId == user.id).toList();

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: textDark), onPressed: () => Navigator.pop(context)),
        title: Text('Portfolio', style: TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // USER HEADER
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: textDark, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: textDark.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))]),
              child: Row(
                children: [
                  CircleAvatar(radius: 36, backgroundColor: Colors.white.withOpacity(0.1), child: const Icon(Icons.person_rounded, size: 36, color: Colors.white)),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(user.email, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 8),
                        
                        // 👉 FIXED: Wrapped in Wrap widget to prevent RenderFlex overflow
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: vibrantAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Text('Role: ${user.role.name.toUpperCase()}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: vibrantAccent))),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text('Code: ${user.myReferralCode}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white))),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),

            // ASSETS SECTION
            Text('Owned Assets 🏠', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textDark)),
            const SizedBox(height: 16),
            if (ownedFractions.isEmpty)
              _buildEmptyState(Icons.landscape_rounded, 'No assets yet', 'This user hasn\'t purchased any fractions.')
            else
              ...ownedFractions.map((item) => _buildAssetCard(item['property'], item['unit'], item['fraction'])).toList(),
            
            const SizedBox(height: 40),

            // BOOKINGS SECTION
            Text('Upcoming Stays 📅', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textDark)),
            const SizedBox(height: 16),
            if (userBookings.isEmpty)
              _buildEmptyState(Icons.event_busy_rounded, 'No bookings', 'No upcoming stays scheduled.')
            else
              ...userBookings.map((booking) => _buildBookingCard(booking)).toList(),

            const SizedBox(height: 40),

            // DOCUMENTS SECTION
            Text('Vault Documents 📁', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textDark)),
            const SizedBox(height: 16),
            if (userDocs.isEmpty)
              _buildEmptyState(Icons.folder_off_rounded, 'Vault is empty', 'No KYC or contracts uploaded.')
            else
              ...userDocs.map((doc) => _buildDocCard(context, doc)).toList(),
              
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetCard(Property property, Unit unit, Fraction fraction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          Container(height: 60, width: 60, decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.key_rounded, color: Color(0xFF6366F1), size: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(property.name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textDark)),
                const SizedBox(height: 4),
                Text('${unit.name} • Fraction ${fraction.id}', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    bool isLiving = booking.type == 'living';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          Container(height: 60, width: 60, decoration: BoxDecoration(color: isLiving ? const Color(0xFFE0E7FF) : const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(16)), child: Icon(isLiving ? Icons.home_rounded : Icons.monetization_on_rounded, color: isLiving ? const Color(0xFF6366F1) : const Color(0xFFD97706), size: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.unitName ?? 'Unknown Unit', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textDark)),
                const SizedBox(height: 4),
                Text('${booking.startDate.day}/${booking.startDate.month} - ${booking.endDate.day}/${booking.endDate.month}', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: isLiving ? const Color(0xFF6366F1).withOpacity(0.1) : const Color(0xFFD97706).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(isLiving ? 'LIVING' : 'RENTING', style: TextStyle(color: isLiving ? const Color(0xFF6366F1) : const Color(0xFFD97706), fontWeight: FontWeight.w900, fontSize: 10))),
        ],
      ),
    );
  }

  Widget _buildDocCard(BuildContext context, UserDocument doc) {
    bool isApproved = doc.status == 'approved';
    bool isPending = doc.status == 'pending';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          Container(height: 50, width: 50, decoration: BoxDecoration(color: const Color(0xFFF7F7F9), borderRadius: BorderRadius.circular(16)), child: Icon(Icons.picture_as_pdf_rounded, color: isApproved ? Colors.green : (isPending ? Colors.orange : Colors.red), size: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.fileName, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(doc.status.toUpperCase(), style: TextStyle(color: isApproved ? Colors.green : (isPending ? Colors.orange : Colors.red), fontWeight: FontWeight.w800, fontSize: 12)),
              ],
            ),
          ),
          if (doc.fileUrl != null && doc.fileUrl!.isNotEmpty)
            IconButton(icon: const Icon(Icons.visibility_rounded, color: Colors.blue), onPressed: () => _openDocument(context, doc.fileUrl!), style: IconButton.styleFrom(backgroundColor: Colors.blue.withOpacity(0.1))),
        ],
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
        ],
      ),
    );
  }
}