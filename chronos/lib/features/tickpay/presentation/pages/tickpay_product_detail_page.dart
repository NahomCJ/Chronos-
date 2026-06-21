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
  bool _wishlisted = false;

  static const _bnplPlans = [
    (2, 'Monthly', 499.50),
    (4, 'Bi-weekly', 249.75),
    (6, 'Bi-weekly', 166.50),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomCta(context),
      body: Stack(
          children: [
            Positioned.fill(child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
            Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
            CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductInfo(),
                const SizedBox(height: 4),
                _buildDivider(),
                _buildBNPLSection(),
                _buildDivider(),
                _buildPaymentSchedule(),
                _buildDivider(),
                _buildDescription(),
                _buildKeyFeatures(),
                _buildDivider(),
                _buildTermsRow(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
          ],
        ),
    );
  }

  Widget _buildDivider() => const Divider(height: 1, color: Color(0xFFF0F0F0));

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.07),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => setState(() => _wishlisted = !_wishlisted),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _wishlisted ? Icons.favorite : Icons.favorite_border,
              color: _wishlisted ? const Color(0xFFFF2D87) : Colors.black87,
              size: 20,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.07),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.share_outlined,
                color: Colors.black87, size: 18),
            onPressed: () {},
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: const Color(0xFFF8F8F8)),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
              child: TickPayImage(widget.asset, fit: BoxFit.contain),
            ),
            if (true)
              Positioned(
                top: 60,
                left: 14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF2D87),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('-17% OFF',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    final msrp = (int.tryParse(
                widget.price.replaceAll(RegExp(r'[^\d]'), '')) ??
            999) +
        200;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () =>
                context.push(RouteConstants.tickpayShopDetail.toPath),
            child: Text('Apple Store',
                style: const TextStyle(
                    color: Color(0xFFFF2D87),
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 6),
          Text(widget.name,
              style: const TextStyle(
                  color: Color(0xFF111111),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3)),
          const SizedBox(height: 10),
          Row(
            children: [
              ...List.generate(
                  5,
                  (i) => Icon(
                        i < 4 ? Icons.star_rounded : Icons.star_half_rounded,
                        color: const Color(0xFFFFB800),
                        size: 16,
                      )),
              const SizedBox(width: 6),
              const Text('4.8',
                  style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              Text(' (2,847 reviews)',
                  style: TextStyle(
                      color: Colors.grey.shade400, fontSize: 12)),
              const SizedBox(width: 12),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                    color: Color(0xFF00C853), shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              const Text('In Stock',
                  style:
                      TextStyle(color: Color(0xFF00C853), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(widget.price,
                  style: const TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5)),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text('\$$msrp',
                    style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 15,
                        decoration: TextDecoration.lineThrough)),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF2D87).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Save \$200',
                      style: TextStyle(
                          color: Color(0xFFFF2D87),
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBNPLSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFF00A693).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.attach_money,
                    color: Color(0xFF00A693), size: 15),
              ),
              const SizedBox(width: 8),
              const Text(
                'Buy Now, Pay Later',
                style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text('0% APR',
                  style: TextStyle(
                      color: const Color(0xFF00C853).withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
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
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF00A693).withValues(alpha: 0.07)
                      : const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF00A693)
                        : const Color(0xFFEEEEEE),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF00A693)
                                  : const Color(0xFFCCCCCC),
                              width: 1.5,
                            ),
                            color: isSelected
                                ? const Color(0xFF00A693)
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 11)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${plan.$1} Payments',
                              style: const TextStyle(
                                  color: Color(0xFF111111),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(plan.$2,
                                style: const TextStyle(
                                    color: Color(0xFF888888), fontSize: 11)),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${plan.$3.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Color(0xFF111111),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Text('per payment',
                                style: TextStyle(
                                    color: Color(0xFF999999), fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                    if (isMostPopular)
                      Positioned(
                        top: -4,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00A693),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Popular',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Schedule',
              style: TextStyle(
                  color: Color(0xFF111111),
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...dates.take(count).toList().asMap().entries.map((e) {
            final isFirst = e.key == 0;
            return Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: e.key < count - 1
                    ? const Border(
                        bottom: BorderSide(color: Color(0xFFF0F0F0)))
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isFirst
                          ? const Color(0xFF00A693).withValues(alpha: 0.12)
                          : const Color(0xFFF5F5F5),
                      shape: BoxShape.circle,
                    ),
                    child: isFirst
                        ? const Icon(Icons.check,
                            color: Color(0xFF00A693), size: 13)
                        : Center(
                            child: Text('${e.key + 1}',
                                style: const TextStyle(
                                    color: Color(0xFF888888),
                                    fontSize: 10))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.value,
                            style: TextStyle(
                                color: isFirst
                                    ? const Color(0xFF111111)
                                    : const Color(0xFF555555),
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        Text('Payment ${e.key + 1} of $count',
                            style: const TextStyle(
                                color: Color(0xFFBBBBBB), fontSize: 10)),
                      ],
                    ),
                  ),
                  Text('\$${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTermsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () =>
                setState(() => _agreedToTerms = !_agreedToTerms),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _agreedToTerms
                      ? const Color(0xFF00A693)
                      : const Color(0xFFCCCCCC),
                ),
                color: _agreedToTerms
                    ? const Color(0xFF00A693)
                    : Colors.transparent,
              ),
              child: _agreedToTerms
                  ? const Icon(Icons.check,
                      color: Colors.white, size: 14)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'I agree to the Terms of Service and Payment Agreement. I understand that missing payments may result in fees.',
              style: TextStyle(
                  color: Color(0xFF888888), fontSize: 11, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        title: const Text('Description',
            style: TextStyle(
                color: Color(0xFF111111),
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        iconColor: const Color(0xFF111111),
        collapsedIconColor: const Color(0xFF111111),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              '${widget.name} delivers an outstanding combination of performance and design. '
              'Featuring advanced processing, premium build quality, and long-lasting battery life, '
              "it's engineered for those who demand the best.",
              style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  height: 1.5),
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
    ];
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        title: const Text('Key Features',
            style: TextStyle(
                color: Color(0xFF111111),
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        iconColor: const Color(0xFF111111),
        collapsedIconColor: const Color(0xFF111111),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              children: features
                  .map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle,
                                color: Color(0xFF00C853), size: 15),
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

  Widget _buildBottomCta(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                side: const BorderSide(color: Color(0xFF111111)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Add to Cart',
                  style: TextStyle(
                      color: Color(0xFF111111),
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _agreedToTerms
                  ? () => context
                      .push(RouteConstants.tickpayBnplCheckout.toPath)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111111),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                disabledBackgroundColor: const Color(0xFFDDDDDD),
                disabledForegroundColor: const Color(0xFF999999),
              ),
              child: Text(
                'Buy · \$${_bnplPlans[_selectedPlan].$3.toStringAsFixed(2)}/mo',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
