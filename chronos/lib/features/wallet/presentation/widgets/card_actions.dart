import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/router/route_constants.dart';
import 'card_details/card_details_modal.dart';
import 'card_settings/freeze_card_modal.dart';
import 'cash_out/cash_out_method_modal.dart';
import 'add_new_card/add_new_card_modal.dart';

class CardActions extends StatelessWidget {
  const CardActions({super.key});

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.of(context).size.width < 360 ? 0.9 : 1.0;
    final double textScale = MediaQuery.of(context).textScaler.scale(1.0);

    return Column(
      children: [
        /// ───────────── Top Quick Actions ─────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickAction(
              icon: Icons.ac_unit,
              label: 'Freeze',
              scale: scale,
              textScale: textScale,
              onTap: () => FreezeCardModal.show(context),
            ),
            _buildQuickAction(
              icon: Icons.visibility_outlined,
              label: 'Details',
              scale: scale,
              textScale: textScale,
              onTap: () => CardDetailsModal.show(context),
            ),
            _buildQuickAction(
              icon: Icons.search,
              label: 'Find ATM',
              scale: scale,
              textScale: textScale,
              onTap: () => context.push(RouteConstants.findAtm.toPath),
            ),
            _buildQuickAction(
              icon: Icons.attach_money,
              label: 'Cash Out',
              scale: scale,
              textScale: textScale,
              onTap: () => CashOutMethodModal.show(context),
            ),
          ],
        ),

        const SizedBox(height: 18), // ↓ reduced from 28

        /// ───────────── Bottom Actions ─────────────
        Row(
          children: [
            Expanded(
              child: Center(
                child: _buildQuickAction(
                  icon: Icons.add,
                  label: 'Add New Card',
                  scale: scale,
                  textScale: textScale,
                  onTap: () => AddNewCardModal.show(context),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: _buildQuickAction(
                  icon: Icons.analytics_outlined,
                  label: 'Wallet Analytics',
                  scale: scale,
                  textScale: textScale,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Wallet Analytics feature coming soon!'),
                        backgroundColor: Color(0xFF6366F1),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// ───────────── Reusable Circular Action (Reduced) ─────────────
  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required double scale,
    required double textScale,
    required VoidCallback onTap,
  }) {
    final double circleSize = 48 * scale; // ↓ reduced from 58

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2), // slightly lighter
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 22 * scale, // ↓ reduced from 26
            ),
          ),
          const SizedBox(height: 6), // ↓ reduced from 10
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyles.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 10.5 * textScale, // ↓ slightly reduced
            ),
          ),
        ],
      ),
    );
  }
}
