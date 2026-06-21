import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import 'transfer_qr_page.dart';

class TransferChronosUserPage extends StatefulWidget {
  const TransferChronosUserPage({super.key});

  @override
  State<TransferChronosUserPage> createState() =>
      _TransferChronosUserPageState();
}

class _TransferChronosUserPageState
    extends State<TransferChronosUserPage> {
  final _ctrl = TextEditingController();
  String _query = '';
  bool _searching = false;
  _CUser? _found;

  static const _mockUsers = [
    _CUser('alexander.h', 'Alexander Hubert', Color(0xFF3B82F6)),
    _CUser('sarahm_sf', 'Sarah Mitchell', Color(0xFF8B5CF6)),
    _CUser('mikeTorres', 'Michael Torres', Color(0xFF10B981)),
    _CUser('emma.j', 'Emma Johnson', Color(0xFFF59E0B)),
  ];

  void _search(String v) {
    setState(() {
      _query = v;
      _found = null;
    });
    if (v.isEmpty) return;
    setState(() => _searching = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      final match = _mockUsers.where((u) =>
          u.username.toLowerCase().contains(v.toLowerCase()) ||
          u.name.toLowerCase().contains(v.toLowerCase()));
      setState(() {
        _searching = false;
        _found = match.isNotEmpty ? match.first : null;
      });
    });
  }

  void _showSendSheet(_CUser u) {
    final amountCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: _ChronosSendSheet(
          user: u,
          amountCtrl: amountCtrl,
          onSend: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  '\$${amountCtrl.text.isEmpty ? "0" : amountCtrl.text} sent to @${u.username}'),
              backgroundColor: const Color(0xFF14B8A6),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ));
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
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
            case 0: context.go(RouteConstants.home.toPath);
            case 1: context.go(RouteConstants.pantherAi.toPath);
            case 2: context.go(RouteConstants.blockHub.toPath);
          }
        },
      ),
      body: Stack(
        children: [
          Positioned.fill(
              child:
                  Image.asset('assets/background.png', fit: BoxFit.cover)),
          Positioned.fill(
              child: Container(
                  color: Colors.black.withValues(alpha: 0.15))),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSearchField(),
                const SizedBox(height: 24),
                _buildResultArea(),
                const Spacer(),
                _buildQrButton(),
                const SizedBox(height: 32),
              ],
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
            child: Text('Chronos User',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TextField(
            controller: _ctrl,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            cursorColor: const Color(0xFF8B5CF6),
            onChanged: _search,
            decoration: InputDecoration(
              hintText: 'Username or @chronos ID',
              hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 15),
              prefixIcon: Icon(Icons.alternate_email_rounded,
                  color: Colors.white.withValues(alpha: 0.45), size: 20),
              suffixIcon: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Color(0xFF8B5CF6), strokeWidth: 2)),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.12)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                    color: Color(0xFF8B5CF6), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultArea() {
    if (_query.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Text('Enter a Chronos username or phone number',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _mockUsers
                  .map((u) => GestureDetector(
                        onTap: () => _showSendSheet(u),
                        child: _SuggestionChip(user: u),
                      ))
                  .toList(),
            ),
          ],
        ),
      );
    }
    if (_searching) return const SizedBox.shrink();
    if (_found == null) {
      return Center(
        child: Text('No user found for "$_query"',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 14)),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => _showSendSheet(_found!),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [
                        _found!.color,
                        _found!.color.withValues(alpha: 0.6)
                      ]),
                    ),
                    child: Center(
                      child: Text(_found!.name[0],
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_found!.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('@${_found!.username}',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 13)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Send',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQrButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const TransferQrPage(initialTab: 1))),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner_rounded,
                  color: Color(0xFF8B5CF6), size: 20),
              SizedBox(width: 10),
              Text('Scan QR Code instead',
                  style: TextStyle(
                      color: Color(0xFF8B5CF6),
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CUser {
  const _CUser(this.username, this.name, this.color);
  final String username;
  final String name;
  final Color color;
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.user});
  final _CUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: user.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: user.color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: user.color,
            ),
            child: Center(
              child: Text(user.name[0],
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 8),
          Text('@${user.username}',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13)),
        ],
      ),
    );
  }
}

class _ChronosSendSheet extends StatelessWidget {
  const _ChronosSendSheet(
      {required this.user,
      required this.amountCtrl,
      required this.onSend});
  final _CUser user;
  final TextEditingController amountCtrl;
  final VoidCallback onSend;

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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
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
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  colors: [user.color, user.color.withValues(alpha: 0.6)]),
            ),
            child: Center(
              child: Text(user.name[0],
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 10),
          Text(user.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          Text('@${user.username}',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 13)),
          const SizedBox(height: 24),
          TextField(
            controller: amountCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
            ],
            textAlign: TextAlign.center,
            autofocus: true,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w300,
                letterSpacing: -1),
            cursorColor: const Color(0xFF8B5CF6),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.2),
                  fontSize: 42,
                  fontWeight: FontWeight.w300),
              prefixText: '\$ ',
              prefixStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 28),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSend,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Send',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
