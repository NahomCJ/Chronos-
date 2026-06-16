import 'package:flutter/material.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/theme/text_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LifeXExportPage extends StatefulWidget {
  const LifeXExportPage({super.key});

  @override
  State<LifeXExportPage> createState() => _LifeXExportPageState();
}

class _LifeXExportPageState extends State<LifeXExportPage> {
  static const _bg = Color(0xFFF5F6FA);
  static const _card = Colors.white;
  static const _lime = Color(0xFF84CC16);
  static const _limeLight = Color(0xFFA3E635);

  static const _reports = [
    _Report('Monthly Life Score Report', 'May 2026', Icons.bar_chart_rounded, Color(0xFF06B6D4), 'PDF'),
    _Report('Health & Fitness Summary', 'May 2026', Icons.favorite_rounded, Color(0xFF14B8A6), 'PDF'),
    _Report('Financial Statement', 'May 2026', Icons.account_balance_rounded, Color(0xFF10B981), 'CSV'),
    _Report('Activity Log', 'May 2026', Icons.directions_run_rounded, Color(0xFFF59E0B), 'CSV'),
    _Report('Education Progress', 'May 2026', Icons.school_rounded, Color(0xFF8B5CF6), 'PDF'),
  ];

  static const _exportTypes = [
    _ExportType('Full LifeX Report', 'All modules combined', Icons.summarize_rounded, Color(0xFF84CC16)),
    _ExportType('Financial Data', 'Transactions & budgets', Icons.attach_money_rounded, Color(0xFF10B981)),
    _ExportType('Health Records', 'Vitals, habits, fitness', Icons.health_and_safety_rounded, Color(0xFF14B8A6)),
    _ExportType('Activity History', 'Workouts & movement', Icons.directions_run_rounded, Color(0xFFF59E0B)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 30),
        child: const ChrisHomeFab(),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHero(context)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionTitle('Quick Export'),
                const SizedBox(height: 14),
                _buildExportGrid(),
                const SizedBox(height: 22),
                _sectionTitle('Recent Reports'),
                const SizedBox(height: 14),
              ]),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                child: _ReportCard(report: _reports[i]),
              ),
              childCount: _reports.length,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionTitle('Data Privacy'),
                const SizedBox(height: 14),
                _buildPrivacyCard(),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Stack(fit: StackFit.expand, children: [
        CachedNetworkImage(
          imageUrl: 'https://images.pexels.com/photos/669619/pexels-photo-669619.jpeg?auto=compress&cs=tinysrgb&w=900',
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: _lime.withValues(alpha: 0.15)),
          errorWidget: (_, __, ___) => Container(color: _lime.withValues(alpha: 0.15)),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withValues(alpha: 0.2), _bg.withValues(alpha: 0.97)],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36, height: 36,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF3F4F6)),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF374151), size: 16),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 24, left: 20,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _lime.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _lime.withValues(alpha: 0.5), width: 1),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.download_rounded, color: _limeLight, size: 12),
                const SizedBox(width: 6),
                Text('REPORTS & DATA', style: TextStyle(color: _limeLight, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
              ]),
            ),
            const SizedBox(height: 10),
            Text('Your Data,\nYour Way', style: TextStyles.displaySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 30, height: 1.1)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildExportGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: _exportTypes.map((t) => _ExportTypeCard(type: t)).toList(),
    );
  }

  Widget _buildPrivacyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAF0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(shape: BoxShape.circle, color: _lime.withValues(alpha: 0.1)),
          child: Icon(Icons.lock_rounded, color: _limeLight, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('End-to-end encrypted', style: TextStyle(color: _limeLight, fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text(
              'All exported data is encrypted and accessible only to you. Chronos never shares your personal data with third parties.',
              style: TextStyle(color: Color(0xFF6B7080), fontSize: 12, height: 1.5),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _sectionTitle(String t) =>
      Text(t, style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 16, fontWeight: FontWeight.w700));
}

class _Report {
  final String title;
  final String period;
  final IconData icon;
  final Color color;
  final String format;
  const _Report(this.title, this.period, this.icon, this.color, this.format);
}

class _ReportCard extends StatelessWidget {
  final _Report report;
  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: report.color.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(shape: BoxShape.circle, color: report.color.withValues(alpha: 0.1)),
          child: Icon(report.icon, color: report.color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(report.title, style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 13.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(report.period, style: const TextStyle(color: Color(0xFF6B7080), fontSize: 12)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: report.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: report.color.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.download_rounded, color: report.color, size: 13),
            const SizedBox(width: 4),
            Text(report.format, style: TextStyle(color: report.color, fontSize: 11, fontWeight: FontWeight.w700)),
          ]),
        ),
      ]),
    );
  }
}

class _ExportType {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _ExportType(this.title, this.subtitle, this.icon, this.color);
}

class _ExportTypeCard extends StatelessWidget {
  final _ExportType type;
  const _ExportTypeCard({required this.type});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: type.color.withValues(alpha: 0.25), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(shape: BoxShape.circle, color: type.color.withValues(alpha: 0.12)),
            child: Icon(type.icon, color: type.color, size: 16),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(type.title, style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 12, fontWeight: FontWeight.w700)),
            Text(type.subtitle, style: const TextStyle(color: Color(0xFF6B7080), fontSize: 10)),
          ]),
        ]),
      ),
    );
  }
}
