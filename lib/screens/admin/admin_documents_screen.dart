import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/property_provider.dart';

class AdminDocumentsScreen extends StatelessWidget {
  const AdminDocumentsScreen({Key? key}) : super(key: key);

  static const Color textDark = Color(0xFF111111);
  static const Color vibrantAccent = Color(0xFFFF5E5E);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PropertyProvider>(context);
    final documents = provider.documents;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Document Vault 📁', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -1)),
            const SizedBox(height: 8),
            Text('Review and approve user KYC and identity documents.', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
            const SizedBox(height: 32),

            if (documents.isEmpty)
              const Center(child: Text('No documents uploaded yet.'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final doc = documents[index];
                  final isPending = doc.status == 'pending';
                  final isApproved = doc.status == 'approved';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFFF7F7F9), borderRadius: BorderRadius.circular(16)),
                          child: Icon(Icons.picture_as_pdf_rounded, color: isApproved ? Colors.green : vibrantAccent, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doc.fileName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark)),
                              const SizedBox(height: 4),
                              Text('Uploaded by: ${doc.userId}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                            ],
                          ),
                        ),
                        if (isPending) ...[
                          IconButton(
                            onPressed: () => provider.updateDocumentStatus(doc.id, 'rejected'),
                            icon: const Icon(Icons.close_rounded, color: Colors.red),
                            tooltip: 'Reject',
                            style: IconButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.1)),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => provider.updateDocumentStatus(doc.id, 'approved'),
                            icon: const Icon(Icons.check_rounded, color: Colors.green),
                            tooltip: 'Approve',
                            style: IconButton.styleFrom(backgroundColor: Colors.green.withOpacity(0.1)),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isApproved ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              doc.status.toUpperCase(),
                              style: TextStyle(
                                color: isApproved ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          )
                        ]
                      ],
                    ),
                  );
                },
              )
          ],
        ),
      ),
    );
  }
}