import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../models/app_user.dart';

import '../add_property_screen.dart'; 
import 'add_user_screen.dart';
import 'admin_documents_screen.dart';
import 'admin_payouts_screen.dart';

import '../shared/marketing_hub_screen.dart'; // Add this line

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  final Color textDark = const Color(0xFF111111);
  final Color vibrantAccent = const Color(0xFFFF5E5E);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final propertyProvider = Provider.of<PropertyProvider>(context);

    // ==========================================
    // 📊 LIVE DATA CALCULATIONS
    // ==========================================
    
    // 1. Revenue & Sales
    double totalRevenue = 0.0;
    int soldFractions = 0;
    int totalUnits = 0;

    for (var prop in propertyProvider.properties) {
      totalUnits += prop.units.length;
      for (var unit in prop.units) {
        for (var frac in unit.fractions) {
          if (frac.ownerId != null) {
            totalRevenue += unit.fractionPrice;
            soldFractions++;
          }
        }
      }
    }

    String revenueDisplay;
    if (totalRevenue >= 1000000) {
      revenueDisplay = '\₹${(totalRevenue / 1000000).toStringAsFixed(1)}M';
    } else if (totalRevenue >= 1000) {
      revenueDisplay = '\₹${(totalRevenue / 1000).toStringAsFixed(1)}K';
    } else {
      revenueDisplay = '\₹${totalRevenue.toStringAsFixed(0)}';
    }

    // 2. Network Sizes
    final directUsers = authProvider.getDownline('ADMIN123');
    int agentCount = directUsers.where((u) => u.role != UserRole.customer).length;
    
    int clientCount = directUsers.where((u) => u.role == UserRole.customer).length;
    for (var agent in directUsers.where((u) => u.role != UserRole.customer)) {
      // Add clients sitting under the agents
      clientCount += authProvider.getDownline(agent.myReferralCode).where((u) => u.role == UserRole.customer).length;
    }

    // 3. Dynamic Chart Data (Scales up visually as you sell more)
    final double baseVal = soldFractions > 0 ? soldFractions.toDouble() : 1.0;
    final List<FlSpot> dynamicSpots = [
      FlSpot(0, baseVal * 0.2), 
      FlSpot(1, baseVal * 0.5), 
      FlSpot(2, baseVal * 0.4),
      FlSpot(3, baseVal * 0.8), 
      FlSpot(4, baseVal * 0.7), 
      FlSpot(5, baseVal * 1.2),
    ];

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack, 
      builder: (context, double value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.95 + (0.05 * value),
            child: child,
          ),
        );
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 100), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Happening Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hey Admin 👋', style: TextStyle(fontSize: 20, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                    Text('Dashboard ⚡️', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -1)),
                  ],
                ),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: vibrantAccent.withOpacity(0.2),
                  child: Text('A', style: TextStyle(color: vibrantAccent, fontSize: 24, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Quick Actions
            Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _buildQuickAction(context, 'Add Asset', Icons.add_business_rounded, const Color(0xFFFFE0E0), const Color(0xFFFF5E5E)),
                  const SizedBox(width: 16),
                  _buildQuickAction(context, 'New User', Icons.person_add_alt_1_rounded, const Color(0xFFE0E7FF), const Color(0xFF6366F1)),
                  const SizedBox(width: 16),
                  _buildQuickAction(context, 'Upload Doc', Icons.cloud_upload_rounded, const Color(0xFFDCFCE7), const Color(0xFF22C55E)),
                  const SizedBox(width: 16),
                  _buildQuickAction(context, 'Payouts', Icons.payments_rounded, const Color(0xFFFEF08A), const Color(0xFFCA8A04)),
                  // Add this right after the 'Payouts' button:
const SizedBox(width: 16),
_buildQuickAction(context, 'Marketing', Icons.campaign_rounded, const Color(0xFFF3E8FF), const Color(0xFF8B5CF6)),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Bento Box Stats
            Text('Live Metrics 🔥', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildBentoCard('Revenue', revenueDisplay, '$soldFractions sold', const Color(0xFF111111), Colors.white), 
                    _buildBentoCard('Properties', '${propertyProvider.properties.length}', '$totalUnits units total', const Color(0xFFE0E7FF), const Color(0xFF6366F1)), 
                    _buildBentoCard('Agents', '$agentCount', 'Active', const Color(0xFFFFE0E0), const Color(0xFFFF5E5E)), 
                    _buildBentoCard('Clients', '$clientCount', 'Network wide', const Color(0xFFFEF08A), const Color(0xFFCA8A04)), 
                  ],
                );
              },
            ),
            const SizedBox(height: 40),

            // Live Chart
            Container(
              height: 300,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 10))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sales Velocity 🚀', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textDark)),
                  const SizedBox(height: 24),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false), 
                        titlesData: const FlTitlesData(
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), 
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: dynamicSpots, // Uses live scaling data
                            isCurved: true,
                            curveSmoothness: 0.4,
                            color: vibrantAccent,
                            barWidth: 6, 
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [vibrantAccent.withOpacity(0.4), vibrantAccent.withOpacity(0.0)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Quick Action Routing Logic
  Widget _buildQuickAction(BuildContext context, String title, IconData icon, Color bgColor, Color iconColor) {
    return GestureDetector(
      onTap: () {
        if (title == 'Add Asset') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPropertyScreen()));
        } else if (title == 'New User') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddUserScreen()));
        } else if (title == 'Upload Doc') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDocumentsScreen()));
        } else if (title == 'Payouts') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPayoutsScreen()));
        } 
        else if (title == 'Marketing') { // <--- ADD THIS BLOCK
  Navigator.push(context, MaterialPageRoute(builder: (context) => const MarketingHubScreen()));
}
      },
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: iconColor, size: 32),
          ),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: textDark, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildBentoCard(String title, String value, String subtitle, Color bgColor, Color textColor) {
    bool isDark = bgColor == const Color(0xFF111111);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          if (!isDark) BoxShadow(color: bgColor.withOpacity(0.5), blurRadius: 16, offset: const Offset(0, 8)),
          if (isDark) BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: isDark ? Colors.white70 : textColor.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.w700)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: isDark ? Colors.white : textDark, letterSpacing: -1)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(subtitle, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : textDark)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}