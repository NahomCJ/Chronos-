import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import '../../../../core/widgets/fluid_glass.dart';
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

  // Each method: icon, title, subtitle, light gradient, dark gradient
  static const _methods = [
    _Method(Icons.people_alt_rounded, 'Contacts', 'Send to a contact',
        Color(0xFF60A5FA), Color(0xFF1D4ED8)),
    _Method(Icons.manage_accounts_rounded, 'Chronos User',
        'Username or QR', Color(0xFFA78BFA), Color(0xFF5B21B6)),
    _Method(Icons.account_balance_rounded, 'Bank Account',
        'Wire transfer', Color(0xFF34D399), Color(0xFF065F46)),
    _Method(Icons.public_rounded, 'International', 'Send abroad',
        Color(0xFFFBBF24), Color(0xFF92400E)),
  ];

  static const _recents = [
    _Recent('Alex',  'https://randomuser.me/api/portraits/men/32.jpg'),
    _Recent('Sarah', 'https://randomuser.me/api/portraits/women/44.jpg'),
    _Recent('Mike',  'https://randomuser.me/api/portraits/men/55.jpg'),
    _Recent('Emma',  'https://randomuser.me/api/portraits/women/68.jpg'),
    _Recent('Ben',   'https://randomuser.me/api/portraits/men/76.jpg'),
    _Recent('Julia', 'https://randomuser.me/api/portraits/women/12.jpg'),
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
      extendBody: true,
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
                  Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
          Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.45))),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 14),
                        _buildBalanceCard(),
                        const SizedBox(height: 18),
                        _buildGrid(),
                        const SizedBox(height: 18),
                        _buildRecentSection(),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: FluidGlass.dark(
        borderRadius: BorderRadius.circular(14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3)),
            const Spacer(),
            GestureDetector(
              onTap: _showQrSheet,
              child: _iconBtn(Icons.qr_code_2_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon) => ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
        ),
      );

  Widget _buildBalanceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FluidGlass.dark(
        borderRadius: BorderRadius.circular(16),
        blur: 20,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Available Balance',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 10)),
                const SizedBox(height: 3),
                const Text('\$12,430.50',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5)),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: const Color(0xFF14B8A6)
                        .withValues(alpha: 0.4)),
              ),
              child: const Text('USD',
                  style: TextStyle(
                      color: Color(0xFF14B8A6),
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.6,
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Recipients',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TransferContactsPage()),
                ),
                child: Text('See All',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 11)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 82,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _recents.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
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
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.25), width: 1.5),
            color: Colors.white.withValues(alpha: 0.06),
          ),
          child: Icon(Icons.add_rounded,
              color: Colors.white.withValues(alpha: 0.55), size: 16),
        ),
        const SizedBox(height: 4),
        Text('Add',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 9)),
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
  const _Recent(this.name, this.photoUrl);
  final String name;
  final String photoUrl;
}

// ─────────────────────────────────────────────────────────────────────────────
// Method card  distinct gradient tint per card
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
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.method.color.withValues(alpha: 0.18),
                    widget.method.dark.withValues(alpha: 0.10),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: widget.method.color.withValues(alpha: 0.28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          widget.method.color.withValues(alpha: 0.25),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(widget.method.icon,
                        color: const Color(0xFF0A0A14), size: 14),
                  ),
                  const Spacer(),
                  Text(widget.method.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2)),
                  const SizedBox(height: 1),
                  Text(widget.method.subtitle,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 9),
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
// Recent avatar  person icon instead of letter
// ─────────────────────────────────────────────────────────────────────────────

class _RecentAvatar extends StatelessWidget {
  const _RecentAvatar({required this.recent});
  final _Recent recent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            recent.photoUrl,
            width: 42,
            height: 54,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 42,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 22),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(recent.name,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 9)),
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
    return FluidGlass.dark(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      blur: 20,
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
          const SizedBox(height: 20),
          const Text('QR Code',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Show your code to receive or scan to send',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12),
              textAlign: TextAlign.center),
          const SizedBox(height: 22),
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
              const SizedBox(width: 12),
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 10),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
