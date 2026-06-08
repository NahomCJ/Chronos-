import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import '../../../../core/widgets/chris_home_fab.dart';

class _AtmData {
  final String name;
  final String address;
  final String distance;
  final String walkTime;
  final String driveTime;
  final bool available;
  final String network;
  const _AtmData(this.name, this.address, this.distance, this.walkTime, this.driveTime, this.available, this.network);
}

const _kAtms = [
  _AtmData('Chase Bank ATM', '123 Main St, Downtown', '0.3 mi', '6 min', '2 min', true, 'Visa · Mastercard'),
  _AtmData('Citibank ATM', '321 Elm St, Shopping Mall', '0.7 mi', '14 min', '3 min', false, 'Visa · Plus'),
  _AtmData('US Bank ATM', '654 Maple Dr, Riverside', '1.1 mi', '22 min', '5 min', true, 'All networks'),
  _AtmData('Wells Fargo ATM', '88 Oak Ave, Midtown', '1.4 mi', '28 min', '6 min', true, 'Visa · Mastercard'),
];

class FindAtmPage extends StatefulWidget {
  const FindAtmPage({super.key});

  @override
  State<FindAtmPage> createState() => _FindAtmPageState();
}

class _FindAtmPageState extends State<FindAtmPage> {
  int _filterIndex = 0;
  static const _filters = ['All ATMs', 'Chronos ATMs', 'Bank ATMs', 'Free Withdrawal'];

  List<_AtmData> get _filtered => _filterIndex == 0
      ? _kAtms
      : _filterIndex == 3
          ? _kAtms.where((a) => a.available).toList()
          : _kAtms;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 90),
        child: const ChrisHomeFab(),
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: 4,
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
          Positioned.fill(child: Image.asset('assets/background.png', fit: BoxFit.cover)),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header
                _buildHeader(context),
                // Map placeholder
                _buildMapPlaceholder(),
                // Filter chips
                _buildFilters(),
                // ATM list
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _buildAtmCard(context, _filtered[i]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RouteConstants.home.toPath);
              }
            },
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.white.withValues(alpha: 0.5), size: 18),
                  const SizedBox(width: 8),
                  Text('Search nearby ATMs...', style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4), fontSize: 13,
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.my_location, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF1A2035),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Fake map grid
            CustomPaint(painter: _MapGridPainter(), size: const Size.fromHeight(180)),
            // Location dot
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF3B82F6), width: 2),
                    ),
                    child: const Icon(Icons.my_location, color: Color(0xFF3B82F6), size: 22),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Your location', style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ],
              ),
            ),
            // ATM pins
            Positioned(top: 40, left: 60,
              child: _mapPin(available: true)),
            Positioned(top: 80, right: 50,
              child: _mapPin(available: true)),
            Positioned(bottom: 40, left: 100,
              child: _mapPin(available: false)),
            // Top info bar
            Positioned(
              top: 10, left: 10, right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF10B981), size: 14),
                    const SizedBox(width: 6),
                    const Text('4 ATMs within 1.5 mi', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('Live', style: TextStyle(color: const Color(0xFF10B981), fontSize: 11)),
                    const SizedBox(width: 4),
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapPin({required bool available}) {
    final color = available ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color: color, shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)],
      ),
      child: const Icon(Icons.account_balance, color: Colors.white, size: 13),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.asMap().entries.map((e) {
            final sel = _filterIndex == e.key;
            return GestureDetector(
              onTap: () => setState(() => _filterIndex = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: sel ? Colors.white : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? Colors.white : Colors.white.withValues(alpha: 0.15)),
                ),
                child: Text(e.value, style: TextStyle(
                  color: sel ? Colors.black : Colors.white.withValues(alpha: 0.7),
                  fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                )),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAtmCard(BuildContext context, _AtmData atm) {
    final statusColor = atm.available ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final statusLabel = atm.available ? 'Available' : 'Busy';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance, color: Colors.orange, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(atm.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(atm.address, style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Distance + Network
          Row(
            children: [
              Icon(Icons.near_me, color: Colors.white.withValues(alpha: 0.5), size: 14),
              const SizedBox(width: 4),
              Text(atm.distance, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
              const SizedBox(width: 14),
              Icon(Icons.credit_card, color: Colors.white.withValues(alpha: 0.5), size: 14),
              const SizedBox(width: 4),
              Text(atm.network, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
              const Spacer(),
              Icon(Icons.access_time, color: Colors.white.withValues(alpha: 0.4), size: 13),
              const SizedBox(width: 3),
              Text('24/7', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
            ],
          ),

          const SizedBox(height: 12),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
          const SizedBox(height: 12),

          // Walk / Ride buttons
          Row(
            children: [
              Expanded(
                child: _directionBtn(
                  icon: Icons.directions_walk,
                  label: 'Walk',
                  time: atm.walkTime,
                  color: const Color(0xFF10B981),
                  onTap: () => _showDirections(context, atm.name, 'walking'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _directionBtn(
                  icon: Icons.directions_car,
                  label: 'Ride',
                  time: atm.driveTime,
                  color: const Color(0xFF3B82F6),
                  onTap: () => _showDirections(context, atm.name, 'driving'),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _showDirections(context, atm.name, 'maps'),
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: const Icon(Icons.map_outlined, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _directionBtn({
    required IconData icon,
    required String label,
    required String time,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
                Text(time, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDirections(BuildContext context, String name, String mode) {
    final labels = {'walking': '🚶 Walking', 'driving': '🚗 Driving', 'maps': '🗺 Maps'};
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${labels[mode]} directions to $name'),
      backgroundColor: const Color(0xFF3B82F6),
    ));
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    // Horizontal lines
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    // Vertical lines
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Road lines
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height * 0.45), Offset(size.width, size.height * 0.45), roadPaint);
    canvas.drawLine(Offset(size.width * 0.35, 0), Offset(size.width * 0.35, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.7, size.height), roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
