import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/property_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/app_user.dart';

class AdminDocumentsScreen extends StatefulWidget {
  const AdminDocumentsScreen({Key? key}) : super(key: key);

  @override
  State<AdminDocumentsScreen> createState() => _AdminDocumentsScreenState();
}

class _AdminDocumentsScreenState extends State<AdminDocumentsScreen> {
  static const Color textDark = Color(0xFF111111);
  static const Color vibrantAccent = Color(0xFFFF5E5E);

  Future<void> _openDocument(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open document link.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PropertyProvider>(context);
    final documents = provider.documents;

    // ---> NEW: Group documents by user name (stored in doc.userId in the provider)
    final Map<String, List<dynamic>> groupedDocuments = {};
    for (var doc in documents) {
      final String folderName = doc.userId;
      if (!groupedDocuments.containsKey(folderName)) {
        groupedDocuments[folderName] = [];
      }
      groupedDocuments[folderName]!.add(doc);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER WITH DYNAMIC BACK BUTTON ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (Navigator.canPop(context))
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0, top: 4.0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textDark),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Vault 📁', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -1)),
                        const SizedBox(height: 8),
                        Text('Manage KYC and contracts.', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showUploadDialog(context),
                    icon: const Icon(Icons.upload_file_rounded, size: 20),
                    label: const Text('Upload'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: textDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  )
                ],
              ),
            ),
            
            // --- DOCUMENT LIST (NOW ORGANIZED INTO FOLDERS) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: groupedDocuments.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                    child: Column(
                      children: [
                        Icon(Icons.folder_off_rounded, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text('Vault is Empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark)),
                        Text('No documents have been uploaded yet.', style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: groupedDocuments.length,
                    itemBuilder: (context, index) {
                      final userName = groupedDocuments.keys.elementAt(index);
                      final userDocs = groupedDocuments[userName]!;
                      
                      // Check if any documents in this folder are pending
                      final hasPendingDocs = userDocs.any((doc) => doc.status == 'pending');

                      // FOLDER UI
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Theme(
                          // Removes the default borders from the ExpansionTile
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: hasPendingDocs ? vibrantAccent.withOpacity(0.1) : const Color(0xFF6366F1).withOpacity(0.1), 
                                borderRadius: BorderRadius.circular(16)
                              ),
                              child: Icon(
                                hasPendingDocs ? Icons.folder_special_rounded : Icons.folder_shared_rounded, 
                                color: hasPendingDocs ? vibrantAccent : const Color(0xFF6366F1), 
                                size: 28
                              ),
                            ),
                            title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textDark)),
                            subtitle: Text('${userDocs.length} Document(s)', style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600)),
                            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            children: userDocs.map((doc) {
                              final isPending = doc.status == 'pending';
                              final isApproved = doc.status == 'approved';

                              // NESTED DOCUMENT UI
                              return Container(
                                margin: const EdgeInsets.only(top: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7F7F9), // Slight gray background for nested effect
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.picture_as_pdf_rounded, color: isApproved ? Colors.green : vibrantAccent, size: 28),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(doc.fileName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textDark)),
                                        ],
                                      ),
                                    ),
                                    
                                    if (doc.fileUrl != null && doc.fileUrl!.isNotEmpty)
                                      IconButton(
                                        onPressed: () => _openDocument(doc.fileUrl!),
                                        icon: const Icon(Icons.visibility_rounded, color: Colors.blue, size: 20),
                                        tooltip: 'View Document',
                                        style: IconButton.styleFrom(backgroundColor: Colors.blue.withOpacity(0.1)),
                                      ),
                                    const SizedBox(width: 4),

                                    if (isPending) ...[
                                      IconButton(
                                        onPressed: () => provider.updateDocumentStatus(doc.id, 'rejected'),
                                        icon: const Icon(Icons.close_rounded, color: Colors.red, size: 20),
                                        tooltip: 'Reject',
                                        style: IconButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.1)),
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        onPressed: () => provider.updateDocumentStatus(doc.id, 'approved'),
                                        icon: const Icon(Icons.check_rounded, color: Colors.green, size: 20),
                                        tooltip: 'Approve',
                                        style: IconButton.styleFrom(backgroundColor: Colors.green.withOpacity(0.1)),
                                      ),
                                    ] else ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(color: isApproved ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                        child: Text(doc.status.toUpperCase(), style: TextStyle(color: isApproved ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
                                      )
                                    ]
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
            )
          ],
        ),
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    
    final users = [authProvider.currentUser!, ...authProvider.getDownline('ADMIN123')];
    AppUser? selectedUser = users.isNotEmpty ? users.first : null;
    
    final nameCtrl = TextEditingController();
    Uint8List? selectedFileBytes;
    String? selectedFileName;
    String? selectedFileExt;
    bool isUploading = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Upload Physical Document', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textDark)),
                    const SizedBox(height: 8),
                    Text('Files uploaded by Admins are automatically approved.', style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(height: 24),
                    
                    DropdownButtonFormField<AppUser>(
                      isExpanded: true,
                      decoration: InputDecoration(labelText: 'Assign to User', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
                      value: selectedUser,
                      items: users.map((u) => DropdownMenuItem(value: u, child: Text('${u.name} (${u.role.name})'))).toList(),
                      onChanged: (u) => setState(() { selectedUser = u; errorMessage = null; }),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: nameCtrl,
                      onChanged: (_) => setState(() => errorMessage = null),
                      decoration: InputDecoration(labelText: 'Document Name (e.g. Contract)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
                    ),
                    const SizedBox(height: 16),

                    InkWell(
                      onTap: () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                          withData: true, 
                        );

                        if (result != null) {
                          setState(() {
                            selectedFileBytes = result.files.first.bytes;
                            selectedFileName = result.files.first.name;
                            selectedFileExt = result.files.first.extension;
                            errorMessage = null;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(color: const Color(0xFFF7F7F9), border: Border.all(color: Colors.grey.shade300, width: 2), borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            Icon(selectedFileBytes != null ? Icons.file_present_rounded : Icons.upload_file_rounded, size: 40, color: selectedFileBytes != null ? const Color(0xFF6366F1) : Colors.grey),
                            const SizedBox(height: 12),
                            Text(selectedFileBytes != null ? selectedFileName! : 'Tap to Browse Files', style: TextStyle(fontWeight: FontWeight.bold, color: selectedFileBytes != null ? const Color(0xFF6366F1) : textDark)),
                            if (selectedFileBytes == null) const Text('Supports PDF, JPG, PNG', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(child: Text(errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13))),
                          ],
                        ),
                      ),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: textDark, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        onPressed: isUploading ? null : () async {
                          setState(() => errorMessage = null);
                          
                          if (selectedUser == null) { setState(() => errorMessage = 'Please select a user.'); return; }
                          if (nameCtrl.text.isEmpty) { setState(() => errorMessage = 'Please enter a document name.'); return; }
                          if (selectedFileBytes == null || selectedFileExt == null) { setState(() => errorMessage = 'Please select a file to upload.'); return; }

                          setState(() => isUploading = true);

                          try {
                            await propertyProvider.uploadAdminDocument(
                              selectedUser!.id, 
                              nameCtrl.text, 
                              selectedFileBytes!, 
                              selectedFileExt!
                            );
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document successfully vaulted! 🔒'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
                            }
                          } catch (e) {
                            setState(() {
                              isUploading = false;
                              errorMessage = 'Upload failed. Please check your R2/Network connection.';
                            });
                          }
                        },
                        child: isUploading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : const Text('Secure Upload to Vault', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }
}