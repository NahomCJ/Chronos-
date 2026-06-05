import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../features/auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth/auth_event.dart';
import '../../../../features/auth/presentation/bloc/auth/auth_state.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';
import '../../data/datasources/profile_remote_datasource.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _kBg = Color(0xFFF4F6FA);
  static const _kCard = Colors.white;
  static const _kDark = Color(0xFF1A0A2E);
  static const _kPurple = Color(0xFF7C3AED);
  static const _kGold = Color(0xFFDC8F4A);
  static const _kText = Color(0xFF1A1A1A);
  static const _kSub = Color(0xFF888888);
  static const _kBorder = Color(0xFFEEEEEE);

  bool _pushTransactions = true;
  bool _pushPayments = true;
  bool _pushAiAlerts = true;
  bool _pushTickPay = true;
  bool _marketingEmails = false;
  bool _biometricsEnabled = false;
  bool _twoFactorEnabled = true;
  String _appearance = 'dark';
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
      _currency = p.getString('pref_currency') ?? 'USD';
    });
  }

  Future<void> _savePref(String key, dynamic value) async {
    final p = await SharedPreferences.getInstance();
    if (value is bool) await p.setBool(key, value);
    if (value is String) await p.setString(key, value);
  }

  // ── Root build: stable listeners outside of any builder ─────────────────────
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileCubit, ProfileState>(
          listener: (ctx, state) {
            if (state is ProfileLoaded) {
              if (state.updateSuccess != null) {
                _snack(ctx, state.updateSuccess!, _kPurple);
              } else if (state.updateError != null) {
                _snack(ctx, state.updateError!, Colors.redAccent);
              }
            }
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listener: (ctx, state) {
            if (state is AuthUnauthenticated) {
              ctx.go(RouteConstants.signIn.toPath);
            }
          },
        ),
      ],
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          UserProfileModel? user;
          bool isLoading = false;
          String? errorMsg;

          if (state is ProfileLoading) {
            isLoading = true;
          } else if (state is ProfileLoaded) {
            user = state.user;
            isLoading = state.isUpdating;
          } else if (state is ProfileError) {
            errorMsg = state.message;
          }

          return Scaffold(
            backgroundColor: _kBg,
            body: Column(
              children: [
                _buildHeroHeader(context, user),
                Expanded(
                  child: isLoading && user == null
                      ? _buildSkeletonLoading()
                      : errorMsg != null && user == null
                          ? _buildErrorState(context, errorMsg)
                          : _buildScrollBody(context, user, isLoading),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Hero header (dark, matches TickPay style) ────────────────────────────────
  Widget _buildHeroHeader(BuildContext context, UserProfileModel? user) {
    final initials = user?.initials ?? '??';
    final name = user?.fullName ?? 'Loading...';
    final tier = _tierLabel(user?.tier ?? 'standard');
    final tierColor = _tierColor(user?.tier ?? 'standard');

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A0A2E), Color(0xFF2D1B4E)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Profile & Settings',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  if (user != null)
                    GestureDetector(
                      onTap: () => _showEditSheet(context, user),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: _kPurple.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: _kPurple.withValues(alpha: 0.5)),
                        ),
                        child: const Text('Edit',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Avatar
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _kPurple.withValues(alpha: 0.5),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(initials,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _comingSoon(context, 'Photo upload'),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _kPurple,
                        border: Border.all(
                            color: const Color(0xFF1A0A2E), width: 2.5),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 13),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: tierColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: tierColor.withValues(alpha: 0.4), width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium_rounded,
                      color: tierColor, size: 13),
                  const SizedBox(width: 5),
                  Text(tier,
                      style: TextStyle(
                          color: tierColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 22),
            // Stats row
            _buildStatsRow(user),
            const SizedBox(height: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(UserProfileModel? user) {
    final balance = user != null
        ? '\$${user.balance.toStringAsFixed(2)}'
        : '---';
    final txCount = user?.transactionCount.toString() ?? '---';
    final since = user?.memberSince;
    final sinceStr = since != null
        ? '${_mon(since.month)} ${since.year}'
        : '---';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.12), width: 0.8),
      ),
      child: Row(
        children: [
          Expanded(child: _stat('Balance', balance)),
          Container(
              width: 0.6,
              height: 36,
              color: Colors.white.withValues(alpha: 0.15)),
          Expanded(child: _stat('Transactions', txCount)),
          Container(
              width: 0.6,
              height: 36,
              color: Colors.white.withValues(alpha: 0.15)),
          Expanded(child: _stat('Member Since', sinceStr)),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w500)),
        ],
      );

  // ── Loading skeleton ──────────────────────────────────────────────────────────
  Widget _buildSkeletonLoading() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      children: List.generate(
          4,
          (i) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                height: 90,
                decoration: BoxDecoration(
                  color: _kCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _kBorder),
                ),
              )),
    );
  }

  // ── Error state ───────────────────────────────────────────────────────────────
  Widget _buildErrorState(BuildContext context, String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _kPurple.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: _kPurple, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Could not load profile',
                style: TextStyle(
                    color: _kText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(msg,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: _kSub, fontSize: 13)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
                  context.read<ProfileCubit>().loadProfile(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
              child: const Text('Retry',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Scrollable settings body ──────────────────────────────────────────────────
  Widget _buildScrollBody(
      BuildContext context, UserProfileModel? user, bool isUpdating) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      children: [
        if (isUpdating)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: _kPurple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _kPurple.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _kPurple.withValues(alpha: 0.8)),
                ),
                const SizedBox(width: 12),
                const Text('Saving changes...',
                    style: TextStyle(
                        color: _kPurple,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        _section('Account', [
          _tile(Icons.person_outline_rounded, 'Full Name',
              user?.fullName ?? '---',
              onTap: user != null
                  ? () => _showEditSheet(context, user)
                  : null),
          _tile(Icons.email_outlined, 'Email', user?.email ?? '---',
              onTap: () => _comingSoon(context, 'Email change')),
          _tile(Icons.phone_outlined, 'Phone',
              user?.phone ?? 'Not set',
              onTap: user != null
                  ? () => _showFieldDialog(
                      context,
                      'Phone Number',
                      user.phone ?? '',
                      Icons.phone_outlined,
                      (v) => context
                          .read<ProfileCubit>()
                          .updateProfile(phone: v))
                  : null),
          _tile(Icons.location_on_outlined, 'Country', 'Ethiopia',
              onTap: () => _comingSoon(context, 'Country')),
        ]),
        const SizedBox(height: 20),
        _section('Security', [
          _tile(Icons.lock_outline_rounded, 'Change PIN', '6-digit PIN',
              onTap: () => _showPinSheet(context)),
          _tile(Icons.password_rounded, 'Change Password',
              'Update your password',
              onTap: () =>
                  context.push(RouteConstants.forgotPassword.toPath)),
          _toggleTile(
            Icons.fingerprint_rounded,
            'Biometric Login',
            'Face ID / Fingerprint',
            _biometricsEnabled,
            (v) {
              setState(() => _biometricsEnabled = v);
              _savePref('sec_biometrics', v);
            },
          ),
          _toggleTile(
            Icons.verified_user_outlined,
            'Two-Factor Auth',
            'SMS code on every login',
            _twoFactorEnabled,
            (v) {
              setState(() => _twoFactorEnabled = v);
              _savePref('sec_2fa', v);
            },
          ),
          _tile(Icons.devices_rounded, 'Active Sessions',
              'Manage devices',
              onTap: () => _showSessionsSheet(context)),
        ]),
        const SizedBox(height: 20),
        _section('Notifications', [
          _toggleTile(Icons.swap_horiz_rounded, 'Transaction Alerts',
              'Every deposit & withdrawal', _pushTransactions, (v) {
            setState(() => _pushTransactions = v);
            _savePref('notif_transactions', v);
          }),
          _toggleTile(Icons.event_outlined, 'Payment Due',
              'TickPay installment reminders', _pushPayments, (v) {
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
          _toggleTile(Icons.mark_email_unread_outlined,
              'Marketing Emails', 'Offers, tips, promotions',
              _marketingEmails, (v) {
            setState(() => _marketingEmails = v);
            _savePref('notif_marketing', v);
          }),
        ]),
        const SizedBox(height: 20),
        _section('Verification', [
          _tile(Icons.badge_outlined, 'KYC Status', 'Verified',
              badge: _pill('Verified', const Color(0xFF10B981)),
              onTap: () => _comingSoon(context, 'KYC Details')),
          _tile(Icons.account_balance_outlined, 'Linked Banks',
              '3 accounts connected',
              onTap: () => _comingSoon(context, 'Linked Banks')),
          _tile(Icons.credit_score_rounded, 'Identity Docs',
              'Government ID verified',
              onTap: () => _comingSoon(context, 'Identity Documents')),
        ]),
        const SizedBox(height: 20),
        _section('Membership', [
          _membershipCard(context, user),
        ]),
        const SizedBox(height: 20),
        _section('TickPay', [
          _tile(Icons.credit_card_outlined, 'TickPay Credit',
              'View your BNPL credit line',
              onTap: () =>
                  context.push(RouteConstants.tickpayDashboard.toPath)),
          _toggleTile(
            Icons.autorenew_rounded,
            'Auto-Pay',
            'Auto-deduct on due dates',
            false,
            (_) => _comingSoon(context, 'Auto-Pay setup'),
          ),
        ]),
        const SizedBox(height: 20),
        _section('Referral', [
          _referralCard(context, user),
          _tile(Icons.share_rounded, 'Invite Friends',
              'Share your code & earn rewards',
              onTap: () => _comingSoon(context, 'Referral sharing')),
          _tile(Icons.monetization_on_outlined, 'Referral Earnings',
              '\$0.00',
              onTap: () => _comingSoon(context, 'Referral earnings')),
        ]),
        const SizedBox(height: 20),
        _section('App Preferences', [
          _tile(Icons.palette_outlined, 'Appearance',
              _appearanceLabel(),
              onTap: () => _showAppearancePicker(context)),
          _tile(Icons.language_rounded, 'Language', 'English',
              onTap: () => _comingSoon(context, 'Language')),
          _tile(Icons.currency_exchange_rounded, 'Display Currency',
              _currency,
              onTap: () => _showCurrencyPicker(context)),
        ]),
        const SizedBox(height: 20),
        _section('Data & Privacy', [
          _tile(Icons.download_outlined, 'Export Transactions',
              'Download CSV or PDF',
              onTap: () => _comingSoon(context, 'Export')),
          _tile(Icons.privacy_tip_outlined, 'Privacy Policy', '',
              onTap: () => _comingSoon(context, 'Privacy Policy')),
          _tile(Icons.gavel_rounded, 'Terms of Service', '',
              onTap: () => _comingSoon(context, 'Terms of Service')),
          _tile(Icons.headset_mic_rounded, 'Help & Support',
              'FAQs, contact us',
              onTap: () => _showSupportSheet(context)),
        ]),
        const SizedBox(height: 20),
        // Danger zone
        Container(
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: Colors.red.withValues(alpha: 0.2)),
          ),
          child: _tile(
            Icons.delete_forever_rounded,
            'Delete Account',
            'Permanently remove all data',
            iconColor: Colors.red.withValues(alpha: 0.8),
            valueColor: Colors.red.withValues(alpha: 0.6),
            onTap: () => _confirmDelete(context),
          ),
        ),
        const SizedBox(height: 16),
        _signOutButton(context),
        const SizedBox(height: 16),
        Center(
          child: Text('Chronos v1.0.0',
              style: TextStyle(
                  color: _kSub.withValues(alpha: 0.5), fontSize: 12)),
        ),
      ],
    );
  }

  // ── Section container ─────────────────────────────────────────────────────────
  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: _kSub,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _kBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                      height: 1,
                      indent: 56,
                      endIndent: 0,
                      color: _kBorder),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── Basic tile ────────────────────────────────────────────────────────────────
  Widget _tile(
    IconData icon,
    String label,
    String value, {
    Widget? badge,
    VoidCallback? onTap,
    Color? iconColor,
    Color? valueColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (iconColor ?? _kPurple).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: iconColor ?? _kPurple, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: _kText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  if (value.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(value,
                        style: TextStyle(
                            color: valueColor ?? _kSub,
                            fontSize: 12)),
                  ],
                ],
              ),
            ),
            badge ??
                Icon(Icons.chevron_right_rounded,
                    color: _kSub.withValues(alpha: 0.5), size: 20),
          ],
        ),
      ),
    );
  }

  // ── Toggle tile ───────────────────────────────────────────────────────────────
  Widget _toggleTile(IconData icon, String label, String subtitle,
      bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _kPurple, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: _kText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: const TextStyle(
                        color: _kSub, fontSize: 12)),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: _kPurple,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFDDDDDD),
            ),
          ),
        ],
      ),
    );
  }

  // ── Membership card ───────────────────────────────────────────────────────────
  Widget _membershipCard(BuildContext context, UserProfileModel? user) {
    final tier = user?.tier ?? 'standard';
    final label = _tierLabel(tier);
    final color = _tierColor(tier);
    final since = user?.memberSince;
    final sinceStr = since != null
        ? '${_mon(since.month)} ${since.year}'
        : '---';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.8), color]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: _kText,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    Text('Member since $sinceStr',
                        style: const TextStyle(
                            color: _kSub, fontSize: 12)),
                  ],
                ),
              ),
              _pill(label, color),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => _comingSoon(context, 'Upgrade Plan'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [_kPurple, _kPurple.withValues(alpha: 0.8)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.rocket_launch_rounded,
                        color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text('Upgrade Plan',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Referral card ─────────────────────────────────────────────────────────────
  Widget _referralCard(BuildContext context, UserProfileModel? user) {
    final code = user != null
        ? 'CHR-${user.id.substring(0, 6).toUpperCase()}'
        : 'CHR-XXXXXX';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _kPurple.withValues(alpha: 0.08),
              const Color(0xFF5B21B6).withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kPurple.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.card_giftcard_rounded,
                color: _kPurple, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Referral Code',
                      style: TextStyle(
                          color: _kSub, fontSize: 11)),
                  const SizedBox(height: 3),
                  Text(code,
                      style: const TextStyle(
                          color: _kText,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: code));
                _snack(context, 'Code copied!', _kPurple);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _kPurple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Copy',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sign out button ───────────────────────────────────────────────────────────
  Widget _signOutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmSignOut(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded,
                color: Colors.red.withValues(alpha: 0.8), size: 18),
            const SizedBox(width: 10),
            Text('Sign Out',
                style: TextStyle(
                    color: Colors.red.withValues(alpha: 0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ── Pill badge ────────────────────────────────────────────────────────────────
  Widget _pill(String text, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: color.withValues(alpha: 0.3), width: 0.8),
        ),
        child: Text(text,
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      );

  // ── Sheets ────────────────────────────────────────────────────────────────────
  void _showEditSheet(BuildContext context, UserProfileModel user) {
    final firstCtrl = TextEditingController(text: user.firstName);
    final lastCtrl = TextEditingController(text: user.lastName);
    final cubit = context.read<ProfileCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
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
                      color: _kBorder,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            const Text('Edit Profile',
                style: TextStyle(
                    color: _kText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _field('First Name', firstCtrl),
            const SizedBox(height: 14),
            _field('Last Name', lastCtrl),
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
                  elevation: 0,
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

  void _showFieldDialog(BuildContext context, String label,
      String current, IconData icon, Function(String) onSave) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: _kPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: _kPurple, size: 18),
            ),
            const SizedBox(width: 12),
            Text('Edit $label',
                style: const TextStyle(
                    color: _kText,
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
          ],
        ),
        content: _field(label, ctrl),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: _kSub))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onSave(ctrl.text.trim());
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: _kPurple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPinSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
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
                      color: _kBorder,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            const Text('Change PIN',
                style: TextStyle(
                    color: _kText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Enter current PIN then set your new one',
                style: TextStyle(color: _kSub, fontSize: 13)),
            const SizedBox(height: 20),
            _pinField('Current PIN'),
            const SizedBox(height: 12),
            _pinField('New PIN'),
            const SizedBox(height: 12),
            _pinField('Confirm New PIN'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _comingSoon(context, 'PIN change');
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: _kPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
                child: const Text('Update PIN',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSessionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
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
                      color: _kBorder,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            const Text('Active Sessions',
                style: TextStyle(
                    color: _kText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _sessionRow(Icons.phone_iphone_rounded, 'iPhone 15',
                'Current device · Now', true),
            const SizedBox(height: 10),
            _sessionRow(Icons.laptop_rounded, 'Chrome on MacBook',
                '2 days ago', false),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _comingSoon(context, 'Sign out all devices');
                },
                icon: const Icon(Icons.logout_rounded, size: 16),
                label:
                    const Text('Sign out all other devices'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side:
                      BorderSide(color: Colors.red.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppearancePicker(BuildContext context) {
    final options = [
      ('dark', 'Dark', Icons.dark_mode_rounded),
      ('light', 'Light', Icons.light_mode_rounded),
      ('system', 'System Default', Icons.settings_brightness_rounded),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
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
                      color: _kBorder,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            const Text('Appearance',
                style: TextStyle(
                    color: _kText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            for (final opt in options)
              GestureDetector(
                onTap: () {
                  setState(() => _appearance = opt.$1);
                  _savePref('pref_appearance', opt.$1);
                  Navigator.pop(ctx);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _appearance == opt.$1
                        ? _kPurple.withValues(alpha: 0.07)
                        : const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: _appearance == opt.$1
                            ? _kPurple.withValues(alpha: 0.4)
                            : _kBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(opt.$3,
                          color: _appearance == opt.$1
                              ? _kPurple
                              : _kSub,
                          size: 20),
                      const SizedBox(width: 14),
                      Text(opt.$2,
                          style: TextStyle(
                              color: _kText,
                              fontSize: 14,
                              fontWeight:
                                  _appearance == opt.$1
                                      ? FontWeight.w600
                                      : FontWeight.w400)),
                      const Spacer(),
                      if (_appearance == opt.$1)
                        const Icon(Icons.check_circle_rounded,
                            color: _kPurple, size: 20),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    final currencies = ['USD', 'EUR', 'GBP', 'ETB', 'CAD', 'AUD', 'AED'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
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
                      color: _kBorder,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            const Text('Display Currency',
                style: TextStyle(
                    color: _kText,
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
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: _currency == c
                                ? _kPurple
                                : const Color(0xFFF4F4F8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(c,
                              style: TextStyle(
                                  color: _currency == c
                                      ? Colors.white
                                      : _kText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showSupportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
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
                      color: _kBorder,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Help & Support',
                  style: TextStyle(
                      color: _kText,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 16),
            for (final item in [
              (Icons.chat_bubble_outline_rounded, 'Live Chat',
                  'Chat with our team'),
              (Icons.email_outlined, 'Email Support',
                  'support@chronos.app'),
              (Icons.quiz_outlined, 'FAQ',
                  'Browse common questions'),
              (Icons.bug_report_outlined, 'Report a Problem',
                  'Let us know'),
            ])
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  _comingSoon(context, item.$2);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8FC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _kBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: _kPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.$1,
                            color: _kPurple, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(item.$2,
                                style: const TextStyle(
                                    color: _kText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)),
                            Text(item.$3,
                                style: const TextStyle(
                                    color: _kSub, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          color: _kSub, size: 13),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign out?',
            style: TextStyle(
                color: _kText, fontWeight: FontWeight.w700)),
        content: const Text(
          'You\'ll need to sign in again to access your account.',
          style: TextStyle(color: _kSub),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: _kSub))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const SignOutRequested());
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.red.withValues(alpha: 0.8)),
            const SizedBox(width: 10),
            const Text('Delete Account?',
                style: TextStyle(
                    color: _kText, fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Text(
          'This permanently removes all your data — transactions, wallets, and TickPay history. This cannot be undone.',
          style: TextStyle(color: _kSub),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  const Text('Cancel', style: TextStyle(color: _kSub))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _comingSoon(context, 'Account deletion');
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── Small helper widgets ──────────────────────────────────────────────────────
  Widget _field(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: _kText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _kSub),
        filled: true,
        fillColor: const Color(0xFFF8F8FC),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _kBorder)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _kBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _kPurple)),
      ),
    );
  }

  Widget _pinField(String label) {
    return TextField(
      obscureText: true,
      maxLength: 6,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: _kText, letterSpacing: 8),
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        labelStyle: const TextStyle(color: _kSub),
        filled: true,
        fillColor: const Color(0xFFF8F8FC),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _kBorder)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _kBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _kPurple)),
      ),
    );
  }

  Widget _sessionRow(
      IconData icon, String device, String time, bool isCurrent) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrent
            ? _kPurple.withValues(alpha: 0.06)
            : const Color(0xFFF8F8FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isCurrent
                ? _kPurple.withValues(alpha: 0.25)
                : _kBorder),
      ),
      child: Row(
        children: [
          Icon(icon,
              color: isCurrent ? _kPurple : _kSub, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device,
                    style: const TextStyle(
                        color: _kText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                Text(time,
                    style:
                        const TextStyle(color: _kSub, fontSize: 11)),
              ],
            ),
          ),
          if (isCurrent) _pill('Current', const Color(0xFF10B981)),
        ],
      ),
    );
  }

  // ── Utilities ──────────────────────────────────────────────────────────────────
  void _comingSoon(BuildContext context, String feature) =>
      _snack(context, '$feature — coming soon', _kDark);

  void _snack(BuildContext context, String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
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
        return 'Platinum';
      default:
        return 'Standard';
    }
  }

  Color _tierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'gold':
        return _kGold;
      case 'silver':
        return const Color(0xFF9CA3AF);
      case 'platinum':
        return const Color(0xFF60A5FA);
      default:
        return const Color(0xFF10B981);
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

  String _mon(int m) {
    const names = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[m];
  }
}
