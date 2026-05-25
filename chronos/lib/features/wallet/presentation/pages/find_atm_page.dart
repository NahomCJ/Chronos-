import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/router/route_constants.dart';

class FindAtmPage extends StatelessWidget {
  const FindAtmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. FIXED BACKGROUND (Does not move)
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),

          // 2. SCROLLABLE LAYER
          Column(
            children: [
              // FIXED WHITE APPBAR
              Container(
                color: Colors.white,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(RouteConstants.home.toPath);
                            }
                          },
                        ),
                        Expanded(
                          child: Text(
                            'Wallet',
                            textAlign: TextAlign.center,
                            style: TextStyles.headlineSmall.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.settings_outlined,
                            color: Colors.black,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // SCROLL CONTENT
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // WHITE TOP SECTION (Location Card)
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF302B48),
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF302B48), Color(0xFF6D64A5)],
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Your Location',
                                style: TextStyles.bodyMedium.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '5 ATMs Nearby',
                                style: TextStyles.titleMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // WHITE SECTION WITH NEARBY ATMS HEADER
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          'Nearby ATMs',
                          style: TextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // TRANSPARENT BOTTOM SECTION (ATM List - Reveals the fixed background)
                      Container(
                        color: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildAtmCard(
                              context: context,
                              bankName: 'Chase Bank ATM',
                              address: '123 Main Street, Downtown',
                              status: 'Available',
                              statusColor: const Color(0xFF5DAA9A),
                              isAvailable: true,
                            ),

                            const SizedBox(height: 16),

                            _buildAtmCard(
                              context: context,
                              bankName: 'Citibank ATM',
                              address: '321 Elm Street, Shopping Mall',
                              status: 'Busy',
                              statusColor: Colors.orange,
                              isAvailable: false,
                            ),

                            const SizedBox(height: 16),

                            _buildAtmCard(
                              context: context,
                              bankName: 'US Bank ATM',
                              address: '654 Maple Drive, Riverside',
                              status: 'Available',
                              statusColor: const Color(0xFF5DAA9A),
                              isAvailable: true,
                            ),

                            const SizedBox(
                              height: 120,
                            ), // Padding for BottomNav
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAtmCard({
    required BuildContext context,
    required String bankName,
    required String address,
    required String status,
    required Color statusColor,
    required bool isAvailable,
  }) {
    return Container(
      padding: const EdgeInsets.all(14), // ↓ reduced from 20
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14), // ↓ from 16
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8, // ↓ from 10
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ───── Header ─────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6), // ↓ from 8
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.orange,
                  size: 18, // ↓ from 20
                ),
              ),
              const SizedBox(width: 10), // ↓ from 12
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bankName,
                      style: TextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2), // ↓ from 4
                    Text(
                      address,
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12), // ↓ from 16
          /// ───── Status Row ─────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, // ↓ from 12
                  vertical: 4, // ↓ from 6
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16), // ↓ from 20
                ),
                child: Text(
                  status,
                  style: TextStyles.labelSmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10), // ↓ from 12
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 14, // ↓ from 16
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '24/7',
                    style: TextStyles.labelSmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12), // ↓ from 16
          /// ───── Divider ─────
          Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),

          const SizedBox(height: 12), // ↓ from 16
          /// ───── Directions Button ─────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening directions to $bankName...'),
                    backgroundColor: const Color(0xFFB0B0B0),
                  ),
                );
              },
              icon: const Icon(Icons.directions, size: 18), // ↓ from 20
              label: const Text('Directions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB0B0B0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8), // ↓ from 12
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26), // ↓ from 30
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
