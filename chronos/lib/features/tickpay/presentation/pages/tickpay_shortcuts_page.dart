import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/app_di.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/text_theme.dart';
import '../../domain/entities/shortcut_action.dart';
import '../../domain/repositories/tickpay_repository.dart';
import '../constants/tickpay_colors.dart';
import '../widgets/widgets.dart';

/// Quick-access grid of TickPay actions ("Shortcuts").
class TickpayShortcutsPage extends StatelessWidget {
  const TickpayShortcutsPage({super.key});

  /// Maps a shortcut to an in-app destination where one exists.
  void _handleTap(BuildContext context, ShortcutAction action) {
    final String? route = switch (action.label) {
      'Rewards' => RouteConstants.tickpayRewards.toPath,
      'Alerts' => RouteConstants.tickpayNotifications.toPath,
      'Credit' => RouteConstants.tickpayCreditOverview.toPath,
      'Plans' => RouteConstants.tickpayActivePlans.toPath,
      _ => null,
    };

    if (route != null) {
      context.push(route);
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('${action.label} coming soon')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shortcuts = sl<TickpayRepository>().getShortcuts();

    return Scaffold(
      backgroundColor: TickpayColors.scaffoldLight,
      body: Stack(
          children: [
            Positioned.fill(child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
            Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
            SafeArea(
          child: Column(
            children: [
              TickpayHeader(
                title: 'Shortcuts',
                subtitle: 'Quick access to actions',
                onBack: () => context.pop(),
                onNotifications: () =>
                    context.push(RouteConstants.tickpayNotifications.toPath),
                onChat: () => context.push(RouteConstants.tickpayRewards.toPath),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: shortcuts.length,
                  itemBuilder: (_, i) => ShortcutTile(
                    action: shortcuts[i],
                    onTap: () => _handleTap(context, shortcuts[i]),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TickpayColors.cardWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: TickpayColors.divider),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: TickpayColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.info_outline,
                            color: TickpayColors.info, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customize Shortcuts',
                              style: TextStyles.titleMedium.copyWith(
                                color: TickpayColors.textPrimaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Long press any shortcut to rearrange or add '
                              'new ones to your home screen',
                              style: TextStyles.bodySmall.copyWith(
                                color: TickpayColors.textMutedLight,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
          ],
        ),
    );
  }
}
