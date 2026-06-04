import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../features/auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth/auth_event.dart';
import '../../../../features/auth/presentation/bloc/auth/auth_state.dart';
import '../../../../core/di/app_di.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';
import '../../data/datasources/profile_remote_datasource.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _kDark = Color(0xFF0A0A14);
  static const _kPurple = Color(0xFF6C5CE7);
  static const _kGold = Color(0xFFDC8F4A);

  // Notification prefs (persisted in SharedPreferences)
  bool _pushTransactions = true;
  bool _pushPayments = true;
  bool _pushAiAlerts = true;
  bool _pushTickPay = true;
  bool _marketingEmails = false;

  // Security prefs
  bool _biometricsEnabled = false;
  bool _twoFactorEnabled = true;

  // App prefs
  String _appearance = 'dark';
  String _language = 'English';
  String _currency = 'USD';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _pushTransactions = p.getBool('notif_transactions') ?? true;
      _pushPayments = p.getBool('notif_payments') ?? true;
      _pushAiAlerts = p.getBool('notif_ai') ?? true;
      _pushTickPay = p.getBool('notif_tickpay') ?? true;
      _marketingEmails = p.getBool('notif_marketing') ?? false;
      _biometricsEnabled = p.getBool('sec_biometrics') ?? false;
      _twoFactorEnabled = p.getBool('sec_2fa') ?? true;
      _appearance = p.getString('pref_appearance') ?? 'dark';
      _language = p.getString('pref_language') ?? 'English';
      _currency = p.getString('pref_currency') ?? 'USD';
    });
  }

  Future<void> _savePref(String key, dynamic value) async {
    final p = await SharedPreferences.getInstance();
    if (value is bool) await p.setBool(key, value);
    if (value is String) await p.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded && state.updateSuccess != null) {
          _showSnack(context, state.updateSuccess!, _kPurple);
        }
        if (state is ProfileLoaded && state.updateError != null) {
          _showSnack(context, state.updateError!, Colors.redAccent);
        }
      },
      builder: (context, state) {
        final loaded = state is ProfileLoaded ? state : null;
        return BlocListener<AuthBloc, AuthState>(
          listener: (context, authState) {
            if (authState is AuthUnauthenticated) {
              context.go(RouteConstants.signIn.toPath);
            }
          },
          child: Scaffold(
            backgroundColor: _kDark,
            body: Stack(
              children: [
                Positioned(
                  top: -80,
                  left: -80,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        _kPurple.withValues(alpha: 0.12),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(context, loaded),
                      Expanded(
                        child: state is ProfileLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: _kPurple))
                            : state is ProfileError
                                ? _buildError(context, state.message)
                                : _buildBody(context, loaded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.white.withValues(alpha: 0.4), size: 48),
          const SizedBox(height: 16),
          Text(message,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.read<ProfileCubit>().loadProfile(),
            child: const Text('Retry', style: TextStyle(color: _kPurple)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProfileLoaded? loaded) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildAvatarSection(loaded),
          const SizedBox(height: 28),
          _buildSection('Account', _accountTiles(context, loaded)),
          const SizedBox(height: 20),
          _buildSection('Security', _securityTiles(context)),
          const SizedBox(height: 20),
          _buildSection('Notifications', _notificationTiles()),
          const SizedBox(height: 20),
          _buildSection('Verification', _verificationTiles(context, loaded)),
          const SizedBox(height: 20),
          _buildSection('Membership', _membershipTiles(context, loaded)),
          const SizedBox(height: 20),
          _buildSection('TickPay', _tickPayTiles(context)),
          const SizedBox(height: 20),
          _buildSection('Referral', _referralTiles(context, loaded)),
          const SizedBox(height: 20),
          _buildSection('App Preferences', _appPrefTiles(context)),
          const SizedBox(height: 20),
          _buildSection('Data & Privacy', _dataTiles(context)),
          const SizedBox(height: 20),
          _buildDangerZone(context),
          const SizedBox(height: 24),
          _buildSignOutButton(context),
          const SizedBox(height: 12),
          Text(
            'Chronos v1.0.0',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.2), fontSize: 12),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, ProfileLoaded? loaded) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12), width: 0.8),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Profile & Settings',
            style: TextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: loaded != null
                ? () => _showEditProfileSheet(context, loaded.user)
                : null,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _kPurple.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _kPurple.withValues(alpha: 0.3), width: 0.8),
              ),
              child: Text(
                'Edit',
                style: TextStyle(
                  color: loaded != null ? _kPurple : Colors.white.withValues(alpha: 0.3),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Avatar ───────────────────────────────────────────────────────────────────

  Widget _buildAvatarSection(ProfileLoaded? loaded) {
    final initials = loaded?.user.initials ?? '??';
    final name = loaded?.user.fullName ?? 'Loading...';
    final tier = _tierLabel(loaded?.user.tier ?? 'standard');
    final balance = loaded?.user.balance ?? 0.0;
    final txCount = loaded?.user.transactionCount ?? 0;
    final since = loaded?.user.memberSince;
    final sinceStr = since != null
        ? '${_monthName(since.month)} ${since.year}'
        : '---';

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_kPurple, Color(0xFF2D3561)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _kPurple.withValues(alpha: 0.35),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showComingSoon(context, 'Photo Upload'),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kPurple,
                    border: Border.all(color: _kDark, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Colors.white, size: 13),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          name,
          style: TextStyles.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: _kGold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: _kGold.withValues(alpha: 0.3), width: 0.7),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.workspace_premium_rounded,
                  color: _kGold, size: 12),
              const SizedBox(width: 4),
              Text(
                tier,
                style: const TextStyle(
                    color: _kGold, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildStatsRow(
          balance: '\$${balance.toStringAsFixed(2)}',
          txCount: txCount.toString(),
          since: sinceStr,
        ),
      ],
    );
  }

  Widget _buildStatsRow(
      {required String balance,
      required String txCount,
      required String since}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.10), width: 0.7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem('Balance', balance),
              _vDivider(),
              _statItem('Transactions', txCount),
              _vDivider(),
              _statItem('Since', since),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45), fontSize: 11)),
      ],
    );
  }

  Widget _vDivider() => Container(
      width: 0.6, height: 32, color: Colors.white.withValues(alpha: 0.12));

  // ── Sections ──────────────────────────────────────────────────────────────────

  Widget _buildSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.38),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10), width: 0.7),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < tiles.length; i++) ...[
                    tiles[i],
                    if (i < tiles.length - 1)
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          height: 0.5,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Tile builders ─────────────────────────────────────────────────────────────

  Widget _infoTile(IconData icon, String label, String value,
      {Widget? trailing, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _iconBox(icon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 11)),
                  if (value.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(value,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.25), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _toggleTile(IconData icon, String label, String subtitle, bool value,
      ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _iconBox(icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11)),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.82,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: _kPurple,
              activeTrackColor: _kPurple.withValues(alpha: 0.3),
              inactiveThumbColor: Colors.white.withValues(alpha: 0.5),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon) => Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: _kPurple.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _kPurple, size: 18),
      );

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 0.7),
        ),
        child: Text(text,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );

  // ── Section tile lists ────────────────────────────────────────────────────────

  List<Widget> _accountTiles(
      BuildContext context, ProfileLoaded? loaded) {
    final u = loaded?.user;
    return [
      _infoTile(Icons.person_outline_rounded, 'Full Name',
          u?.fullName ?? '---',
          onTap: loaded != null
              ? () => _showEditProfileSheet(context, u!)
              : null),
      _infoTile(Icons.email_outlined, 'Email', u?.email ?? '---',
          onTap: () => _showComingSoon(context, 'Email change')),
      _infoTile(Icons.phone_outlined, 'Phone', u?.phone ?? 'Not set',
          onTap: loaded != null
              ? () => _showEditField(context, 'Phone', u?.phone ?? '',
                  (v) => context
                      .read<ProfileCubit>()
                      .updateProfile(phone: v))
              : null),
      _infoTile(Icons.location_on_outlined, 'Country', 'Ethiopia',
          onTap: () => _showComingSoon(context, 'Country')),
    ];
  }

  List<Widget> _securityTiles(BuildContext context) {
    return [
      _infoTile(Icons.lock_outline_rounded, 'Change PIN', '••••••',
          onTap: () => _showPinChangeSheet(context)),
      _infoTile(Icons.password_rounded, 'Change Password',
          'Update your password',
          onTap: () =>
              context.push(RouteConstants.forgotPassword.toPath)),
      _toggleTile(Icons.fingerprint_rounded, 'Biometric Login',
          'Face ID / Fingerprint', _biometricsEnabled, (v) {
        setState(() => _biometricsEnabled = v);
        _savePref('sec_biometrics', v);
      }),
      _toggleTile(Icons.verified_user_outlined, 'Two-Factor Auth',
          'SMS code on every login', _twoFactorEnabled, (v) {
        setState(() => _twoFactorEnabled = v);
        _savePref('sec_2fa', v);
      }),
      _infoTile(Icons.devices_rounded, 'Active Sessions',
          'Manage logged-in devices',
          onTap: () => _showSessionsSheet(context)),
    ];
  }

  List<Widget> _notificationTiles() {
    return [
      _toggleTile(Icons.swap_horiz_rounded, 'Transaction Alerts',
          'Every deposit & withdrawal', _pushTransactions, (v) {
        setState(() => _pushTransactions = v);
        _savePref('notif_transactions', v);
      }),
      _toggleTile(Icons.calendar_today_outlined, 'Payment Due',
          'Upcoming TickPay installments', _pushPayments, (v) {
        setState(() => _pushPayments = v);
        _savePref('notif_payments', v);
      }),
      _toggleTile(Icons.psychology_outlined, 'AI Insights',
          'Panther AI alerts & tips', _pushAiAlerts, (v) {
        setState(() => _pushAiAlerts = v);
        _savePref('notif_ai', v);
      }),
      _toggleTile(Icons.shopping_bag_outlined, 'TickPay Alerts',
          'BNPL reminders & offers', _pushTickPay, (v) {
        setState(() => _pushTickPay = v);
        _savePref('notif_tickpay', v);
      }),
      _toggleTile(Icons.mark_email_unread_outlined, 'Marketing Emails',
          'Offers, tips, promotions', _marketingEmails, (v) {
        setState(() => _marketingEmails = v);
        _savePref('notif_marketing', v);
      }),
    ];
  }

  List<Widget> _verificationTiles(
      BuildContext context, ProfileLoaded? loaded) {
    final kycColor = const Color(0xFF10B981);
    return [
      _infoTile(Icons.badge_outlined, 'KYC Status', 'Verified',
          trailing: _badge('Verified', kycColor),
          onTap: () => _showComingSoon(context, 'KYC Details')),
      _infoTile(Icons.account_balance_outlined, 'Linked Banks',
          '3 accounts connected',
          onTap: () => _showComingSoon(context, 'Linked Banks')),
      _infoTile(Icons.credit_score_rounded, 'Identity Documents',
          'ID verified',
          onTap: () => _showComingSoon(context, 'Identity Documents')),
    ];
  }

  List<Widget> _membershipTiles(
      BuildContext context, ProfileLoaded? loaded) {
    final tier = loaded?.user.tier ?? 'standard';
    final tierLabel = _tierLabel(tier);
    final since = loaded?.user.memberSince;
    final sinceStr = since != null
        ? '${_monthName(since.month)} ${since.year}'
        : '---';
    return [
      _infoTile(Icons.workspace_premium_rounded, 'Current Tier',
          tierLabel,
          trailing: _badge(tierLabel, _kGold)),
      _infoTile(Icons.calendar_month_outlined, 'Member Since', sinceStr),
      _infoTile(Icons.rocket_launch_outlined, 'Upgrade Plan',
          'Unlock premium features',
          onTap: () => _showComingSoon(context, 'Upgrade Plan')),
    ];
  }

  List<Widget> _tickPayTiles(BuildContext context) {
    return [
      _infoTile(Icons.credit_card_outlined, 'TickPay Credit',
          'View your credit line',
          onTap: () =>
              context.push(RouteConstants.tickpayDashboard.toPath)),
      _toggleTile(Icons.autorenew_rounded, 'Auto-Pay',
          'Auto-deduct on due dates', false, (v) {
        _showComingSoon(context, 'Auto-Pay setup');
      }),
    ];
  }

  List<Widget> _referralTiles(
      BuildContext context, ProfileLoaded? loaded) {
    final code = loaded != null
        ? 'CHR-${loaded.user.id.substring(0, 6).toUpperCase()}'
        : 'CHR-XXXXXX';
    return [
      _infoTile(Icons.card_giftcard_rounded, 'Referral Code', code,
          trailing: GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: code));
              _showSnack(context, 'Copied to clipboard!', _kPurple);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _kPurple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Copy',
                  style: TextStyle(
                      color: _kPurple,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          )),
      _infoTile(Icons.share_rounded, 'Invite Friends',
          'Share your code & earn rewards',
          onTap: () => _showComingSoon(context, 'Referral sharing')),
      _infoTile(Icons.monetization_on_outlined, 'Referral Earnings',
          '\$0.00',
          onTap: () => _showComingSoon(context, 'Referral earnings')),
    ];
  }

  List<Widget> _appPrefTiles(BuildContext context) {
    return [
      _infoTile(Icons.palette_outlined, 'Appearance', _appearanceLabel(),
          onTap: () => _showAppearancePicker(context)),
      _infoTile(Icons.language_rounded, 'Language', _language,
          onTap: () => _showComingSoon(context, 'Language')),
      _infoTile(Icons.currency_exchange_rounded, 'Display Currency',
          _currency,
          onTap: () => _showCurrencyPicker(context)),
    ];
  }

  List<Widget> _dataTiles(BuildContext context) {
    return [
      _infoTile(Icons.download_outlined, 'Export Transactions',
          'Download CSV or PDF',
          onTap: () => _showComingSoon(context, 'Export')),
      _infoTile(Icons.privacy_tip_outlined, 'Privacy Policy', '',
          onTap: () => _showComingSoon(context, 'Privacy Policy')),
      _infoTile(Icons.gavel_rounded, 'Terms of Service', '',
          onTap: () => _showComingSoon(context, 'Terms of Service')),
      _infoTile(Icons.help_outline_rounded, 'Help & Support',
          'FAQs, contact us',
          onTap: () => _showSupportSheet(context)),
    ];
  }

  // ── Danger zone ───────────────────────────────────────────────────────────────

  Widget _buildDangerZone(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'DANGER ZONE',
            style: TextStyle(
              color: Colors.red.withValues(alpha: 0.6),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Colors.red.withValues(alpha: 0.15), width: 0.7),
              ),
              child: _infoTile(
                Icons.delete_forever_rounded,
                'Delete Account',
                'Permanently remove your data',
                trailing: Icon(Icons.chevron_right_rounded,
                    color: Colors.red.withValues(alpha: 0.5), size: 20),
                onTap: () => _confirmDeleteAccount(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────────

  Widget _buildSignOutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmSignOut(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: Colors.red.withValues(alpha: 0.25), width: 0.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded,
                color: Colors.red.withValues(alpha: 0.8), size: 18),
            const SizedBox(width: 10),
            Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.red.withValues(alpha: 0.8),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sheets / Dialogs ──────────────────────────────────────────────────────────

  void _showEditProfileSheet(BuildContext context, UserProfileModel user) {
    final firstCtrl = TextEditingController(text: user.firstName);
    final lastCtrl = TextEditingController(text: user.lastName);
    final cubit = context.read<ProfileCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141420),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Edit Profile',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _sheetField('First Name', firstCtrl),
            const SizedBox(height: 14),
            _sheetField('Last Name', lastCtrl),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  cubit.updateProfile(
                    firstName: firstCtrl.text.trim(),
                    lastName: lastCtrl.text.trim(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Save Changes',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditField(BuildContext context, String label, String current,
      Function(String) onSave) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141420),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Edit $label',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
        content: _sheetField(label, ctrl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onSave(ctrl.text.trim());
            },
            child: const Text('Save',
                style: TextStyle(
                    color: _kPurple, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showPinChangeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141420),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            const Text('Change PIN',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Enter your current PIN then set a new one.',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13)),
            const SizedBox(height: 24),
            _pinRow('Current PIN'),
            const SizedBox(height: 14),
            _pinRow('New PIN'),
            const SizedBox(height: 14),
            _pinRow('Confirm New PIN'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showComingSoon(context, 'PIN change');
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: _kPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
                child: const Text('Update PIN',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showSessionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141420),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            const Text('Active Sessions',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _sessionTile('Current Device', 'iPhone 15 · Now', true),
            const SizedBox(height: 10),
            _sessionTile('Android · Chrome', '2 days ago', false),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                _showComingSoon(context, 'Sign out all devices');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded,
                        color: Colors.red.withValues(alpha: 0.8),
                        size: 16),
                    const SizedBox(width: 8),
                    Text('Sign out all other devices',
                        style: TextStyle(
                            color: Colors.red.withValues(alpha: 0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppearancePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141420),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 20),
              const Text('Appearance',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              for (final option in [
                ('dark', 'Dark', Icons.dark_mode_rounded),
                ('light', 'Light', Icons.light_mode_rounded),
                ('system', 'System Default', Icons.settings_brightness_rounded),
              ])
                GestureDetector(
                  onTap: () {
                    setS(() {});
                    setState(() => _appearance = option.$1);
                    _savePref('pref_appearance', option.$1);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: _appearance == option.$1
                          ? _kPurple.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _appearance == option.$1
                              ? _kPurple.withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(option.$3, color: _kPurple, size: 20),
                        const SizedBox(width: 12),
                        Text(option.$2,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                        const Spacer(),
                        if (_appearance == option.$1)
                          const Icon(Icons.check_circle_rounded,
                              color: _kPurple, size: 20),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    final currencies = ['USD', 'EUR', 'GBP', 'ETB', 'CAD', 'AUD'];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141420),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            const Text('Display Currency',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: currencies
                  .map((c) => GestureDetector(
                        onTap: () {
                          setState(() => _currency = c);
                          _savePref('pref_currency', c);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: _currency == c
                                ? _kPurple.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: _currency == c
                                    ? _kPurple
                                    : Colors.white
                                        .withValues(alpha: 0.12)),
                          ),
                          child: Text(c,
                              style: TextStyle(
                                  color: _currency == c
                                      ? _kPurple
                                      : Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showSupportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141420),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            const Text('Help & Support',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _supportOption(ctx, Icons.chat_bubble_outline_rounded,
                'Live Chat', 'Chat with our support team'),
            const SizedBox(height: 10),
            _supportOption(ctx, Icons.email_outlined, 'Email Us',
                'support@chronos.app'),
            const SizedBox(height: 10),
            _supportOption(ctx, Icons.quiz_outlined, 'FAQ',
                'Browse common questions'),
            const SizedBox(height: 10),
            _supportOption(ctx, Icons.bug_report_outlined,
                'Report a Problem', 'Let us know what went wrong'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141420),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Sign out?',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
        content: Text(
          'You will need to sign in again to access your account.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const SignOutRequested());
            },
            child: const Text('Sign out',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141420),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete Account?',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
        content: Text(
          'This will permanently remove all your data including transactions, wallets, and TickPay history. This cannot be undone.',
          style:
              TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showComingSoon(context, 'Account deletion');
            },
            child: const Text('Delete',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── Helper widgets ────────────────────────────────────────────────────────────

  Widget _sheetField(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kPurple),
        ),
      ),
    );
  }

  Widget _pinRow(String label) {
    return TextField(
      obscureText: true,
      maxLength: 6,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white, letterSpacing: 8),
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        labelStyle:
            TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kPurple),
        ),
      ),
    );
  }

  Widget _sessionTile(String device, String time, bool isCurrent) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrent
            ? _kPurple.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isCurrent
                ? _kPurple.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(
              isCurrent
                  ? Icons.phone_iphone_rounded
                  : Icons.laptop_rounded,
              color: isCurrent ? _kPurple : Colors.white.withValues(alpha: 0.5),
              size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                Text(time,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11)),
              ],
            ),
          ),
          if (isCurrent)
            _badge('Current', const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _supportOption(
      BuildContext ctx, IconData icon, String title, String subtitle) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(ctx);
        _showComingSoon(context, title);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _kPurple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _kPurple, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white.withValues(alpha: 0.25), size: 14),
          ],
        ),
      ),
    );
  }

  // ── Utility ───────────────────────────────────────────────────────────────────

  void _showComingSoon(BuildContext context, String feature) {
    _showSnack(context, '$feature — coming soon', const Color(0xFF1A1A2E));
  }

  void _showSnack(BuildContext context, String message, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  String _tierLabel(String tier) {
    switch (tier.toLowerCase()) {
      case 'gold':
        return 'Gold Member';
      case 'silver':
        return 'Silver Member';
      case 'platinum':
        return 'Platinum Member';
      default:
        return 'Standard';
    }
  }

  String _appearanceLabel() {
    switch (_appearance) {
      case 'light':
        return 'Light';
      case 'system':
        return 'System Default';
      default:
        return 'Dark';
    }
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}
