import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import '../../../../core/widgets/chris_home_fab.dart';

class WalletAnalyticsPage extends StatefulWidget {
  const WalletAnalyticsPage({super.key});

  @override
  State<WalletAnalyticsPage> createState() => _WalletAnalyticsPageState();
}

class _WalletAnalyticsPageState extends State<WalletAnalyticsPage> {
  int _periodIndex = 1; // 0=Week, 1=Month, 2=Year
  static const _periods = ['Week', 'Month', 'Year'];

  // Monthly spend data (last 6 months)
  static const _monthlySpend = [1240.0, 980.0, 1560.0, 820.0, 1380.0, 1120.0];
  static const _monthLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

  static const _categories = [
    ('🛒', 'Shopping', '\$342.50', 0.31, Color(0xFF8B5CF6)),
    ('🍔', 'Food & Drink', '\$214.80', 0.19, Color(0xFFEC4899)),
    ('🚗', 'Transport', '\$178.20', 0.16, Color(0xFF3B82F6)),
    ('🎮', 'Entertainment', '\$156.00', 0.14, Color(0xFFF59E0B)),
    ('💊', 'Health', '\$98.50', 0.09, Color(0xFF10B981)),
    ('⚡', 'Utilities', '\$130.00', 0.11, Color(0xFF06B6D4)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 90),
        child: const ChrisHomeFab(),
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: 4,
        onItemSelected: (i) {
          switch (i) {
            case 0: context.go(RouteConstants.home.toPath);
            case 1: context.go(RouteConstants.pantherAi.toPath);
            case 2: context.go(RouteConstants.blockHub.toPath);
          }
        },
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/background.png', fit: BoxFit.cover)),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryRow(),
                        const SizedBox(height: 20),
                        _buildPeriodSelector(),
                        const SizedBox(height: 16),
                        _buildSpendingChart(),
                        const SizedBox(height: 20),
                        _buildCategoryTitle(),
                        const SizedBox(height: 12),
                        _buildCategoryList(),
                        const SizedBox(height: 20),
                        _buildCashFlowCard(),
                        const SizedBox(height: 120),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RouteConstants.home.toPath);
              }
            },
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Spending Analytics', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('June 2026', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.ios_share_outlined, color: Colors.white.withValues(alpha: 0.7), size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(child: _summaryCard('Spent', '\$1,120', '-8.3%', false, const Color(0xFFEF4444))),
        const SizedBox(width: 12),
        Expanded(child: _summaryCard('Saved', '\$640', '+12.1%', true, const Color(0xFF10B981))),
        const SizedBox(width: 12),
        Expanded(child: _summaryCard('Income', '\$3,200', '+5.0%', true, const Color(0xFF8B5CF6))),
      ],
    );
  }

  Widget _summaryCard(String label, String value, String change, bool positive, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 3),
          Row(
            children: [
              Icon(positive ? Icons.arrow_upward : Icons.arrow_downward, color: color, size: 10),
              Text(change, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: _periods.asMap().entries.map((e) {
        final sel = _periodIndex == e.key;
        return GestureDetector(
          onTap: () => setState(() => _periodIndex = e.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? Colors.white : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(e.value, style: TextStyle(
              color: sel ? Colors.black : Colors.white.withValues(alpha: 0.6),
              fontSize: 13, fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
            )),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSpendingChart() {
    final maxVal = _monthlySpend.reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Monthly Spending', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Avg \$1,183', style: TextStyle(color: Color(0xFF8B5CF6), fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _monthlySpend.asMap().entries.map((e) {
                final heightPct = e.value / maxVal;
                final isLast = e.key == _monthlySpend.length - 1;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          height: 90 * heightPct,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: isLast
                                  ? [const Color(0xFF8B5CF6), const Color(0xFFAB7FF8)]
                                  : [Colors.white.withValues(alpha: 0.25), Colors.white.withValues(alpha: 0.15)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(_monthLabels[e.key], style: TextStyle(
                          color: isLast ? Colors.white : Colors.white.withValues(alpha: 0.45),
                          fontSize: 10, fontWeight: isLast ? FontWeight.w700 : FontWeight.w400,
                        )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTitle() {
    return const Text('By Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15));
  }

  Widget _buildCategoryList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: _categories.asMap().entries.map((entry) {
          final c = entry.value;
          final isLast = entry.key == _categories.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  children: [
                    Text(c.$1, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(c.$2, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13)),
                              Text(c.$3, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: c.$4,
                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(c.$5),
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('${(c.$4 * 100).toInt()}%', style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4), fontSize: 12,
                    )),
                  ],
                ),
              ),
              if (!isLast) Divider(color: Colors.white.withValues(alpha: 0.06), height: 0),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCashFlowCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cash Flow', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 16),
          _flowRow('Income', '\$3,200.00', const Color(0xFF10B981), Icons.arrow_downward),
          const SizedBox(height: 12),
          _flowRow('Expenses', '\$1,120.00', const Color(0xFFEF4444), Icons.arrow_upward),
          const Divider(color: Colors.white12, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Net Savings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('+\$2,080.00', style: TextStyle(
                  color: Color(0xFF10B981), fontWeight: FontWeight.w700, fontSize: 14,
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _flowRow(String label, String amount, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
        ),
        Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}
