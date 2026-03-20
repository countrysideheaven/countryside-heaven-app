import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../models/app_user.dart';

class AdminPayoutsScreen extends StatelessWidget {
  const AdminPayoutsScreen({Key? key}) : super(key: key);

  final Color bgLight = const Color(0xFFF7F7F9);
  final Color textDark = const Color(0xFF111111);
  final Color payoutColor = const Color(0xFFCA8A04); // Yellow/Gold for money

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final propertyProvider = Provider.of<PropertyProvider>(context);

    // 1. Get all agents/partners (anyone who isn't just a basic customer)
    final agents = authProvider.getDownline('ADMIN123').where((u) => u.role != UserRole.customer).toList();

    // 2. Calculate commissions
    // For this example, let's assume a flat 5% commission on the fraction price for the direct referring agent.
    const double commissionRate = 0.10; 
    
    List<Map<String, dynamic>> payoutReports = [];
    double totalOwed = 0.0;

    for (var agent in agents) {
      double agentCommission = 0.0;
      int fractionsSold = 0;

      // Find all clients referred by this agent
      final clients = authProvider.getDownline(agent.myReferralCode);
      final clientIds = clients.map((c) => c.id).toList();

      // Check all properties to see if these clients bought anything
      for (var prop in propertyProvider.properties) {
        for (var unit in prop.units) {
          for (var frac in unit.fractions) {
            if (frac.ownerId != null && clientIds.contains(frac.ownerId)) {
              fractionsSold++;
              agentCommission += (unit.fractionPrice * commissionRate);
            }
          }
        }
      }

      if (agentCommission > 0) {
        totalOwed += agentCommission;
        payoutReports.add({
          'agent': agent,
          'sales': fractionsSold,
          'commission': agentCommission,
        });
      }
    }

    // Sort by highest commission
    payoutReports.sort((a, b) => (b['commission'] as double).compareTo(a['commission'] as double));

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: textDark), onPressed: () => Navigator.pop(context)),
        title: Text('Payouts 💸', style: TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: textDark,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: textDark.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Outstanding', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('\$${totalOwed.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text('${payoutReports.length} Agents waiting for payout', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),

            Text('Pending Agent Commissions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textDark)),
            const SizedBox(height: 16),

            if (payoutReports.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 64, color: Colors.green.shade300),
                    const SizedBox(height: 16),
                    const Text('All Caught Up!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                    Text('No pending commissions to pay out.', style: TextStyle(color: Colors.grey.shade500)),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: payoutReports.length,
                itemBuilder: (context, index) {
                  final report = payoutReports[index];
                  final AppUser agent = report['agent'];
                  final int sales = report['sales'];
                  final double commission = report['commission'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: payoutColor.withOpacity(0.1),
                          child: Icon(Icons.payments_rounded, color: payoutColor, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(agent.name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textDark)),
                              const SizedBox(height: 4),
                              Text('$sales Fractions Sold • 5% Rate', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('\$${commission.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: payoutColor)),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () {
                                // In a real app, this would update a 'transactions' table in Supabase
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Marked \$${commission.toStringAsFixed(0)} as paid to ${agent.name}.'), backgroundColor: Colors.green),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: textDark, borderRadius: BorderRadius.circular(12)),
                                child: const Text('Mark Paid', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}