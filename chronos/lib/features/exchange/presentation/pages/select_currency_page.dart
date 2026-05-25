import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/text_theme.dart';

class SelectCurrencyPage extends StatefulWidget {
  final String currentCurrency;
  final bool isFromCurrency;

  const SelectCurrencyPage({
    super.key,
    required this.currentCurrency,
    this.isFromCurrency = true,
  });

  @override
  State<SelectCurrencyPage> createState() => _SelectCurrencyPageState();
}

class _SelectCurrencyPageState extends State<SelectCurrencyPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sample currency data
  final List<CurrencyModel> _favoriteCurrencies = [
    CurrencyModel(
      code: 'USD',
      name: 'US Dollar',
      flag: '🇺🇸',
      balance: '12,450',
      isFavorite: true,
    ),
    CurrencyModel(
      code: 'EUR',
      name: 'Euro',
      flag: '🇪🇺',
      balance: '8,320.5',
      isFavorite: true,
    ),
    CurrencyModel(
      code: 'GBP',
      name: 'British Pound',
      flag: '🇬🇧',
      balance: '5,100.75',
      isFavorite: true,
    ),
  ];

  final List<CurrencyModel> _fiatCurrencies = [
    CurrencyModel(
      code: 'JPY',
      name: 'Japanese Yen',
      flag: '🇯🇵',
      balance: '250,000',
    ),
    CurrencyModel(
      code: 'CHF',
      name: 'Swiss Franc',
      flag: '🇨🇭',
      balance: '3,200',
    ),
    CurrencyModel(
      code: 'AUD',
      name: 'Australian Dollar',
      flag: '🇦🇺',
      balance: '3,200',
    ),
    CurrencyModel(
      code: 'CAD',
      name: 'Canadian Dollar',
      flag: '🇨🇦',
      balance: '3,200',
    ),
    CurrencyModel(
      code: 'SGD',
      name: 'Singapore Dollar',
      flag: '🇸🇬',
      balance: '2,800.5',
    ),
  ];

  List<CurrencyModel> get _filteredFavorites {
    if (_searchQuery.isEmpty) return _favoriteCurrencies;
    return _favoriteCurrencies
        .where(
          (currency) =>
              currency.code.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              currency.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  List<CurrencyModel> get _filteredFiatCurrencies {
    if (_searchQuery.isEmpty) return _fiatCurrencies;
    return _fiatCurrencies
        .where(
          (currency) =>
              currency.code.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              currency.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;
    final horizontalPadding = isSmallScreen ? 16.0 : 20.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),

          // Dark Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.7)),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Select Currency',
                        style: TextStyles.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: isSmallScreen ? 20 : 24,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Container(
                  margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    style: TextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search Currencies',
                      hintStyle: TextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withValues(alpha: 0.6),
                        size: isSmallScreen ? 18 : 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: isSmallScreen ? 20 : 24),

                // Content List
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Favorites Section
                        if (_filteredFavorites.isNotEmpty) ...[
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                  size: isSmallScreen ? 18 : 20,
                                ),
                                SizedBox(width: isSmallScreen ? 6 : 8),
                                Text(
                                  'Favorites',
                                  style: TextStyles.titleMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: isSmallScreen ? 16 : 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          ..._filteredFavorites.map(
                            (currency) => _buildCurrencyTile(
                              currency,
                              isSmallScreen,
                              horizontalPadding,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 20 : 24),
                        ],

                        // Fiat Currencies Section
                        if (_filteredFiatCurrencies.isNotEmpty) ...[
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                            ),
                            child: Text(
                              'Fiat Currencies',
                              style: TextStyles.titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 16 : 18,
                              ),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          ..._filteredFiatCurrencies.map(
                            (currency) => _buildCurrencyTile(
                              currency,
                              isSmallScreen,
                              horizontalPadding,
                            ),
                          ),
                        ],

                        // Bottom padding for navigation
                        const SizedBox(height: 100),
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

  Widget _buildCurrencyTile(
    CurrencyModel currency,
    bool isSmallScreen,
    double horizontalPadding,
  ) {
    final isSelected = currency.code == widget.currentCurrency;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isSmallScreen ? 3 : 4,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Return selected currency
            context.pop({
              'currency': currency.code,
              'name': currency.name,
              'flag': currency.flag,
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isSelected
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                // Flag
                Container(
                  width: isSmallScreen ? 36 : 40,
                  height: isSmallScreen ? 24 : 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      currency.flag,
                      style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),

                // Currency Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            currency.code,
                            style: TextStyles.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 16 : 18,
                            ),
                          ),
                          if (currency.isFavorite) ...[
                            SizedBox(width: isSmallScreen ? 6 : 8),
                            Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: isSmallScreen ? 14 : 16,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currency.name,
                        style: TextStyles.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Balance
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currency.balance,
                      style: TextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 15 : 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Available',
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: isSmallScreen ? 10 : 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CurrencyModel {
  final String code;
  final String name;
  final String flag;
  final String balance;
  final bool isFavorite;

  CurrencyModel({
    required this.code,
    required this.name,
    required this.flag,
    required this.balance,
    this.isFavorite = false,
  });
}
