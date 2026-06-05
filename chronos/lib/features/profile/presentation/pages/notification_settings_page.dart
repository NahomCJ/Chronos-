import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  static const _kBg = Color(0xFF0A0A14);
  static const _kCard = Color(0xFF1A1A2E);
  static const _kTeal = Color(0xFF14B8A6);

  final Map<String, bool> _prefs = {
    'push_enabled': true,
    'transaction_alerts': true,
    'tickpay_deals': true,
    'security_alerts': true,
    'weekly_report': false,
    'marketing': false,
  };

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Preferences saved',
            style: TextStyle(color: Colors.white)),
        backgroundColor: _kTeal,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                children: [
                  _sectionLabel('PUSH NOTIFICATIONS'),
                  const SizedBox(height: 8),
                  _buildCard([
                    _toggleRow(
                      Icons.notifications_rounded,
                      'Push Notifications',
                      'Enable all push notifications',
                      'push_enabled',
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _sectionLabel('TRANSACTION ALERTS'),
                  const SizedBox(height: 8),
                  _buildCard([
                    _toggleRow(
                      Icons.swap_horiz_rounded,
                      'Transaction Alerts',
                      'Every deposit and withdrawal',
                      'transaction_alerts',
                    ),
                    Divider(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.05)),
                    _toggleRow(
                      Icons.shopping_bag_outlined,
                      'TickPay Deals',
                      'BNPL reminders and offers',
                      'tickpay_deals',
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _sectionLabel('SECURITY'),
                  const SizedBox(height: 8),
                  _buildCard([
                    _toggleRow(
                      Icons.shield_outlined,
                      'Security Alerts',
                      'Login attempts and suspicious activity',
                      'security_alerts',
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _sectionLabel('REPORTS & MARKETING'),
                  const SizedBox(height: 8),
                  _buildCard([
                    _toggleRow(
                      Icons.bar_chart_rounded,
                      'Weekly Report',
                      'Summary of your activity each week',
                      'weekly_report',
                    ),
                    Divider(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.05)),
                    _toggleRow(
                      Icons.mark_email_unread_outlined,
                      'Marketing',
                      'Offers, tips, and promotions',
                      'marketing',
                    ),
                  ]),
                  const SizedBox(height: 32),
                  _buildSaveButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: _kCard,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Notification Settings',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.45),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(children: children),
    );
  }

  Widget _toggleRow(
      IconData icon, String label, String subtitle, String key) {
    final isOn = _prefs[key] ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isOn
                  ? _kTeal.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                color: isOn
                    ? _kTeal
                    : Colors.white.withValues(alpha: 0.4),
                size: 18),
          ),
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
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 12)),
              ],
            ),
          ),
          Switch.adaptive(
            value: isOn,
            onChanged: (v) => setState(() => _prefs[key] = v),
            activeColor: _kTeal,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _save,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Center(
            child: Text(
              'Save Preferences',
              style: TextStyle(
                color: Color(0xFF0A0A14),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
