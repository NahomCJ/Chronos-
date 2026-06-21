import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../utils/tickpay_media.dart';

class TickPayAiPicksPage extends StatelessWidget {
  const TickPayAiPicksPage({super.key});

  static const _picks = [
    _Pick('iPhone 15 Pro', 'Apple Store', '\$999', 95, TickPayMedia.iphone15Pro),
    _Pick('Sony WH-1000XMS', 'Best Buy', '\$349', 82, TickPayMedia.headphonesBlack),
    _Pick('MacBook Air M3', 'Apple Store', '\$1,099', 88, TickPayMedia.macbook),
    _Pick('Apple Watch Ultra', 'Apple', '\$799', 85, TickPayMedia.appleWatchBlack),
    _Pick('iPad Pro 12.9"', 'Apple', '\$1,099', 82, TickPayMedia.ipad),
    _Pick('JBL Flip 6 Speaker', 'JBL', '\$129', 78, TickPayMedia.bluetoothSpeaker),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
          children: [
            Positioned.fill(child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
            Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
            Column(
        children: [
          // ── Dark header + AI chat card ────────────────────────────────────
          Container(
            color: const Color(0xFF1A0A2E),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildTopBar(context),
                  _buildChatCard(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // ── White picks list ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Top Picks for You',
                    style: TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text('${_picks.length} items',
                    style: const TextStyle(
                        color: Color(0xFF888888), fontSize: 13)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _picks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _buildPickRow(context, _picks[i]),
            ),
          ),
        ],
      ),
          ],
        ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('AI Picks',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text('Curated by Chris',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
            ],
          ),
          const Spacer(),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle),
            child: const Icon(Icons.notifications_none,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
                color: Color(0xFFDC8F4A), shape: BoxShape.circle),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildChatCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('👋', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Hi I'm Chris 👋",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    Text(
                        'Analyzed your patterns to find products you\'ll love.',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Text('Type your message here...',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13)),
                  const Spacer(),
                  Icon(Icons.send,
                      color: Colors.white.withValues(alpha: 0.6), size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickRow(BuildContext context, _Pick pick) {
    final matchColor = pick.match >= 90
        ? const Color(0xFF00C853)
        : pick.match >= 80
            ? const Color(0xFF7C3AED)
            : const Color(0xFFDC8F4A);

    return GestureDetector(
      onTap: () => context.push(RouteConstants.tickpayProductDetail.toPath,
          extra: {'name': pick.name, 'price': pick.price, 'asset': pick.asset}),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            TickPayImage(
              pick.asset,
              width: 64,
              height: 64,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pick.name,
                      style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(pick.store,
                      style: const TextStyle(
                          color: Color(0xFF888888), fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(pick.price,
                          style: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A693).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: const Color(0xFF00A693)
                                  .withValues(alpha: 0.35)),
                        ),
                        child: const Text('BNPL',
                            style: TextStyle(
                                color: Color(0xFF00A693),
                                fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: matchColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                    color: matchColor.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Center(
                child: Text('${pick.match}%',
                    style: TextStyle(
                        color: matchColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pick {
  final String name, store, price, asset;
  final int match;
  const _Pick(this.name, this.store, this.price, this.match, this.asset);
}
