import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import '../../../../core/router/route_constants.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';
import '../widgets/balance_card.dart';
import '../widgets/card_carousel.dart';
import '../widgets/card_actions.dart';
import '../widgets/recent_transactions.dart';
import '../widgets/features_section.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetIt.I<WalletBloc>()..add(const WalletSummaryRequested()),
      child: const _WalletView(),
    );
  }
}

class _WalletView extends StatelessWidget {
  const _WalletView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        final summary = state is WalletLoaded ? state.summary : null;
        final balance = summary?.totalBalance ?? 0.0;
        final transactions = summary?.recentTransactions ?? [];

        return Scaffold(
          backgroundColor: Colors.white,
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
              Positioned.fill(
                child: Image.asset('assets/background.png', fit: BoxFit.cover),
              ),
              Column(
                children: [
                  Container(
                    color: Colors.white,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.black),
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
                              icon: const Icon(Icons.settings_outlined,
                                  color: Colors.black),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: state is WalletLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                  color: Colors.white,
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(bottom: 32),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: BalanceCard(balance: balance),
                                      ),
                                      const SizedBox(height: 24),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Text(
                                          'Your Cards',
                                          style: TextStyles.titleMedium
                                              .copyWith(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const CardCarousel(),
                                    ],
                                  ),
                                ),
                                Container(
                                  color: Colors.transparent,
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      const CardActions(),
                                      const SizedBox(height: 24),
                                      RecentTransactions(
                                          transactions: transactions),
                                      const SizedBox(height: 24),
                                      const FeaturesSection(),
                                      const SizedBox(height: 120),
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
      },
    );
  }
}
