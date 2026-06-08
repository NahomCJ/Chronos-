import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import 'transfer_contacts_page.dart';
import 'transfer_chronos_user_page.dart';
import 'transfer_qr_page.dart';
import 'bank_transfer_page.dart';
import 'transfer_international_page.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<Animation<double>> _anims;

  static const _methods = [
    _Method(Icons.people_alt_rounded, 'Contacts', 'Send to a contact',
        Color(0xFF3B82F6), Color(0xFF1D4ED8)),
    _Method(Icons.manage_accounts_rounded, 'Chronos User',
        'Username or QR code', Color(0xFF8B5CF6), Color(0xFF6D28D9)),
    _Method(Icons.account_balance_rounded, 'Bank Account',
        'External bank transfer', Color(0xFF10B981), Color(0xFF059669)),
    _Method(Icons.public_rounded, 'International', 'Send abroad',
        Color(0xFFF59E0B), Color(0xFFD97706)),
  ];

  static const _recents = [
    _Recent('A', 'Alex', Color(0xFF3B82F6)),
    _Recent('S', 'Sarah', Color(0xFF8B5CF6)),
    _Recent('M', 'Mike', Color(0xFF10B981)),
    _Recent('E', 'Emma', Color(0xFFF59E0B)),
    _Recent('B', 'Ben', Color(0xFFEF4444)),
    _Recent('J', 'Julia', Color(0xFFEC4899)),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _anims = List.generate(
      _methods.length,
      (i) => CurvedAnimation(
        parent: _ctrl,
        curve: Interval(0.08 * i, 0.55 + 0.08 * i,
            curve: Curves.easeOutCubic),
      ),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _showQrSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _QrOptionsSheet(
        onReceive: () {
          Navigator.pop(context);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const TransferQrPage(initialTab: 0)));
        },
        onScan: () {
          Navigator.pop(context);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const TransferQrPage(initialTab: 1)));
        },
      ),
    );
  }

  void _onMethodTap(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TransferContactsPage()));
      case 1:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const TransferChronosUserPage()));
      case 2:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BankTransferPage()));
      case 3:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const TransferInternationalPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 90),
        child: const ChrisHomeFab(),
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: 0,
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
      body: Stack(
        children: [
          Positioned.fill(
              child:
                  Image.asset('assets/background.png', fit: BoxFit.cover)),
          Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.60))),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildBalanceCard(),
                const SizedBox(height: 28),
                _buildGrid(),
                const SizedBox(height: 28),
                _buildRecentSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.canPop()
                ? context.pop()
                : context.go(RouteConstants.home.toPath),
            child: _iconBtn(Icons.arrow_back_rounded),
          ),
          const Spacer(),
          const Text('Send Money',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3)),
          const Spacer(),
          GestureDetector(
            onTap: _showQrSheet,
            child: _iconBtn(Icons.qr_code_2_rounded),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon) => ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
      );

  Widget _buildBalanceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.12),
                  Colors.white.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Available Balance',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 12)),
                    const SizedBox(height: 4),
                    const Text('\$12,430.50',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5)),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14B8A6).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF14B8A6)
                            .withValues(alpha: 0.4)),
                  ),
                  child: const Text('USD',
                      style: TextStyle(
                          color: Color(0xFF14B8A6),
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.45,
        children: List.generate(_methods.length, (i) {
          final m = _methods[i];
          return FadeTransition(
            opacity: _anims[i],
            child: SlideTransition(
              position: _anims[i].drive(
                  Tween(begin: const Offset(0, 0.18), end: Offset.zero)),
              child: _MethodCard(method: m, onTap: () => _onMethodTap(i)),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRecentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Recipients',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              Text('See All',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 78,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _recents.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, i) {
              if (i == _recents.length) return _addNewBtn();
              return _RecentAvatar(recent: _recents[i]);
            },
          ),
        ),
      ],
    );
  }

  Widget _addNewBtn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.25), width: 1.5),
            color: Colors.white.withValues(alpha: 0.06),
          ),
          child: Icon(Icons.add_rounded,
              color: Colors.white.withValues(alpha: 0.55), size: 20),
        ),
        const SizedBox(height: 6),
        Text('Add',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 11)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data classes
// ─────────────────────────────────────────────────────────────────────────────

class _Method {
  const _Method(
      this.icon, this.title, this.subtitle, this.color, this.dark);
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color dark;
}

class _Recent {
  const _Recent(this.initial, this.name, this.color);
  final String initial;
  final String name;
  final Color color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Method card
// ─────────────────────────────────────────────────────────────────────────────

class _MethodCard extends StatefulWidget {
  const _MethodCard({required this.method, required this.onTap});
  final _Method method;
  final VoidCallback onTap;

  @override
  State<_MethodCard> createState() => _MethodCardState();
}

class _MethodCardState extends State<_MethodCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.11),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        widget.method.color,
                        widget.method.dark,
                      ]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.method.icon,
                        color: Colors.white, size: 18),
                  ),
                  const Spacer(),
                  Text(widget.method.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2)),
                  const SizedBox(height: 2),
                  Text(widget.method.subtitle,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent avatar
// ─────────────────────────────────────────────────────────────────────────────

class _RecentAvatar extends StatelessWidget {
  const _RecentAvatar({required this.recent});
  final _Recent recent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [recent.color, recent.color.withValues(alpha: 0.6)],
            ),
          ),
          child: Center(
            child: Text(recent.initial,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 6),
        Text(recent.name,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 11)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QR options bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _QrOptionsSheet extends StatelessWidget {
  const _QrOptionsSheet(
      {required this.onReceive, required this.onScan});
  final VoidCallback onReceive;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1E),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
            top: BorderSide(
                color: Colors.white.withValues(alpha: 0.08), width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          const Text('QR Code',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Show your code to receive or scan to send',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13),
              textAlign: TextAlign.center),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _QrTile(
                  icon: Icons.qr_code_2_rounded,
                  label: 'My QR Code',
                  subtitle: 'Let others scan you',
                  color: const Color(0xFF14B8A6),
                  onTap: onReceive,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _QrTile(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Scan QR',
                  subtitle: "Scan someone's code",
                  color: const Color(0xFF8B5CF6),
                  onTap: onScan,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QrTile extends StatelessWidget {
  const _QrTile(
      {required this.icon,
      required this.label,
      required this.subtitle,
      required this.color,
      required this.onTap});
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 34),
            const SizedBox(height: 10),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(subtitle,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 11),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
