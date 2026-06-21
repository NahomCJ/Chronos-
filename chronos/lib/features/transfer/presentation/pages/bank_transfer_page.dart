import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BankTransferPage extends StatefulWidget {
  const BankTransferPage({super.key});

  @override
  State<BankTransferPage> createState() => _BankTransferPageState();
}

class _BankTransferPageState extends State<BankTransferPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  bool _copied = false;

  static const _details = [
    _Detail('Account Name', 'Chronos Financial Inc.'),
    _Detail('Account Number', '8271 4829 1093'),
    _Detail('Routing Number', '021000021'),
    _Detail('Bank', 'Chase Bank'),
    _Detail('SWIFT / BIC', 'CHASUS33'),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim =
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _copyAll() {
    final text = _details
        .map((d) => '${d.label}: ${d.value}')
        .join('\n');
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2),
        () => mounted ? setState(() => _copied = false) : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: Stack(
        children: [
          Positioned.fill(
              child:
                  Image.asset('assets/background.png', fit: BoxFit.cover)),
          Positioned.fill(
              child: Container(
                  color: Colors.black.withValues(alpha: 0.15))),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _buildInfoBanner(),
                          const SizedBox(height: 20),
                          _buildDetailsCard(),
                          const SizedBox(height: 20),
                          _buildPlaidCard(),
                          const SizedBox(height: 20),
                          _buildActions(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 22),
          ),
          const Expanded(
            child: Column(
              children: [
                Text('Bank Transfer',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 2),
                Text('Add funds via wire',
                    style: TextStyle(
                        color: Color(0xFF14B8A6), fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Funds typically arrive within 1–2 business days. '
                  'Include your name as reference.',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      height: 1.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(
            children: _details.asMap().entries.map((e) {
              final isLast = e.key == _details.length - 1;
              return _DetailRow(
                  detail: e.value, isLast: isLast);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaidCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF16A34A).withValues(alpha: 0.15),
                const Color(0xFF16A34A).withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: const Color(0xFF16A34A).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Instant via Plaid',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    Text('Connect your bank for instant transfers',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Connect',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _copyAll,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _copied
                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: _copied
                        ? const Color(0xFF10B981).withValues(alpha: 0.4)
                        : Colors.white.withValues(alpha: 0.12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                      _copied
                          ? Icons.check_rounded
                          : Icons.copy_all_rounded,
                      color: _copied
                          ? const Color(0xFF10B981)
                          : Colors.white,
                      size: 17),
                  const SizedBox(width: 8),
                  Text(_copied ? 'Copied!' : 'Copy All',
                      style: TextStyle(
                          color: _copied
                              ? const Color(0xFF10B981)
                              : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.share_rounded,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 17),
                  const SizedBox(width: 8),
                  Text('Share',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail row
// ─────────────────────────────────────────────────────────────────────────────

class _Detail {
  const _Detail(this.label, this.value);
  final String label;
  final String value;
}

class _DetailRow extends StatefulWidget {
  const _DetailRow({required this.detail, required this.isLast});
  final _Detail detail;
  final bool isLast;

  @override
  State<_DetailRow> createState() => _DetailRowState();
}

class _DetailRowState extends State<_DetailRow> {
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.detail.value));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2),
        () => mounted ? setState(() => _copied = false) : null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.detail.label,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(widget.detail.value,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _copy,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: _copied
                        ? const Color(0xFF10B981).withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                      _copied ? Icons.check_rounded : Icons.copy_rounded,
                      color: _copied
                          ? const Color(0xFF10B981)
                          : Colors.white.withValues(alpha: 0.5),
                      size: 15),
                ),
              ),
            ],
          ),
        ),
        if (!widget.isLast)
          Divider(
              height: 1, color: Colors.white.withValues(alpha: 0.07)),
      ],
    );
  }
}
