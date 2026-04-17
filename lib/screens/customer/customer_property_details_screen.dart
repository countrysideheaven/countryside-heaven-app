import 'package:flutter/material.dart';
import '../../models/property_models.dart';

class CustomerPropertyDetailsScreen extends StatefulWidget {
  final Property property;
  final double startingPrice;

  const CustomerPropertyDetailsScreen({
    Key? key,
    required this.property,
    required this.startingPrice,
  }) : super(key: key);

  @override
  State<CustomerPropertyDetailsScreen> createState() => _CustomerPropertyDetailsScreenState();
}

class _CustomerPropertyDetailsScreenState extends State<CustomerPropertyDetailsScreen> {
  final Color bgLight = const Color(0xFFF7F7F9);
  final Color textDark = const Color(0xFF111111);
  final Color customerAccent = const Color(0xFF22C55E); 

  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Image Carousel Header
              SliverAppBar(
                expandedHeight: 350,
                pinned: true,
                backgroundColor: Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: textDark, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      if (widget.property.imageUrls.isEmpty)
                        Container(color: Colors.grey.shade200, child: Center(child: Icon(Icons.landscape_rounded, size: 80, color: Colors.grey.shade400)))
                      else
                        PageView.builder(
                          itemCount: widget.property.imageUrls.length,
                          onPageChanged: (index) => setState(() => _currentImageIndex = index),
                          itemBuilder: (context, index) {
                            final url = widget.property.imageUrls[index];
                            // 👉 FIXED: R2 URLs are always network links, regardless of the platform
                            return Image.network(
                              url, 
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade200, 
                                child: Center(child: Icon(Icons.broken_image_rounded, size: 50, color: Colors.grey.shade400))
                              ),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(child: CircularProgressIndicator(color: customerAccent));
                              },
                            );
                          },
                        ),
                      
                      // Image Indicator
                      if (widget.property.imageUrls.length > 1)
                        Positioned(
                          bottom: 24,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(widget.property.imageUrls.length, (index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentImageIndex == index ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _currentImageIndex == index ? customerAccent : Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Property Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 120), // Bottom padding for action bar
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(12)),
                            child: const Text('Est. Yield 8-12%', style: TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.w900, fontSize: 12)),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                            child: Icon(Icons.favorite_border_rounded, color: textDark),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(widget.property.name, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -1)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 16, color: Colors.grey.shade500),
                          const SizedBox(width: 6),
                          Text(widget.property.location, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      Text('About this Asset', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textDark)),
                      const SizedBox(height: 16),
                      Text(
                        widget.property.description.isEmpty ? 'No description available for this property.' : widget.property.description,
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 16, height: 1.6),
                      ),
                      const SizedBox(height: 40),

                      Text('Available Units', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textDark)),
                      const SizedBox(height: 16),
                      ...widget.property.units.map((unit) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade200)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(unit.name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textDark)),
                                    const SizedBox(height: 4),
                                    Text('${unit.availableFractions} / ${unit.fractions.length} Fractions Left', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 13)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // 👉 FIXED: Currency updated and handled for large strings
                              Text('₹${unit.fractionPrice.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: customerAccent)),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 👉 FIXED: Bottom Action Bar Layout Overflow
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -10))],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Row(
                children: [
                  // Wrapped the price column in an Expanded widget
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Starts at', style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(
                          '₹${widget.startingPrice.toStringAsFixed(0)}', 
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -1),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16), // Added spacing between price and button
                  
                  // Adjusted button padding to be slightly more responsive
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Contact your Agent to secure this fraction!'),
                        backgroundColor: textDark,
                        behavior: SnackBarBehavior.floating,
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: textDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: const Text('Express Interest ⚡️', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}