import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import '../../domain/entities/unit_banking_entities.dart';
import '../bloc/unit_banking_bloc.dart';
import '../bloc/unit_banking_event.dart';
import '../bloc/unit_banking_state.dart';

class UnitBankingPage extends StatelessWidget {
  const UnitBankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetIt.I<UnitBankingBloc>()..add(const UnitBankingLoadRequested()),
      child: const _UnitBankingView(),
    );
  }
}

class _UnitBankingView extends StatelessWidget {
  const _UnitBankingView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UnitBankingBloc, UnitBankingState>(
      listener: (context, state) {
        if (state is UnitBankingActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is UnitBankingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final summary = switch (state) {
          UnitBankingLoaded s => s.summary,
          UnitBankingActionSuccess s => s.summary,
          _ => null,
        };
        final isLoading = state is UnitBankingLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: CustomBottomNav(
            selectedIndex: 4,
            onItemSelected: (i) {
              switch (i) {
                case 0:
                  context.go(RouteConstants.home.toPath);
                case 1:
                  context.go(RouteConstants.pantherAi.toPath);
                case 2:
                  context.go(RouteConstants.blockHub.toPath);
              }
            },
          ),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : summary == null
                          ? _buildEmpty(context)
                          : _buildContent(context, summary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(RouteConstants.wallet.toPath),
          ),
          Expanded(
            child: Text(
              'Unit Banking',
              textAlign: TextAlign.center,
              style: TextStyles.headlineSmall.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () => context
                .read<UnitBankingBloc>()
                .add(const UnitBankingLoadRequested()),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_outlined,
                size: 72, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No Unit accounts yet',
              style: TextStyles.titleMedium.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a Unit banking account to get started',
              textAlign: TextAlign.center,
              style: TextStyles.bodyMedium.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => context
                  .read<UnitBankingBloc>()
                  .add(const UnitBankingCreateAccount()),
              child: const Text('Open Account'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, UnitBankingSummary summary) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<UnitBankingBloc>().add(const UnitBankingLoadRequested());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(summary),
            const SizedBox(height: 24),
            _buildAccountsSection(context, summary.accounts),
            const SizedBox(height: 24),
            _buildCardsSection(context, summary.cards),
            const SizedBox(height: 24),
            _buildTransfersSection(summary.transfers),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(UnitBankingSummary summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Balance',
              style: TextStyles.bodyMedium.copyWith(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            '\$${summary.totalBalance.toStringAsFixed(2)}',
            style: TextStyles.headlineLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${summary.accounts.length} account${summary.accounts.length == 1 ? '' : 's'} · ${summary.cards.length} card${summary.cards.length == 1 ? '' : 's'}',
            style: TextStyles.bodySmall.copyWith(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsSection(
      BuildContext context, List<UnitAccountEntity> accounts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Accounts',
                style: TextStyles.titleMedium.copyWith(
                    color: Colors.black, fontWeight: FontWeight.w600)),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('New'),
              onPressed: () => context
                  .read<UnitBankingBloc>()
                  .add(const UnitBankingCreateAccount()),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (accounts.isEmpty)
          _buildEmptyCard('No accounts yet. Tap + New to open one.')
        else
          ...accounts.map((a) => _buildAccountTile(a)),
      ],
    );
  }

  Widget _buildAccountTile(UnitAccountEntity account) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(Icons.account_balance, color: Colors.blue.shade700, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.accountNumber != null
                      ? '****${account.accountNumber!.substring(account.accountNumber!.length - 4)}'
                      : account.unitAccountId.substring(0, 8),
                  style: TextStyles.bodyMedium.copyWith(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
                if (account.routingNumber != null)
                  Text('Routing: ${account.routingNumber}',
                      style:
                          TextStyles.bodySmall.copyWith(color: Colors.black54)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${account.balance.toStringAsFixed(2)}',
                  style: TextStyles.bodyMedium.copyWith(
                      color: Colors.black, fontWeight: FontWeight.w600)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: account.isActive
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  account.status,
                  style: TextStyles.bodySmall.copyWith(
                      color: account.isActive
                          ? Colors.green.shade700
                          : Colors.red.shade700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardsSection(
      BuildContext context, List<UnitCardEntity> cards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cards',
            style: TextStyles.titleMedium
                .copyWith(color: Colors.black, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (cards.isEmpty)
          _buildEmptyCard('No cards linked to this account yet.')
        else
          ...cards.map((c) => _buildCardTile(context, c)),
      ],
    );
  }

  Widget _buildCardTile(BuildContext context, UnitCardEntity card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: card.isFrozen ? Colors.blue.shade50 : Colors.purple.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              card.isVirtual ? Icons.credit_card : Icons.credit_card_outlined,
              color: card.isFrozen ? Colors.blue.shade700 : Colors.purple.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('**** **** **** ${card.last4}',
                    style: TextStyles.bodyMedium.copyWith(
                        color: Colors.black, fontWeight: FontWeight.w600)),
                Text('${card.type} · ${card.status}',
                    style: TextStyles.bodySmall.copyWith(color: Colors.black54)),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              if (card.isFrozen) {
                context
                    .read<UnitBankingBloc>()
                    .add(UnitBankingUnfreezeCard(card.unitCardId));
              } else {
                context
                    .read<UnitBankingBloc>()
                    .add(UnitBankingFreezeCard(card.unitCardId));
              }
            },
            child: Text(card.isFrozen ? 'Unfreeze' : 'Freeze',
                style: TextStyle(
                    color: card.isFrozen ? Colors.green : Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildTransfersSection(List<UnitTransferEntity> transfers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Transfers',
            style: TextStyles.titleMedium
                .copyWith(color: Colors.black, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (transfers.isEmpty)
          _buildEmptyCard('No transfers yet.')
        else
          ...transfers.take(5).map((t) => _buildTransferTile(t)),
      ],
    );
  }

  Widget _buildTransferTile(UnitTransferEntity transfer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.swap_horiz, color: Colors.orange.shade700, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transfer.unitTransferId.length > 12
                      ? '${transfer.unitTransferId.substring(0, 12)}...'
                      : transfer.unitTransferId,
                  style: TextStyles.bodySmall.copyWith(color: Colors.black54),
                ),
                Text(transfer.status,
                    style: TextStyles.bodySmall.copyWith(color: Colors.black54)),
              ],
            ),
          ),
          Text('\$${transfer.amount.toStringAsFixed(2)}',
              style: TextStyles.bodyMedium
                  .copyWith(color: Colors.black, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyles.bodySmall.copyWith(color: Colors.black45),
      ),
    );
  }
}
