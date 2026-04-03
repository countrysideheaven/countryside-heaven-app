import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

// Robust Conditional Import
import 'dart:html' if (dart.library.io) 'package:countryside_heaven_app/screens/shared/mock_html.dart' as html;

import '../../providers/auth_provider.dart';
import '../../models/app_user.dart';

class MarketingAsset {
  final String id;
  final String title;
  final String url;
  final bool isVideo;

  MarketingAsset({required this.id, required this.title, required this.url, required this.isVideo});
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

  List<MarketingAsset> assets = [
    MarketingAsset(
      id: '1', 
      title: 'Luxury Villa Campaign', 
      url: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=1000&auto=format&fit=crop', 
      isVideo: false
    ),
    MarketingAsset(id: '2', title: 'Fractional Promo Video', url: 'dummy_video.mp4', isVideo: true),
    MarketingAsset(id: '3', title: 'High Yield Investment', url: 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?q=80&w=1000&auto=format&fit=crop', isVideo: false),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser!;
    final isAdmin = user.role == UserRole.admin;

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: textDark), onPressed: () => Navigator.pop(context)),
        title: Text('Marketing Hub 📢', style: TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload flow ready to be wired!')));
                    },
                    icon: const Icon(Icons.upload_rounded, size: 20),
                    label: const Text('Upload'),
                    style: ElevatedButton.styleFrom(backgroundColor: textDark, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  )
              ],
            ),
            const SizedBox(height: 32),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: kIsWeb ? 4 : 2, 
                crossAxisSpacing: 16, 
                mainAxisSpacing: 16, 
                childAspectRatio: 0.85
              ),
              itemCount: assets.length,
              itemBuilder: (context, index) {
                final asset = assets[index];
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
                            : Image.network(asset.url, fit: BoxFit.cover),
                        
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
                            child: Text(asset.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ),
                        )
                      ],
                    ),
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
                      : Image.network(widget.asset.url, fit: BoxFit.contain),
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