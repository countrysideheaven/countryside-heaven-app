import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Robust Conditional Import
import 'dart:html' if (dart.library.io) 'package:countryside_heaven_app/screens/shared/mock_html.dart' as html;

import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../models/app_user.dart';

class MarketingAsset {
  final String id;
  final String title;
  final String url;
  final bool isVideo;
  final String category;

  MarketingAsset({required this.id, required this.title, required this.url, required this.isVideo, required this.category});
}

class MarketingHubScreen extends StatefulWidget {
  const MarketingHubScreen({Key? key}) : super(key: key);

  @override
  State<MarketingHubScreen> createState() => _MarketingHubScreenState();
}

class _MarketingHubScreenState extends State<MarketingHubScreen> {
  final Color bgLight = const Color(0xFFF7F7F9);
  final Color textDark = const Color(0xFF111111);
  final Color partnerAccent = const Color(0xFF8B5CF6);

  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<MarketingAsset> assets = [
    // Fallback data while DB loads
    MarketingAsset(id: '1', title: 'Luxury Villa Campaign', url: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=1000&auto=format&fit=crop', isVideo: false, category: 'Company Brand'),
    MarketingAsset(id: '3', title: 'High Yield Investment', url: 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?q=80&w=1000&auto=format&fit=crop', isVideo: false, category: 'Company Brand'),
  ];

  @override
  void initState() {
    super.initState();
    _fetchAssets();
  }

  Future<void> _fetchAssets() async {
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase.from('marketing_assets').select().order('created_at', ascending: false);
      
      if (mounted) {
        setState(() {
          assets = data.map((item) => MarketingAsset(
            id: item['id'].toString(),
            title: item['title'],
            url: item['url'],
            isVideo: item['is_video'],
            category: item['category'] ?? 'Company Brand',
          )).toList();
        });
      }
    } catch (e) {
      debugPrint("Marketing assets table not found or error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final user = authProvider.currentUser!;
    final isAdmin = user.role == UserRole.admin;

    // Filter Logic
    final filteredAssets = assets.where((a) {
      final matchesSearch = a.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || a.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: textDark), onPressed: () => Navigator.pop(context)),
        title: Text('Marketing Hub 📢', style: TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isAdmin ? 'Asset Manager' : 'Co-Branded Assets', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textDark)),
                      const SizedBox(height: 8),
                      Text(
                        isAdmin ? 'Upload new creatives for your partners to use.' : 'Select a creative to preview and personalize.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                if (isAdmin)
                  ElevatedButton.icon(
                    onPressed: () => _showUploadDialog(context, propertyProvider),
                    icon: const Icon(Icons.upload_rounded, size: 20),
                    label: const Text('Upload'),
                    style: ElevatedButton.styleFrom(backgroundColor: textDark, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  )
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search marketing materials...',
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _buildCategoryPill('All'),
                _buildCategoryPill('Company Brand'),
                ...propertyProvider.properties.map((p) => _buildCategoryPill(p.name)).toList(),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Asset Grid
          Expanded(
            child: filteredAssets.isEmpty 
              ? Center(child: Text('No assets found matching your criteria.', style: TextStyle(color: Colors.grey.shade600)))
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: kIsWeb ? 4 : 2, 
                    crossAxisSpacing: 16, 
                    mainAxisSpacing: 16, 
                    childAspectRatio: 0.85
                  ),
                  itemCount: filteredAssets.length,
                  itemBuilder: (context, index) {
                    final asset = filteredAssets[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MarketingAssetDetailsScreen(asset: asset, user: user)));
                      },
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(24), 
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 5))]
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            asset.isVideo 
                                ? Container(color: Colors.black87, child: const Center(child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 48)))
                                : Image.network(asset.url, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image_rounded))),
                            
                            Positioned(
                              top: 12, left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(10)),
                                child: Text(asset.isVideo ? 'VIDEO' : 'IMAGE', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)),
                              ),
                            ),

                            Positioned(
                              bottom: 0, left: 0, right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter, end: Alignment.topCenter,
                                    colors: [Colors.black.withOpacity(0.8), Colors.transparent]
                                  )
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(asset.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text(asset.category, style: TextStyle(color: partnerAccent, fontWeight: FontWeight.bold, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPill(String label) {
    bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? textDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? textDark : Colors.grey.shade300),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : textDark, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  void _showUploadDialog(BuildContext context, PropertyProvider propertyProvider) {
    final titleCtrl = TextEditingController();
    
    List<String> categories = ['Company Brand', ...propertyProvider.properties.map((p) => p.name)];
    String selectedCategory = categories.first;
    
    Uint8List? selectedFileBytes;
    String? selectedFileName;
    String? selectedFileExt;
    bool isVideo = false;
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
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Upload Marketing Asset', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textDark)),
                    const SizedBox(height: 8),
                    Text('Upload images or videos for your partners to co-brand.', style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(height: 32),

                    TextField(
                      controller: titleCtrl,
                      onChanged: (_) => setState(() => errorMessage = null),
                      decoration: InputDecoration(labelText: 'Asset Title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: InputDecoration(labelText: 'Assign to Category', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
                      value: selectedCategory,
                      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setState(() { selectedCategory = val!; errorMessage = null; }),
                    ),
                    const SizedBox(height: 16),

                    InkWell(
                      onTap: () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.media, // Accepts both Image and Video
                          withData: true, 
                        );

                        if (result != null) {
                          setState(() {
                            selectedFileBytes = result.files.first.bytes;
                            selectedFileName = result.files.first.name;
                            selectedFileExt = result.files.first.extension?.toLowerCase() ?? '';
                            
                            // Determine if it is a video based on extension
                            isVideo = ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(selectedFileExt);
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
                            Icon(selectedFileBytes != null ? (isVideo ? Icons.movie_rounded : Icons.image_rounded) : Icons.upload_file_rounded, size: 40, color: selectedFileBytes != null ? partnerAccent : Colors.grey),
                            const SizedBox(height: 12),
                            Text(selectedFileBytes != null ? selectedFileName! : 'Tap to Browse Media', style: TextStyle(fontWeight: FontWeight.bold, color: selectedFileBytes != null ? partnerAccent : textDark)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    if (errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
                        child: Text(errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: textDark, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        onPressed: isUploading ? null : () async {
                          if (titleCtrl.text.isEmpty) { setState(() => errorMessage = 'Please enter a title.'); return; }
                          if (selectedFileBytes == null) { setState(() => errorMessage = 'Please select a file to upload.'); return; }

                          setState(() => isUploading = true);

                          try {
                            // Call the new provider method
                            final url = await propertyProvider.uploadMarketingAsset(
                              titleCtrl.text, selectedFileBytes!, selectedFileExt!, isVideo, selectedCategory
                            );
                            
                            // Instantly update UI locally
                            this.setState(() {
                              assets.insert(0, MarketingAsset(id: DateTime.now().toString(), title: titleCtrl.text, url: url, isVideo: isVideo, category: selectedCategory));
                            });

                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Asset uploaded successfully! 🎉'), backgroundColor: Colors.green));
                            }
                          } catch (e) {
                            setState(() {
                              isUploading = false;
                              errorMessage = 'Upload failed. Check connection / Database config.';
                            });
                          }
                        },
                        child: isUploading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : const Text('Secure Upload', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

class MarketingAssetDetailsScreen extends StatefulWidget {
  final MarketingAsset asset;
  final AppUser user;

  const MarketingAssetDetailsScreen({Key? key, required this.asset, required this.user}) : super(key: key);

  @override
  State<MarketingAssetDetailsScreen> createState() => _MarketingAssetDetailsScreenState();
}

class _MarketingAssetDetailsScreenState extends State<MarketingAssetDetailsScreen> {
  final Color bgLight = const Color(0xFFF7F7F9);
  final Color textDark = const Color(0xFF111111);
  final Color partnerAccent = const Color(0xFF8B5CF6);

  bool _isProcessing = false;

  bool _isProfileComplete() {
    return widget.user.companyName != null && widget.user.companyName!.isNotEmpty &&
           widget.user.phoneNumber != null && widget.user.phoneNumber!.isNotEmpty;
  }

  void _showProfileIncompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade600),
            const SizedBox(width: 8),
            const Text('Profile Incomplete', style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: const Text('To personalize marketing materials, you must first add your Company Name and Contact Number in your Profile settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: textDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Go to Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _personalizeAndDownload() async {
    if (!_isProfileComplete()) {
      _showProfileIncompleteDialog();
      return;
    }

    if (widget.asset.isVideo) {
      _downloadToBrowser(widget.asset.url, '${widget.asset.title}_Raw.mp4');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final response = await http.get(Uri.parse(widget.asset.url));
      final Uint8List originalBytes = response.bodyBytes;

      final ui.Codec codec = await ui.instantiateImageCodec(originalBytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image originalImage = frameInfo.image;

      final int width = originalImage.width;
      final int bannerHeight = (width * 0.18).toInt(); 
      final int totalHeight = originalImage.height + bannerHeight;

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      canvas.drawImage(originalImage, Offset.zero, Paint());

      final Rect bannerRect = Rect.fromLTWH(0, originalImage.height.toDouble(), width.toDouble(), bannerHeight.toDouble());
      canvas.drawRect(bannerRect, Paint()..color = const Color(0xFFFFFFFF));

      final String companyName = widget.user.companyName!; 
      final String contactInfo = "Call: ${widget.user.phoneNumber!} | Email: ${widget.user.email}";

      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        children: [
          TextSpan(text: '$companyName\n', style: TextStyle(color: textDark, fontSize: bannerHeight * 0.30, fontWeight: FontWeight.w900)),
          TextSpan(text: contactInfo, style: TextStyle(color: Colors.grey.shade600, fontSize: bannerHeight * 0.20, fontWeight: FontWeight.w600)),
        ],
      );
      
      textPainter.layout(maxWidth: width.toDouble() * 0.65); 
      textPainter.paint(canvas, Offset(bannerHeight * 0.25, originalImage.height.toDouble() + (bannerHeight - textPainter.height) / 2));

      final ui.Image stampedImage = await recorder.endRecording().toImage(width, totalHeight);
      final ByteData? byteData = await stampedImage.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List finalBytes = byteData!.buffer.asUint8List();

      _downloadBytesToBrowser(finalBytes, '${widget.asset.title}_Branded.png');

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error rendering image: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _downloadToBrowser(String url, String filename) {
    if (kIsWeb) {
      final anchor = html.AnchorElement(href: url);
      anchor.download = filename;
      anchor.click();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download currently supported on Web only.')));
    }
  }

  void _downloadBytesToBrowser(Uint8List bytes, String filename) {
    if (kIsWeb) {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url);
      anchor.setAttribute("download", filename);
      anchor.click();
      html.Url.revokeObjectUrl(url);
    } else {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Personalization currently supported on Web only.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: textDark, size: 18)
          ), 
          onPressed: () => Navigator.pop(context)
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                  ),
                  child: widget.asset.isVideo
                      ? const Center(child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 80))
                      : Image.network(widget.asset.url, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image_rounded, color: Colors.white54, size: 80))),
                ),
              ),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: partnerAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text(widget.asset.isVideo ? 'VIDEO ASSET' : 'IMAGE ASSET', style: TextStyle(color: partnerAccent, fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                    const SizedBox(height: 12),
                    Text(widget.asset.title, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -1)),
                    const SizedBox(height: 8),
                    Text('Download the raw file, or instantly personalize it with your branding to share with your network.', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _downloadToBrowser(widget.asset.url, '${widget.asset.title}_Raw.${widget.asset.isVideo ? 'mp4' : 'jpg'}'),
                            icon: const Icon(Icons.download_rounded),
                            label: const Text('Raw File', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textDark,
                              side: BorderSide(color: Colors.grey.shade300, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.asset.isVideo ? null : _personalizeAndDownload,
                            icon: const Icon(Icons.brush_rounded),
                            label: const Text('Personalize', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: partnerAccent,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade300,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24), 
                  ],
                ),
              )
            ],
          ),

          if (_isProcessing)
            Container(
              color: Colors.white.withOpacity(0.9),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: partnerAccent),
                    const SizedBox(height: 24),
                    Text('Stamping your branding...', style: TextStyle(fontWeight: FontWeight.w900, color: textDark, fontSize: 18)),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}