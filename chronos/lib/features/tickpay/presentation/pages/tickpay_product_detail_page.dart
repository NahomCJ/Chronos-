import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../utils/tickpay_media.dart';

class TickPayProductDetailPage extends StatelessWidget {
  final String name;
  final String price;
  final String asset;

  const TickPayProductDetailPage({
    super.key,
    this.name = 'iPhone 15 Pro',
    this.price = '\$999',
    this.asset = TickPayMedia.iphone15Pro,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductInfo(context),
                _buildBNPLCard(context),
                _buildDescription(),
                _buildKeyFeatures(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: Colors.black.withValues(alpha: 0.8),
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.favorite_border,
                color: Colors.white, size: 20),
            onPressed: () {},
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white, size: 20),
            onPressed: () {},
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            TickPayImage(asset, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFFF2D87),
                    borderRadius: BorderRadius.circular(8)),
                child: const Text('-17% OFF',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: const TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () =>
                context.push(RouteConstants.tickpayShopDetail.toPath),
            child: Row(
              children: [
                Text('Apple Store',
                    style: const TextStyle(
                        color: Color(0xFF7C3AED),
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                const Icon(Icons.chevron_right,
                    color: Color(0xFF7C3AED), size: 16),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.star, color: Color(0xFFFFB800), size: 16),
              const SizedBox(width: 4),
              const Text('4.8',
                  style: TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              Text(' (2,847 reviews)',
                  style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12)),
              const SizedBox(width: 12),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: Color(0xFF00C853), shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              const Text('In Stock',
                  style: TextStyle(color: Color(0xFF00C853), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(price,
                  style: const TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              Text(
                  '\$${(int.tryParse(price.replaceAll(RegExp(r'[^\d]'), '')) ?? 999) + 200}',
                  style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 16,
                      decoration: TextDecoration.lineThrough)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBNPLCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A693).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.attach_money,
                      color: Color(0xFF00A693), size: 16),
                ),
                const SizedBox(width: 8),
                const Text('Buy Now, Pay Later',
                    style: TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 14),
            _infoRow('Payment plan', '4 installments'),
            _infoRow('Each payment', '\$249.75'),
            _infoRow('Frequency', 'Bi-Weekly'),
            _infoRow('First payment', 'Today'),
            _infoRow('Interest',
                '\$0 (0%)', valueColor: const Color(0xFF00C853)),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context
                    .push(RouteConstants.tickpayBnplCheckout.toPath),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A693),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Buy Now, Pay Later',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: valueColor ?? const Color(0xFF1A1A2E),
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Description',
              style: TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'The $name features a titanium design with a 48MP main camera, A17 Pro chip, and Action button. Experience ProMotion display technology and all-day battery life.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyFeatures() {
    final features = [
      'A17 chip with 6-core GPU',
      '48MP Main camera with Super Retina XDR',
      'Titanium design with Ceramic Shield',
      'Action button for quick shortcuts',
      'All-day battery life',
      'Emergency SOS via satellite',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Key Features',
              style: TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle,
                        color: Color(0xFF00C853), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(f,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
