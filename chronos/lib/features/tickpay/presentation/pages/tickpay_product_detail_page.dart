import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../utils/tickpay_media.dart';

class TickPayProductDetailPage extends StatefulWidget {
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
  State<TickPayProductDetailPage> createState() =>
      _TickPayProductDetailPageState();
}

class _TickPayProductDetailPageState extends State<TickPayProductDetailPage> {
  int _selectedPlan = 1;
  bool _agreedToTerms = false;

  static const _bnplPlans = [
    (2, 'Monthly', 499.50),
    (4, 'Bi-weekly', 249.75),
    (6, 'Bi-weekly', 166.50),
  ];

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
                _buildBNPLSection(context),
                _buildPaymentSchedule(),
                _buildDescription(),
                _buildKeyFeatures(),
                const SizedBox(height: 24),
                _buildTermsRow(),
                const SizedBox(height: 16),
                _buildAcceptButton(context),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Your first payment of \$${_bnplPlans[_selectedPlan].$3.toStringAsFixed(2)} will be charged today',
                    style: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 11),
                  ),
                ),
                const SizedBox(height: 40),
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
            TickPayImage(widget.asset, fit: BoxFit.cover),
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
          Text(widget.name,
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
              Text(widget.price,
                  style: const TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              Text(
                  '\$${(int.tryParse(widget.price.replaceAll(RegExp(r'[^\d]'), '')) ?? 999) + 200}',
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

  Widget _buildBNPLSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF00A693).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.attach_money, color: Color(0xFF00A693), size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Buy Now, Pay Later',
                style: TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._bnplPlans.asMap().entries.map((e) {
            final i = e.key;
            final plan = e.value;
            final isSelected = _selectedPlan == i;
            final isMostPopular = i == 1;
            return GestureDetector(
              onTap: () => setState(() => _selectedPlan = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF0EBFF) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFEEEEEE),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFCCCCCC),
                              width: 1.5,
                            ),
                            color: isSelected ? const Color(0xFF7C3AED) : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 12)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${plan.$1} Payments',
                              style: const TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              plan.$2,
                              style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${plan.$3.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'per payment',
                              style: TextStyle(color: Color(0xFF999999), fontSize: 11),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              '0% APR',
                              style: TextStyle(
                                color: Color(0xFF00C853),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (isMostPopular)
                      Positioned(
                        top: -2,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Most Popular',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentSchedule() {
    final dates = ['Today', 'May 21, 2026', 'Jun 4, 2026', 'Jun 18, 2026'];
    final plan = _bnplPlans[_selectedPlan];
    final amount = plan.$3;
    final count = plan.$1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Schedule',
            style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEEEEE)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
            ),
            child: Column(
              children: dates.take(count).toList().asMap().entries.map((e) {
                final isFirst = e.key == 0;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: e.key < count - 1
                        ? const Border(bottom: BorderSide(color: Color(0xFFF0F0F0)))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isFirst
                              ? const Color(0xFF00A693).withValues(alpha: 0.15)
                              : const Color(0xFFF5F5F5),
                          shape: BoxShape.circle,
                        ),
                        child: isFirst
                            ? const Icon(Icons.check, color: Color(0xFF00A693), size: 14)
                            : Center(
                                child: Text('${e.key + 1}',
                                    style: const TextStyle(color: Color(0xFF888888), fontSize: 11))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.value,
                              style: TextStyle(
                                color: isFirst ? const Color(0xFF1A1A1A) : const Color(0xFF555555),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text('Payment ${e.key + 1} of $count',
                                style: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 11)),
                          ],
                        ),
                      ),
                      Text('\$${amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Color(0xFF1A1A1A), fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _agreedToTerms ? const Color(0xFF00A693) : const Color(0xFFCCCCCC),
                ),
                color: _agreedToTerms ? const Color(0xFF00A693) : Colors.transparent,
              ),
              child: _agreedToTerms
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'I agree to the Terms of Service and Payment Agreement. I understand that missing payments may result in fees and impact my credit score.',
              style: TextStyle(color: Color(0xFF888888), fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _agreedToTerms
              ? () => context.push(RouteConstants.tickpayBnplCheckout.toPath)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A0A2E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            elevation: 0,
            disabledBackgroundColor: const Color(0xFFDDDDDD),
            disabledForegroundColor: const Color(0xFF999999),
          ),
          child: const Text(
            'Accept Terms to Continue',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        title: const Text('Description',
            style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        iconColor: const Color(0xFF1A1A2E),
        collapsedIconColor: const Color(0xFF1A1A2E),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              '${widget.name} delivers an outstanding combination of performance and design. '
              'Featuring advanced processing, premium build quality, and long-lasting battery life, '
              "it's engineered for those who demand the best.",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyFeatures() {
    final features = [
      'High-performance processor',
      'Pro-grade camera system',
      'Premium build materials',
      'Customizable quick-action controls',
      'All-day battery life',
      'Advanced connectivity & safety features',
    ];
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        title: const Text('Key Features',
            style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        iconColor: const Color(0xFF1A1A2E),
        collapsedIconColor: const Color(0xFF1A1A2E),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              children: features
                  .map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle,
                                color: Color(0xFF00C853), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(f,
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13)),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
