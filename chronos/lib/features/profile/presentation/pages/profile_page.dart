import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/theme_cubit.dart';
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
  static const _kTeal = Color(0xFF14B8A6);
  String _appearance = 'dark';
  String _currency = 'USD';

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileCubit, ProfileState>(
          listener: (ctx, state) {
            if (state is ProfileLoaded) {
              if (state.updateSuccess != null) _snack(ctx, state.updateSuccess!, _kTeal);
              if (state.updateError != null) _snack(ctx, state.updateError!, Colors.redAccent);
            }
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listener: (ctx, state) {
            if (state is AuthUnauthenticated) ctx.go(RouteConstants.signIn.toPath);
          },
        ),
      ],
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          UserProfileModel? user;
          bool isLoading = false;
          String? errorMsg;

          if (state is ProfileInitial || state is ProfileLoading) {
            isLoading = true;
          } else if (state is ProfileLoaded) {
            user = state.user;
            isLoading = state.isUpdating;
          } else if (state is ProfileError) {
            errorMsg = state.message;
          }

          return Scaffold(
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            floatingActionButton: Container(
              margin: const EdgeInsets.only(bottom: 90),
              child: const ChrisHomeFab(),
            ),
            body: Stack(
              children: [
                // Background
                Positioned.fill(
                  child: Image.asset('assets/background.png', fit: BoxFit.cover),
                ),
                Positioned.fill(
                  child: Container(color: Colors.black.withValues(alpha: 0.55)),
                ),
                // Content
                SafeArea(
                  child: Column(
                    children: [
                      _buildTopBar(context, user),
                      Expanded(
                        child: isLoading && user == null
                            ? _buildSkeleton()
                            : errorMsg != null && user == null
                                ? _buildError(context, errorMsg)
                                : _buildBody(context, user, isLoading),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, UserProfileModel? user) {
    final name = user?.fullName ?? 'Loading...';
    final initials = user?.initials ?? '??';
    final tier = _tierLabel(user?.tier ?? 'standard');
    final tierColor = _tierColor(user?.tier ?? 'standard');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: _glass(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 14),
                ),
              ),
              const SizedBox(width: 12),
              // Avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                ),
                child: Center(
                  child: Text(initials,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.workspace_premium_rounded, color: tierColor, size: 11),
                        const SizedBox(width: 3),
                        Text(tier,
                            style: TextStyle(
                                color: tierColor, fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              if (user != null)
                GestureDetector(
                  onTap: () => _showEditSheet(context, user),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: const Text('Edit',
                        style: TextStyle(
                            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: List.generate(
          4,
          (i) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                ),
              )),
    );
  }

  Widget _buildError(BuildContext context, String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.redAccent.withValues(alpha: 0.7), size: 36),
            const SizedBox(height: 12),
            Text(msg,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => context.read<ProfileCubit>().loadProfile(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text('Retry',
                    style: TextStyle(color: Color(0xFF0A0A14), fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserProfileModel? user, bool isUpdating) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        if (isUpdating) _buildUpdatingBanner(),
        _buildStatsRow(user),
        const SizedBox(height: 12),
        _section('ACCOUNT', [
          _tile(Icons.person_outline_rounded, 'Full Name', user?.fullName ?? '---',
              onTap: user != null ? () => _showEditSheet(context, user) : null),
          _div(),
          _tile(Icons.email_outlined, 'Email', user?.email ?? '---',
              onTap: () => _comingSoon(context, 'Email change')),
          _div(),
          _tile(Icons.phone_outlined, 'Phone', user?.phone ?? 'Not set',
              onTap: user != null
                  ? () => _showFieldDialog(context, 'Phone Number', user.phone ?? '',
                      Icons.phone_outlined, (v) => context.read<ProfileCubit>().updateProfile(phone: v))
                  : null),
          _div(),
          _tile(Icons.location_on_outlined, 'Country', 'United States',
              onTap: () => _comingSoon(context, 'Country')),
        ]),
        const SizedBox(height: 12),
        _section('SECURITY', [
          _tile(Icons.lock_outline_rounded, 'Change PIN', '6-digit PIN',
              onTap: () => _showPinSheet(context)),
          _div(),
          _tile(Icons.password_rounded, 'Change Password', 'Update your password',
              onTap: () => context.push(RouteConstants.changePassword.toPath)),
          _div(),
          _tile(Icons.devices_rounded, 'Active Sessions', 'Manage devices',
              onTap: () => _showSessionsSheet(context)),
          _div(),
          _tile(Icons.verified_user_outlined, 'Two-Factor Auth', 'Authenticator app',
              onTap: () => _show2faDialog(context)),
        ]),
        const SizedBox(height: 12),
        _section('NOTIFICATIONS', [
          _tile(Icons.notifications_outlined, 'Notification Settings',
              'Push, alerts, marketing',
              onTap: () => context.push(RouteConstants.notificationSettings.toPath)),
        ]),
        const SizedBox(height: 12),
        _section('VERIFICATION', [
          _tile(Icons.badge_outlined, 'KYC Status', 'Verified',
              badge: _pill('Verified', const Color(0xFF10B981)),
              onTap: () => _comingSoon(context, 'KYC Details')),
          _div(),
          _tile(Icons.account_balance_outlined, 'Linked Banks', '3 accounts connected',
              onTap: () => _comingSoon(context, 'Linked Banks')),
          _div(),
          _tile(Icons.credit_score_rounded, 'Identity Docs', 'Government ID verified',
              onTap: () => _comingSoon(context, 'Identity Documents')),
        ]),
        const SizedBox(height: 12),
        _section('MEMBERSHIP', [_membershipCard(context, user)]),
        const SizedBox(height: 12),
        _section('TICKPAY', [
          _tile(Icons.credit_card_outlined, 'TickPay Credit', 'View your BNPL credit line',
              onTap: () => context.push(RouteConstants.tickpayDashboard.toPath)),
          _div(),
          _tile(Icons.autorenew_rounded, 'Auto-Pay', 'Auto-deduct on due dates',
              onTap: () => _comingSoon(context, 'Auto-Pay setup')),
        ]),
        const SizedBox(height: 12),
        _section('REFERRAL', [
          _referralCard(context, user),
          _div(),
          _tile(Icons.share_rounded, 'Invite Friends', 'Share your code and earn rewards',
              onTap: () => _comingSoon(context, 'Referral sharing')),
          _div(),
          _tile(Icons.monetization_on_outlined, 'Referral Earnings', '\$0.00',
              onTap: () => _comingSoon(context, 'Referral earnings')),
        ]),
        const SizedBox(height: 12),
        _section('APP PREFERENCES', [
          _tile(Icons.palette_outlined, 'Appearance', _appearanceLabel(),
              onTap: () => _showAppearancePicker(context)),
          _div(),
          _themeTile(context),
          _div(),
          _tile(Icons.language_rounded, 'Language', 'English',
              onTap: () => _comingSoon(context, 'Language')),
          _div(),
          _tile(Icons.currency_exchange_rounded, 'Display Currency', _currency,
              onTap: () => _showCurrencyPicker(context)),
        ]),
        const SizedBox(height: 12),
        _section('DATA & PRIVACY', [
          _tile(Icons.download_outlined, 'Export Transactions', 'Download CSV or PDF',
              onTap: () => _comingSoon(context, 'Export')),
          _div(),
          _tile(Icons.privacy_tip_outlined, 'Privacy Policy', '',
              onTap: () => _comingSoon(context, 'Privacy Policy')),
          _div(),
          _tile(Icons.gavel_rounded, 'Terms of Service', '',
              onTap: () => _comingSoon(context, 'Terms of Service')),
          _div(),
          _tile(Icons.headset_mic_rounded, 'Help & Support', 'FAQs, contact us',
              onTap: () => _showSupportSheet(context)),
        ]),
        const SizedBox(height: 12),
        _buildDangerZone(context),
        const SizedBox(height: 12),
        Center(
          child: Text('Chronos v1.0.0',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 11)),
        ),
      ],
    );
  }

  Widget _buildStatsRow(UserProfileModel? user) {
    final balance = user != null ? '\$${user.balance.toStringAsFixed(0)}' : '---';
    final txCount = user?.transactionCount.toString() ?? '---';
    final since = user?.memberSince;
    final sinceStr = since != null ? '${_mon(since.month)} ${since.year}' : '---';

    return _glass(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Expanded(child: _stat('Balance', balance)),
            Container(width: 0.6, height: 28, color: Colors.white.withValues(alpha: 0.15)),
            Expanded(child: _stat('Transactions', txCount)),
            Container(width: 0.6, height: 28, color: Colors.white.withValues(alpha: 0.15)),
            Expanded(child: _stat('Member Since', sinceStr)),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 9,
                  fontWeight: FontWeight.w500)),
        ],
      );

  Widget _buildUpdatingBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _kTeal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kTeal.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: _kTeal.withValues(alpha: 0.8)),
          ),
          const SizedBox(width: 10),
          Text('Saving changes...',
              style: TextStyle(color: _kTeal, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text('DANGER ZONE',
              style: TextStyle(
                  color: Colors.red.withValues(alpha: 0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1)),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.red.withValues(alpha: 0.18)),
              ),
              child: Column(
                children: [
                  _tile(Icons.logout_rounded, 'Sign Out', 'Sign out of your account',
                      iconColor: Colors.red.withValues(alpha: 0.8),
                      valueColor: Colors.red.withValues(alpha: 0.5),
                      onTap: () => _confirmSignOut(context)),
                  Divider(height: 1, color: Colors.red.withValues(alpha: 0.1)),
                  _tile(Icons.delete_forever_rounded, 'Delete Account',
                      'Permanently remove all data',
                      iconColor: Colors.red.withValues(alpha: 0.8),
                      valueColor: Colors.red.withValues(alpha: 0.5),
                      onTap: () => _confirmDelete(context)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Glass card helper ───────────────────────────────────────────────────────
  Widget _glass({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: child,
        ),
      ),
    );
  }

  // ── Section wrapper ─────────────────────────────────────────────────────────
  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(title,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1)),
        ),
        _glass(child: Column(children: children)),
      ],
    );
  }

  Widget _div() => Divider(height: 1, color: Colors.white.withValues(alpha: 0.07));

  // ── Basic tile ──────────────────────────────────────────────────────────────
  Widget _tile(IconData icon, String label, String value,
      {Widget? badge, VoidCallback? onTap, Color? iconColor, Color? valueColor}) {
    final ic = iconColor ?? Colors.white.withValues(alpha: 0.65);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: ic.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: ic, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                  if (value.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(value,
                        style: TextStyle(
                            color: valueColor ?? Colors.white.withValues(alpha: 0.4),
                            fontSize: 11)),
                  ],
                ],
              ),
            ),
            badge ??
                Icon(Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.25), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
        ),
        child: Text(text,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
      );

  // ── Membership card ─────────────────────────────────────────────────────────
  Widget _membershipCard(BuildContext context, UserProfileModel? user) {
    final tier = user?.tier ?? 'standard';
    final label = _tierLabel(tier);
    final color = _tierColor(tier);
    final since = user?.memberSince;
    final sinceStr = since != null ? '${_mon(since.month)} ${since.year}' : '---';

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Icon(Icons.workspace_premium_rounded, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                    Text('Since $sinceStr',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
                  ],
                ),
              ),
              _pill(label, color),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _comingSoon(context, 'Upgrade Plan'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.rocket_launch_rounded, color: Color(0xFF0A0A14), size: 14),
                    SizedBox(width: 6),
                    Text('Upgrade Plan',
                        style: TextStyle(
                            color: Color(0xFF0A0A14),
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Referral card ───────────────────────────────────────────────────────────
  Widget _referralCard(BuildContext context, UserProfileModel? user) {
    final rawId = user?.id ?? '';
    final shortId = rawId.length >= 6 ? rawId.substring(0, 6) : rawId.padRight(6, 'X');
    final code = 'CHR-${shortId.toUpperCase()}';

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(Icons.card_giftcard_rounded, color: Colors.white.withValues(alpha: 0.6), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Referral Code',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4), fontSize: 10)),
                const SizedBox(height: 2),
                Text(code,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: code));
              _snack(context, 'Code copied!', _kTeal);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: const Text('Copy',
                  style: TextStyle(
                      color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Theme tile ──────────────────────────────────────────────────────────────
  Widget _themeTile(BuildContext context) {
    final currentTheme = context.watch<ThemeCubit>().state;
    return GestureDetector(
      onTap: () => context.push('/theme-settings'),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(Icons.color_lens_outlined,
                  color: Colors.white.withValues(alpha: 0.65), size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Theme',
                      style: TextStyle(
                          color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 1),
                  Text(currentTheme.name,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
                ],
              ),
            ),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentTheme.accentColor,
                boxShadow: [
                  BoxShadow(
                      color: currentTheme.accentColor.withValues(alpha: 0.5), blurRadius: 5)
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.25), size: 18),
          ],
        ),
      ),
    );
  }

  // ── Sheets & dialogs ────────────────────────────────────────────────────────
  void _showEditSheet(BuildContext context, UserProfileModel user) {
    final firstCtrl = TextEditingController(text: user.firstName);
    final lastCtrl = TextEditingController(text: user.lastName);
    final cubit = context.read<ProfileCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 18),
            const Text('Edit Profile',
                style: TextStyle(
                    color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            _darkField('First Name', firstCtrl),
            const SizedBox(height: 12),
            _darkField('Last Name', lastCtrl),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  cubit.updateProfile(
                      firstName: firstCtrl.text.trim(),
                      lastName: lastCtrl.text.trim());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(50)),
                  child: const Center(
                    child: Text('Save Changes',
                        style: TextStyle(
                            color: Color(0xFF0A0A14),
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFieldDialog(BuildContext context, String label, String current,
      IconData icon, Function(String) onSave) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 17),
            ),
            const SizedBox(width: 10),
            Text('Edit $label',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
          ],
        ),
        content: _darkField(label, ctrl),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5)))),
          GestureDetector(
            onTap: () {
              Navigator.pop(ctx);
              onSave(ctrl.text.trim());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: const Text('Save',
                  style: TextStyle(
                      color: Color(0xFF0A0A14), fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _show2faDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.security_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Two-Factor Auth',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
          ],
        ),
        content: Text('Enable 2FA via your authenticator app.\n\nFeature coming in next release.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pop(ctx),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: const Text('OK',
                  style: TextStyle(color: Color(0xFF0A0A14), fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _showPinSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 18),
            const Text('Change PIN',
                style: TextStyle(
                    color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Enter current PIN then set your new one',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12)),
            const SizedBox(height: 18),
            _pinField('Current PIN'),
            const SizedBox(height: 10),
            _pinField('New PIN'),
            const SizedBox(height: 10),
            _pinField('Confirm New PIN'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  _comingSoon(context, 'PIN change');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(50)),
                  child: const Center(
                    child: Text('Update PIN',
                        style: TextStyle(
                            color: Color(0xFF0A0A14),
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
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
      backgroundColor: const Color(0xFF1A1A2E),
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
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 18),
            const Text('Active Sessions',
                style: TextStyle(
                    color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            _sessionRow(Icons.phone_iphone_rounded, 'iPhone 15', 'Current device · Now', true),
            const SizedBox(height: 8),
            _sessionRow(Icons.laptop_rounded, 'Chrome on MacBook', '2 days ago', false),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _comingSoon(context, 'Sign out all devices');
                },
                icon: const Icon(Icons.logout_rounded, size: 15),
                label: const Text('Sign out all other devices'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      backgroundColor: const Color(0xFF1A1A2E),
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
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 18),
            const Text('Appearance',
                style: TextStyle(
                    color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            for (final opt in options)
              GestureDetector(
                onTap: () {
                  setState(() => _appearance = opt.$1);
                  Navigator.pop(ctx);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _appearance == opt.$1
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _appearance == opt.$1
                            ? Colors.white.withValues(alpha: 0.22)
                            : Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Row(
                    children: [
                      Icon(opt.$3,
                          color: _appearance == opt.$1
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.4),
                          size: 18),
                      const SizedBox(width: 12),
                      Text(opt.$2,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: _appearance == opt.$1
                                  ? FontWeight.w600
                                  : FontWeight.w400)),
                      const Spacer(),
                      if (_appearance == opt.$1)
                        Icon(Icons.check_circle_rounded, color: _kTeal, size: 18),
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
      backgroundColor: const Color(0xFF1A1A2E),
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
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 18),
            const Text('Display Currency',
                style: TextStyle(
                    color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: currencies
                  .map((c) => GestureDetector(
                        onTap: () {
                          setState(() => _currency = c);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                          decoration: BoxDecoration(
                            color: _currency == c
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _currency == c
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Text(c,
                              style: TextStyle(
                                  color: _currency == c
                                      ? const Color(0xFF0A0A14)
                                      : Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
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
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 18),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Help & Support',
                  style: TextStyle(
                      color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 14),
            for (final item in [
              (Icons.chat_bubble_outline_rounded, 'Live Chat', 'Chat with our team'),
              (Icons.email_outlined, 'Email Support', 'support@chronos.app'),
              (Icons.quiz_outlined, 'FAQ', 'Browse common questions'),
              (Icons.bug_report_outlined, 'Report a Problem', 'Let us know'),
            ])
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  _comingSoon(context, item.$2);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(item.$1,
                            color: Colors.white.withValues(alpha: 0.65), size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.$2,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                            Text(item.$3,
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.white.withValues(alpha: 0.25), size: 12),
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
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign out?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        content: Text('You\'ll need to sign in again to access your account.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5)))),
          GestureDetector(
            onTap: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const SignOutRequested());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(10)),
              child: const Text('Sign out',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.withValues(alpha: 0.8)),
            const SizedBox(width: 8),
            const Text('Delete Account?',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
          ],
        ),
        content: Text(
          'This permanently removes all your data — transactions, wallets, and TickPay history. This cannot be undone.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 13),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5)))),
          GestureDetector(
            onTap: () {
              Navigator.pop(ctx);
              _confirmDeleteStep2(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(10)),
              child: const Text('Continue',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteStep2(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Type DELETE to confirm',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('This action is irreversible.',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55), fontSize: 12)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'DELETE',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5)))),
          StatefulBuilder(
            builder: (_, setInner) => GestureDetector(
              onTap: () {
                if (ctrl.text.trim() == 'DELETE') {
                  Navigator.pop(ctx);
                  _snack(context, 'Request submitted.', Colors.red);
                } else {
                  setInner(() {});
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(10)),
                child: const Text('Delete',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Small helpers ───────────────────────────────────────────────────────────
  Widget _darkField(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.35))),
      ),
    );
  }

  Widget _pinField(String label) {
    return TextField(
      obscureText: true,
      maxLength: 6,
      keyboardType: TextInputType.number,
      style:
          const TextStyle(color: Colors.white, letterSpacing: 8, fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        labelStyle:
            TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.35))),
      ),
    );
  }

  Widget _sessionRow(IconData icon, String device, String time, bool isCurrent) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isCurrent
                ? Colors.white.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Icon(icon,
              color: isCurrent ? Colors.white : Colors.white.withValues(alpha: 0.4),
              size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                Text(time,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4), fontSize: 10)),
              ],
            ),
          ),
          if (isCurrent) _pill('Current', const Color(0xFF10B981)),
        ],
      ),
    );
  }

  // ── Utilities ───────────────────────────────────────────────────────────────
  void _comingSoon(BuildContext context, String feature) =>
      _snack(context, '$feature — coming soon', const Color(0xFF2A2A3E));

  void _snack(BuildContext context, String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  String _tierLabel(String tier) {
    switch (tier.toLowerCase()) {
      case 'gold': return 'Gold Member';
      case 'silver': return 'Silver Member';
      case 'platinum': return 'Platinum';
      default: return 'Standard';
    }
  }

  Color _tierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'gold': return const Color(0xFFDC8F4A);
      case 'silver': return const Color(0xFF9CA3AF);
      case 'platinum': return const Color(0xFF60A5FA);
      default: return const Color(0xFF10B981);
    }
  }

  String _appearanceLabel() {
    switch (_appearance) {
      case 'light': return 'Light';
      case 'system': return 'System Default';
      default: return 'Dark';
    }
  }

  String _mon(int m) {
    const names = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[m];
  }
}
