import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransferContactsPage extends StatefulWidget {
  const TransferContactsPage({super.key});

  @override
  State<TransferContactsPage> createState() =>
      _TransferContactsPageState();
}

class _TransferContactsPageState extends State<TransferContactsPage> {
  final _search = TextEditingController();
  String _query = '';
  final _amountCtrl = TextEditingController();

  static const _contacts = [
    _Contact('Alexander Hubert', '+1 (415) 555-0182', 'A',
        Color(0xFF3B82F6)),
    _Contact('Sarah Mitchell', '+1 (415) 555-0247', 'S',
        Color(0xFF8B5CF6)),
    _Contact('Michael Torres', '+1 (415) 555-0391', 'M',
        Color(0xFF10B981)),
    _Contact('Emma Johnson', '+1 (415) 555-0458', 'E',
        Color(0xFFF59E0B)),
    _Contact('Benjamin Clark', '+1 (415) 555-0512', 'B',
        Color(0xFFEF4444)),
    _Contact('Julia Anderson', '+1 (415) 555-0673', 'J',
        Color(0xFFEC4899)),
    _Contact('Daniel Lee', '+1 (415) 555-0784', 'D', Color(0xFF06B6D4)),
    _Contact('Olivia Brown', '+1 (415) 555-0829', 'O',
        Color(0xFF84CC16)),
    _Contact('Noah Wilson', '+1 (415) 555-0943', 'N',
        Color(0xFFF97316)),
  ];

  List<_Contact> get _filtered => _query.isEmpty
      ? _contacts
      : _contacts
          .where((c) =>
              c.name.toLowerCase().contains(_query.toLowerCase()) ||
              c.phone.contains(_query))
          .toList();

  @override
  void dispose() {
    _search.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _onSelectContact(_Contact c) {
    _showSendSheet(c);
  }

  void _showSendSheet(_Contact c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SendSheet(
        contact: c,
        amountCtrl: _amountCtrl,
        onNoteChanged: (_) {},
        onSend: () {
          Navigator.pop(context);
          _showSuccessSheet(c);
        },
      ),
    );
  }

  void _showSuccessSheet(_Contact c) {
    final amount = _amountCtrl.text.isEmpty ? '0' : _amountCtrl.text;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SuccessSheet(
        contact: c,
        amount: amount,
        onDone: () {
          Navigator.pop(context);
          Navigator.of(context).pop();
        },
      ),
    );
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
                  color: Colors.black.withValues(alpha: 0.65))),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 8),
                Expanded(child: _buildList()),
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
            child: Text('Send to Contact',
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TextField(
            controller: _search,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            cursorColor: const Color(0xFF14B8A6),
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search contacts…',
              hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 15),
              prefixIcon: Icon(Icons.search_rounded,
                  color: Colors.white.withValues(alpha: 0.45), size: 20),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.12)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFF14B8A6), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_filtered.isEmpty) {
      return Center(
        child: Text('No contacts found',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 14)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) =>
          Divider(color: Colors.white.withValues(alpha: 0.07), height: 1),
      itemBuilder: (_, i) {
        final c = _filtered[i];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  colors: [c.color, c.color.withValues(alpha: 0.6)]),
            ),
            child: Center(
              child: Text(c.initial,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          title: Text(c.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
          subtitle: Text(c.phone,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 12)),
          trailing: Icon(Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.3), size: 20),
          onTap: () => _onSelectContact(c),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────────────────────────────────────

class _Contact {
  const _Contact(this.name, this.phone, this.initial, this.color);
  final String name;
  final String phone;
  final String initial;
  final Color color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Send sheet
// ─────────────────────────────────────────────────────────────────────────────

class _SendSheet extends StatelessWidget {
  const _SendSheet(
      {required this.contact,
      required this.amountCtrl,
      required this.onNoteChanged,
      required this.onSend});
  final _Contact contact;
  final TextEditingController amountCtrl;
  final ValueChanged<String> onNoteChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
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
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [
                      contact.color,
                      contact.color.withValues(alpha: 0.6)
                    ]),
                  ),
                  child: Center(
                    child: Text(contact.initial,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contact.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    Text(contact.phone,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
              ],
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -1),
              cursorColor: const Color(0xFF14B8A6),
              decoration: InputDecoration(
                hintText: '\$0.00',
                hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.2),
                    fontSize: 40,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -1),
                prefixText: '\$ ',
                prefixStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 28),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: onNoteChanged,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              cursorColor: const Color(0xFF14B8A6),
              decoration: InputDecoration(
                hintText: 'Add a note (optional)',
                hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 14),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF14B8A6), width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14B8A6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Send Money',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Success sheet
// ─────────────────────────────────────────────────────────────────────────────

class _SuccessSheet extends StatelessWidget {
  const _SuccessSheet(
      {required this.contact,
      required this.amount,
      required this.onDone});
  final _Contact contact;
  final String amount;
  final VoidCallback onDone;

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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
              ),
            ),
            child:
                const Icon(Icons.check_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('Sent!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('\$$amount sent to ${contact.name}',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0A0A14),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Done',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
