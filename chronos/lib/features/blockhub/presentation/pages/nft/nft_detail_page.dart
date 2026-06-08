import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';
import 'nft_buy_sheet.dart';
import 'nft_offer_sheet.dart';
import 'nft_price_history_page.dart';

class NftDetailPage extends StatelessWidget {
  const NftDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ColoredBox(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildWhiteTop(context), _buildDarkBody(context)],
          ),
        ),
      ),
    );
  }

  // ── White section: header + NFT image ────────────────────────────────────
  Widget _buildWhiteTop(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.black87, size: 20),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'BlockHub NFTs',
                          style: TextStyles.titleMedium.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Discover curated digital assets',
                          style: TextStyles.bodySmall.copyWith(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            // NFT image
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 240,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/btc.png',
                        fit: BoxFit.contain,
                        errorBuilder:
                            (_, __, ___) => Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: Colors.white.withValues(alpha: 0.3),
                                size: 60,
                              ),
                            ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.open_in_full,
                        color: Colors.white,
                        size: 16,
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

  // ── Dark section: all detail content ─────────────────────────────────────
  Widget _buildDarkBody(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: AssetImage('assets/background.png'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        20,
        16,
        MediaQuery.of(context).padding.bottom + 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collection label
          Text(
            'Holographic Futures',
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          // Title
          Text(
            'Holographic #9012',
            style: TextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          // Owner
          Row(
            children: [
              Text(
                'Owned by ',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
              Text(
                '0x9876...5432',
                style: TextStyles.bodySmall.copyWith(
                  color: const Color(0xFF00D4FF),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPriceCard(context),
          const SizedBox(height: 20),
          _buildDetailsCard(),
          const SizedBox(height: 20),
          _buildTraitsSection(),
          const SizedBox(height: 24),
          _buildBottomButtons(context),
        ],
      ),
    );
  }

  Widget _buildPriceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Price',
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '3.5 ETH',
                      style: TextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '\$8400.00',
                      style: TextStyles.bodySmall.copyWith(
                        color: const Color(0xFF00D4FF),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Last Sale',
                    style: TextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '3.2',
                    style: TextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'ETH',
                    style: TextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => NftBuySheet.show(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Buy Now',
                    style: TextStyles.labelLarge.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => NftOfferSheet.show(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: Text(
                    'Make Offer',
                    style: TextStyles.labelLarge.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: TextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _detailRow('Network', 'Polygon', Colors.white),
          _divider(),
          _detailRow('Royalty', '10%', Colors.white),
          _divider(),
          _detailRow('Rarity Score', '#92', const Color(0xFF00D4FF)),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyles.bodyMedium.copyWith(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
    color: Colors.white.withValues(alpha: 0.07),
    height: 1,
    thickness: 0.5,
  );

  Widget _buildTraitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Traits',
          style: TextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _traitCard('TYPE', 'Holographic', '13% rarity')),
            const SizedBox(width: 10),
            Expanded(child: _traitCard('DIMENSION', '4D', '8% rarity')),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _traitCard('EFFECT', 'Shimmer', '22% rarity')),
            const SizedBox(width: 10),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _traitCard(String type, String value, String rarity) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type,
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rarity,
            style: TextStyles.bodySmall.copyWith(
              color: const Color(0xFF22C55E),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NftPriceHistoryPage(),
                  ),
                ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 0,
            ),
            child: Text(
              'View Price History',
              style: TextStyles.labelMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Activity',
                  style: TextStyles.labelMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.open_in_new,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
