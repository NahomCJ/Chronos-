import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../constants/tickpay_colors.dart';
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
      body: CustomScrollView(
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
    );
  }

  Widget _buildDivider() => const Divider(height: 1, color: TickpayColors.divider);

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
          child: const Icon(Icons.arrow_back, color: TickpayColors.textPrimaryLight, size: 20),
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
              color: _wishlisted ? TickpayColors.negative : TickpayColors.textPrimaryLight,
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
                color: TickpayColors.textPrimaryLight, size: 18),
            onPressed: () {},
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: TickpayColors.neutralSurface),
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
                    color: TickpayColors.negative,
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
                    color: TickpayColors.negative,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 6),
          Text(widget.name,
              style: const TextStyle(
                  color: TickpayColors.textPrimaryLight,
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
                        color: TickpayColors.warning,
                        size: 16,
                      )),
              const SizedBox(width: 6),
              const Text('4.8',
                  style: TextStyle(
                      color: TickpayColors.textPrimaryLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              Text(' (2,847 reviews)',
                  style: TextStyle(
                      color: TickpayColors.textMutedLight, fontSize: 12)),
              const SizedBox(width: 12),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                    color: TickpayColors.positive, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              const Text('In Stock',
                  style:
                      TextStyle(color: TickpayColors.positive, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(widget.price,
                  style: const TextStyle(
                      color: TickpayColors.textPrimaryLight,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5)),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text('\$$msrp',
                    style: TextStyle(
                        color: TickpayColors.textMutedLight,
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
                    color: TickpayColors.negative.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Save \$200',
                      style: TextStyle(
                          color: TickpayColors.negative,
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
                  color: TickpayColors.accentPurple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.attach_money,
                    color: TickpayColors.accentPurple, size: 15),
              ),
              const SizedBox(width: 8),
              const Text(
                'Buy Now, Pay Later',
                style: TextStyle(
                    color: TickpayColors.textPrimaryLight,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text('0% APR',
                  style: TextStyle(
                      color: TickpayColors.positive.withValues(alpha: 0.9),
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
                      ? TickpayColors.accentPurple.withValues(alpha: 0.07)
                      : TickpayColors.neutralSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? TickpayColors.accentPurple
                        : TickpayColors.divider,
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
                                  ? TickpayColors.accentPurple
                                  : const Color(0xFFCCCCCC),
                              width: 1.5,
                            ),
                            color: isSelected
                                ? TickpayColors.accentPurple
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
                                  color: TickpayColors.textPrimaryLight,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(plan.$2,
                                style: const TextStyle(
                                    color: TickpayColors.textMutedLight, fontSize: 11)),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${plan.$3.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: TickpayColors.textPrimaryLight,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Text('per payment',
                                style: TextStyle(
                                    color: TickpayColors.textMutedLight, fontSize: 10)),
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
                            color: TickpayColors.accentPurple,
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
                  color: TickpayColors.textPrimaryLight,
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
                        bottom: BorderSide(color: TickpayColors.divider))
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isFirst
                          ? TickpayColors.accentPurple.withValues(alpha: 0.12)
                          : TickpayColors.neutralSurface,
                      shape: BoxShape.circle,
                    ),
                    child: isFirst
                        ? const Icon(Icons.check,
                            color: TickpayColors.accentPurple, size: 13)
                        : Center(
                            child: Text('${e.key + 1}',
                                style: const TextStyle(
                                    color: TickpayColors.textMutedLight,
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
                                    ? TickpayColors.textPrimaryLight
                                    : TickpayColors.textMutedLight,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        Text('Payment ${e.key + 1} of $count',
                            style: const TextStyle(
                                color: TickpayColors.textMutedLight, fontSize: 10)),
                      ],
                    ),
                  ),
                  Text('\$${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: TickpayColors.textPrimaryLight,
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
                      ? TickpayColors.accentPurple
                      : const Color(0xFFCCCCCC),
                ),
                color: _agreedToTerms
                    ? TickpayColors.accentPurple
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
                  color: TickpayColors.textMutedLight, fontSize: 11, height: 1.4),
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
                color: TickpayColors.textPrimaryLight,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        iconColor: TickpayColors.textPrimaryLight,
        collapsedIconColor: TickpayColors.textPrimaryLight,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              '${widget.name} delivers an outstanding combination of performance and design. '
              'Featuring advanced processing, premium build quality, and long-lasting battery life, '
              "it's engineered for those who demand the best.",
              style: TextStyle(
                  color: TickpayColors.textMutedLight,
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
                color: TickpayColors.textPrimaryLight,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        iconColor: TickpayColors.textPrimaryLight,
        collapsedIconColor: TickpayColors.textPrimaryLight,
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
                                color: TickpayColors.positive, size: 15),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(f,
                                  style: TextStyle(
                                      color: TickpayColors.textMutedLight,
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
                side: const BorderSide(color: TickpayColors.textPrimaryLight),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Add to Cart',
                  style: TextStyle(
                      color: TickpayColors.textPrimaryLight,
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
                backgroundColor: TickpayColors.textPrimaryLight,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                disabledBackgroundColor: TickpayColors.divider,
                disabledForegroundColor: TickpayColors.textMutedLight,
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
