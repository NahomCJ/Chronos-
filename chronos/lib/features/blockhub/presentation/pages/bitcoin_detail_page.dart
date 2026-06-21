import 'package:flutter/material.dart';
import '../../../../core/theme/text_theme.dart';
import 'sell/sell_btc_page.dart';

class BitcoinDetailPage extends StatefulWidget {
  const BitcoinDetailPage({super.key});

  @override
  State<BitcoinDetailPage> createState() => _BitcoinDetailPageState();
}

class _BitcoinDetailPageState extends State<BitcoinDetailPage> {
  String _selectedTab = 'Overview';
  String _selectedTimeframe = '1D';

  final List<String> _tabs = [
    'Overview',
    'Chart',
    'Info',
    'News',
    'Related',
    'Depth',
  ];
  final List<String> _timeframes = ['1H', '1D', '1W', '1M', 'YTD'];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(child: Image.asset('assets/background.png', fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.65))),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Bitcoin Icon
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.currency_bitcoin,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bitcoin',
                            style: TextStyles.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'BTC',
                            style: TextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Price Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$64,250',
                        style: TextStyles.headlineLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: isSmallScreen ? 32 : 36,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: const Color(0xFF10B981),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+5.2% (24h)',
                            style: TextStyles.bodyMedium.copyWith(
                              color: const Color(0xFF10B981),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to Buy BTC flow
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Buy BTC',
                            style: TextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to Sell BTC flow
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SellBtcPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Sell BTC',
                            style: TextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Tab Navigation
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _tabs.length,
                    itemBuilder: (context, index) {
                      final tab = _tabs[index];
                      final isSelected = _selectedTab == tab;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTab = tab;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 24),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            tab,
                            style: TextStyles.bodyMedium.copyWith(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.6),
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Content based on selected tab
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildTabContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 'Overview':
        return _buildOverviewContent();
      case 'Chart':
        return _buildChartContent();
      case 'Info':
        return _buildInfoContent();
      case 'News':
        return _buildNewsContent();
      case 'Related':
        return _buildRelatedContent();
      case 'Depth':
        return _buildDepthContent();
      default:
        return _buildOverviewContent();
    }
  }

  Widget _buildOverviewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time Period Selector
        Row(
          children:
              _timeframes.map((timeframe) {
                final isSelected = _selectedTimeframe == timeframe;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTimeframe = timeframe;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isSelected
                                ? Colors.white.withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      timeframe,
                      style: TextStyles.bodySmall.copyWith(
                        color:
                            isSelected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.7),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),

        const SizedBox(height: 20),

        // Chart Placeholder
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomPaint(painter: BitcoinChartPainter()),
        ),

        const SizedBox(height: 32),

        // Key Stats
        Text(
          'Key Stats',
          style: TextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(child: _buildStatItem('Market Cap', '\$1.25T')),
            Expanded(child: _buildStatItem('24h Volume', '\$35.4B')),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(child: _buildStatItem('Circulating Supply', '19.5M BTC')),
            Expanded(child: _buildStatItem('All-Time High', '\$69,000')),
          ],
        ),

        const SizedBox(height: 32),

        // About Section
        Text(
          'About',
          style: TextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'The first decentralized cryptocurrency, created by Satoshi Nakamoto.',
          style: TextStyles.bodyMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildChartContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Advanced Chart Title
        Text(
          'Advanced Chart',
          style: TextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),

        const SizedBox(height: 20),

        // Chart Container
        Container(
          height: 350,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomPaint(painter: AdvancedChartPainter()),
        ),

        const SizedBox(height: 32),

        // Available Indicators
        Text(
          'Available Indicators',
          style: TextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),

        const SizedBox(height: 16),

        // Indicators Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: [
            _buildIndicatorCard('RSI (14)', 'Relative Strength Index'),
            _buildIndicatorCard('MACD', 'Moving Average\nConvergence'),
            _buildIndicatorCard('MA (50/200)', 'Moving Averages'),
            _buildIndicatorCard('Bollinger Bands', 'Volatility Indicator'),
          ],
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildIndicatorCard(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overview Section
        Text(
          'Overview',
          style: TextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Text(
            'Bitcoin is the world\'s first decentralized cryptocurrency, created in 2009 by the pseudonymous Satoshi Nakamoto. It operates on a peer-to-peer network without central authority, using blockchain technology to secure transactions.',
            style: TextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Use Cases Section
        Text(
          'Use Cases',
          style: TextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBulletPoint('Store of value and digital gold'),
              _buildBulletPoint('Cross-border payments and remittances'),
              _buildBulletPoint('Hedge against inflation'),
              _buildBulletPoint('Decentralized payment system'),
              _buildBulletPoint(
                'Financial sovereignty and censorship resistance',
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Technical Information Section
        Text(
          'Technical Information',
          style: TextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Blockchain', 'Bitcoin'),
              const SizedBox(height: 12),
              _buildInfoRow('Consensus Mechanism', 'Proof of Work (SHA-256)'),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Tokenomics Section
        Text(
          'Tokenomics',
          style: TextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Max Supply', '21M BTC'),
              const SizedBox(height: 12),
              _buildInfoRow('Total Supply', '19.5M BTC'),
              const SizedBox(height: 12),
              _buildInfoRow('Inflation', 'Decreasing (halving every 4 years)'),
            ],
          ),
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, right: 12),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyles.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildNewsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Buttons
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All', true),
              const SizedBox(width: 8),
              _buildFilterChip('Bullish', false),
              const SizedBox(width: 8),
              _buildFilterChip('Bearish', false),
              const SizedBox(width: 8),
              _buildFilterChip('High', false),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // News Articles
        _buildNewsArticle(
          'Bitcoin ETF Sees Record Inflows',
          'CoinDesk',
          'Invalid Date',
          'Bitcoin spot ETFs recorded \$1.2B in net inflows this week, marking the strongest week since launch.',
          Icons.article,
        ),

        const SizedBox(height: 16),

        _buildNewsArticle(
          'Major Institution Adds BTC to Treasury',
          'Bloomberg Crypto',
          'Invalid Date',
          'Fortune 500 company announces \$500M Bitcoin purchase as part of treasury diversification strategy.',
          Icons.business,
        ),

        const SizedBox(height: 16),

        _buildNewsArticle(
          'Bitcoin Mining Difficulty Reaches New High',
          'CryptoQuant',
          'Invalid Date',
          'Network difficulty adjustment reflects growing hash rate and miner confidence.',
          Icons.trending_up,
        ),

        const SizedBox(height: 32),

        // Upcoming Events
        Text(
          'Upcoming Events',
          style: TextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),

        const SizedBox(height: 16),

        _buildEventCard(
          'Next Bitcoin Halving',
          'Apr 1, 2028',
          'halving',
          Colors.orange,
        ),

        const SizedBox(height: 12),

        _buildEventCard(
          'Bitcoin 2026 Conference',
          'May 1, 2026',
          'conference',
          Colors.blue,
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:
            isSelected
                ? const Color(0xFF7C3AED)
                : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isSelected
                  ? const Color(0xFF7C3AED)
                  : Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        label,
        style: TextStyles.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildNewsArticle(
    String title,
    String source,
    String date,
    String description,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      source,
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      ' â€¢ ',
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(
    String title,
    String date,
    String tag,
    Color tagColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: Colors.white.withValues(alpha: 0.7),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      date,
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: tagColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: TextStyles.bodySmall.copyWith(
                          color: tagColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Related Assets Title
        Row(
          children: [
            Icon(Icons.hub_outlined, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Related Assets',
              style: TextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Related Assets List
        _buildRelatedAssetCard(
          'Ethereum',
          'ETH',
          '\$3,420.5',
          '+3.8%',
          true,
          Colors.blue,
        ),

        const SizedBox(height: 12),

        _buildRelatedAssetCard(
          'Solana',
          'SOL',
          '\$145.3',
          '-2.1%',
          false,
          const Color(0xFF9945FF),
        ),

        const SizedBox(height: 12),

        _buildRelatedAssetCard(
          'Chainlink',
          'LINK',
          '\$15.84',
          '+4.2%',
          true,
          const Color(0xFF375BD2),
        ),

        const SizedBox(height: 24),

        // Info Note
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF7C3AED),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'These assets are frequently traded together or belong to the same sector, offering diversification opportunities.',
                  style: TextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildRelatedAssetCard(
    String name,
    String symbol,
    String price,
    String change,
    bool isPositive,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Crypto Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.currency_bitcoin, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          // Name and Symbol
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  symbol,
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Price and Change
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                change,
                style: TextStyles.bodySmall.copyWith(
                  color: isPositive ? const Color(0xFF10B981) : Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDepthContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Market Depth Title
        Row(
          children: [
            Icon(Icons.show_chart, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Market Depth',
              style: TextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Order Book
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buy Orders (Bids)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buy Orders (Bids)',
                    style: TextStyles.bodyMedium.copyWith(
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildOrderBookHeader(),
                  const SizedBox(height: 8),
                  ..._buildBuyOrders(),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Sell Orders (Asks)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sell Orders (Asks)',
                    style: TextStyles.bodyMedium.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildOrderBookHeader(),
                  const SizedBox(height: 8),
                  ..._buildSellOrders(),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Data Source Info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data Source:',
                style: TextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Order book data provided by liquidity partners.',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              Text(
                'Spread: \$128.50',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildOrderBookHeader() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            'Price',
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 10,
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Size',
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 10,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        Expanded(
          child: Text(
            'Total',
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 10,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBuyOrders() {
    final orders = [
      ['919.23', '0.010', '0.010'],
      ['919.23', '0.550', '0.550'],
      ['919.23', '0.010', '0.010'],
      ['919.16', '0.550', '0.550'],
      ['919.23', '0.010', '0.010'],
      ['919.16', '0.550', '0.550'],
      ['919.23', '0.010', '0.010'],
      ['919.16', '0.550', '0.550'],
      ['919.23', '0.010', '0.010'],
      ['919.16', '0.550', '0.550'],
      ['919.16', '0.550', '0.550'],
      ['919.23', '0.010', '0.010'],
      ['919.16', '0.550', '0.550'],
      ['919.23', '0.010', '0.010'],
      ['919.16', '0.550', '0.550'],
    ];

    return orders.map((order) => _buildOrderRow(order, true)).toList();
  }

  List<Widget> _buildSellOrders() {
    final orders = [
      ['919.23', '0.010', '0.010'],
      ['919.23', '0.550', '0.550'],
      ['919.23', '0.010', '0.010'],
      ['919.16', '0.550', '0.550'],
      ['919.23', '0.010', '0.010'],
      ['919.16', '0.550', '0.550'],
      ['919.23', '0.010', '0.010'],
      ['919.16', '0.550', '0.550'],
      ['919.23', '0.010', '0.010'],
      ['919.16', '0.550', '0.550'],
      ['919.16', '0.550', '0.550'],
      ['919.23', '0.010', '0.010'],
      ['919.16', '0.550', '0.550'],
      ['919.23', '0.010', '0.010'],
      ['919.16', '0.550', '0.550'],
    ];

    return orders.map((order) => _buildOrderRow(order, false)).toList();
  }

  Widget _buildOrderRow(List<String> order, bool isBuy) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              order[0],
              style: TextStyles.bodySmall.copyWith(
                color: isBuy ? const Color(0xFF10B981) : Colors.red,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              order[1],
              style: TextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Text(
              order[2],
              style: TextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class AdvancedChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw candlestick chart with volume bars
    final volumePaint = Paint()..style = PaintingStyle.fill;

    final linePaint =
        Paint()
          ..color = const Color(0xFF7C3AED)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    // Draw volume bars
    final barWidth = size.width / 25;
    for (int i = 0; i < 25; i++) {
      final height = (size.height * 0.3) * (0.3 + (i % 5) * 0.15);
      volumePaint.color = Colors.purple.withValues(alpha: 0.3);

      canvas.drawRect(
        Rect.fromLTWH(
          i * barWidth,
          size.height - height,
          barWidth * 0.8,
          height,
        ),
        volumePaint,
      );
    }

    // Draw price line
    final path = Path();
    path.moveTo(0, size.height * 0.5);

    for (int i = 0; i < 25; i++) {
      final x = i * (size.width / 24);
      final y = size.height * (0.3 + (i % 7) * 0.05);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BitcoinChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF10B981)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final fillPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF10B981).withValues(alpha: 0.3),
              const Color(0xFF10B981).withValues(alpha: 0.05),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    // Create a sample chart path
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.1, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.6),
      Offset(size.width * 0.3, size.height * 0.5),
      Offset(size.width * 0.4, size.height * 0.4),
      Offset(size.width * 0.5, size.height * 0.3),
      Offset(size.width * 0.6, size.height * 0.35),
      Offset(size.width * 0.7, size.height * 0.25),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.9, size.height * 0.15),
      Offset(size.width, size.height * 0.1),
    ];

    // Draw the line
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Create fill path
    fillPath.addPath(path, Offset.zero);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    // Draw fill and line
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
