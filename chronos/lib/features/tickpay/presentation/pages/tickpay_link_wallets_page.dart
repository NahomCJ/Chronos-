import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/app_di.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/text_theme.dart';
import '../../domain/entities/onboarding_entities.dart';
import '../../domain/repositories/tickpay_repository.dart';
import '../constants/tickpay_colors.dart';
import '../widgets/widgets.dart';

/// Lets the user pick which payment method(s) to link to TickPay.
class TickpayLinkWalletsPage extends StatefulWidget {
  const TickpayLinkWalletsPage({super.key});

  @override
  State<TickpayLinkWalletsPage> createState() => _TickpayLinkWalletsPageState();
}

class _TickpayLinkWalletsPageState extends State<TickpayLinkWalletsPage> {
  late final List<WalletOption> _options =
      sl<TickpayRepository>().getWalletOptions();
  final Set<String> _selected = {};

  void _toggle(String id) {
    setState(() {
      if (!_selected.add(id)) _selected.remove(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final int count = _selected.length;
    final bool hasSelection = count > 0;

    return Scaffold(
      backgroundColor: TickpayColors.pureBlack,
      body: TickpayBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TickpayCircleButton(
                  icon: Icons.arrow_back,
                  onTap: () => context.pop(),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  children: [
                    Text(
                      'Link Your Wallets',
                      style: TextStyles.displaySmall.copyWith(
                        color: TickpayColors.textOnDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Choose how you'd like to manage your payments",
                      style: TextStyles.bodyLarge
                          .copyWith(color: TickpayColors.textMutedDark),
                    ),
                    const SizedBox(height: 32),
                    for (final option in _options) ...[
                      WalletOptionTile(
                        option: option,
                        isSelected: _selected.contains(option.id),
                        onTap: () => _toggle(option.id),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 16),
                    _InfoBox(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: TickpayPrimaryButton(
                  label: hasSelection
                      ? 'Continue with $count '
                          '${count == 1 ? 'wallet' : 'wallets'}'
                      : 'Select at least one wallet',
                  onPressed: hasSelection
                      ? () => context.push(
                            RouteConstants.tickpayVerification.toPath,
                          )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TickpayColors.glassFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TickpayColors.glassBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline,
              color: TickpayColors.textMutedDark, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You can add or remove payment methods anytime in your '
              'account settings',
              style: TextStyles.bodySmall.copyWith(
                color: TickpayColors.textMutedDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
