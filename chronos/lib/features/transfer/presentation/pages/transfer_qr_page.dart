import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class TransferQrPage extends StatefulWidget {
  const TransferQrPage({super.key, this.initialTab = 0});
  final int initialTab; // 0 = show QR, 1 = scan QR

  @override
  State<TransferQrPage> createState() => _TransferQrPageState();
}

class _TransferQrPageState extends State<TransferQrPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  late AnimationController _scanAnim;
  MobileScannerController? _cameraCtrl;
  bool _scanned = false;

  static const _qrData = 'chronos://pay/user/alexander_hubert_001';

  @override
  void initState() {
    super.initState();
    _tab = TabController(
        length: 2, vsync: this, initialIndex: widget.initialTab);
    _scanAnim = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    _tab.addListener(() {
      if (_tab.index == 1) {
        _startCamera();
      } else {
        _stopCamera();
      }
    });
    if (widget.initialTab == 1) _startCamera();
  }

  void _startCamera() {
    _cameraCtrl ??= MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
    setState(() => _scanned = false);
  }

  void _stopCamera() {
    _cameraCtrl?.stop();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null) return;
    _scanned = true;
    _cameraCtrl?.stop();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ScanResultSheet(
        code: code,
        onDismiss: () {
          Navigator.pop(context);
          setState(() => _scanned = false);
          _cameraCtrl?.start();
        },
      ),
    );
  }

  @override
  void dispose() {
    _tab.dispose();
    _scanAnim.dispose();
    _cameraCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: Stack(
        children: [
          Positioned.fill(
              child:
                  Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
          Positioned.fill(
              child: Container(
                  color: Colors.black.withValues(alpha: 0.45))),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 8),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tab,
                    children: [
                      _buildShowTab(),
                      _buildScanTab(),
                    ],
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
      padding: const EdgeInsets.fromLTRB(16, 12, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 22),
          ),
          const Expanded(
            child: Text('QR Code',
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

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: TabBar(
              controller: _tab,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: const Color(0xFF0A0A14),
              unselectedLabelColor: Colors.white.withValues(alpha: 0.55),
              labelStyle: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'My QR Code'),
                Tab(text: 'Scan QR'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShowTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text('Share your QR code to receive money',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 13),
              textAlign: TextAlign.center),
          const SizedBox(height: 28),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16)),
                      child: QrImageView(
                        data: _qrData,
                        version: QrVersions.auto,
                        size: 180,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Color(0xFF0A0A14)),
                        dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Color(0xFF0A0A14)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Alexander Hubert',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('@alexander.h',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 13)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14B8A6)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFF14B8A6)
                                .withValues(alpha: 0.35)),
                      ),
                      child: const Text('Chronos Pay',
                          style: TextStyle(
                              color: Color(0xFF14B8A6),
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                  child: _ActionBtn(
                icon: Icons.share_rounded,
                label: 'Share',
                color: const Color(0xFF14B8A6),
                onTap: () {},
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: _ActionBtn(
                icon: Icons.download_rounded,
                label: 'Save',
                color: const Color(0xFF8B5CF6),
                onTap: () {},
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScanTab() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Text('Point the camera at a Chronos QR code',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 13),
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_cameraCtrl != null)
                      MobileScanner(
                        controller: _cameraCtrl!,
                        onDetect: _onDetect,
                        errorBuilder: (_, error) => _CameraErrorView(
                            error: error.errorDetails?.message ?? 'Camera error'),
                      )
                    else
                      Container(color: const Color(0xFF111122)),
                    // Corner frame overlay
                    CustomPaint(painter: _ScanFramePainter()),
                    // Animated scan line
                    AnimatedBuilder(
                      animation: _scanAnim,
                      builder: (_, __) => Positioned(
                        top: 16 +
                            (_scanAnim.value *
                                (MediaQuery.of(context).size.width -
                                    64 -
                                    32)),
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          margin:
                              const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color(0xFF14B8A6),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF14B8A6)
                                    .withValues(alpha: 0.6),
                                blurRadius: 8,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (!kIsWeb)
          IconButton(
            onPressed: () => _cameraCtrl?.toggleTorch(),
            icon: const Icon(Icons.flash_on_rounded,
                color: Colors.white54, size: 26),
            tooltip: 'Toggle flashlight',
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Camera error view
// ─────────────────────────────────────────────────────────────────────────────

class _CameraErrorView extends StatelessWidget {
  const _CameraErrorView({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF111122),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.camera_alt_rounded,
                  color: Colors.white38, size: 48),
              const SizedBox(height: 12),
              const Text('Camera access needed',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(error,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scan result sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ScanResultSheet extends StatelessWidget {
  const _ScanResultSheet({required this.code, required this.onDismiss});
  final String code;
  final VoidCallback onDismiss;

  String get _displayName {
    if (code.startsWith('chronos://pay/user/')) {
      return code.replaceFirst('chronos://pay/user/', '').replaceAll('_', ' ');
    }
    return code;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF14B8A6).withValues(alpha: 0.15),
            ),
            child: const Icon(Icons.qr_code_2_rounded,
                color: Color(0xFF14B8A6), size: 32),
          ),
          const SizedBox(height: 16),
          const Text('QR Code Detected',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(_displayName,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDismiss,
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
          const SizedBox(height: 12),
          TextButton(
            onPressed: onDismiss,
            child: Text('Scan Again',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom painters
// ─────────────────────────────────────────────────────────────────────────────

class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF14B8A6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const r = 16.0;
    const len = 28.0;
    const pad = 16.0;

    // top-left
    canvas.drawLine(Offset(pad, pad + r + len), Offset(pad, pad + r), paint);
    canvas.drawArc(Rect.fromLTWH(pad, pad, r * 2, r * 2), math.pi, math.pi / 2,
        false, paint);
    canvas.drawLine(Offset(pad + r, pad), Offset(pad + r + len, pad), paint);

    // top-right
    final x = size.width - pad;
    canvas.drawLine(
        Offset(x, pad + r + len), Offset(x, pad + r), paint);
    canvas.drawArc(
        Rect.fromLTWH(x - r * 2, pad, r * 2, r * 2), 0, -math.pi / 2,
        false, paint);
    canvas.drawLine(
        Offset(x - r, pad), Offset(x - r - len, pad), paint);

    // bottom-left
    final y = size.height - pad;
    canvas.drawLine(
        Offset(pad, y - r - len), Offset(pad, y - r), paint);
    canvas.drawArc(
        Rect.fromLTWH(pad, y - r * 2, r * 2, r * 2), math.pi, -math.pi / 2,
        false, paint);
    canvas.drawLine(
        Offset(pad + r, y), Offset(pad + r + len, y), paint);

    // bottom-right
    canvas.drawLine(
        Offset(x, y - r - len), Offset(x, y - r), paint);
    canvas.drawArc(
        Rect.fromLTWH(x - r * 2, y - r * 2, r * 2, r * 2), 0, math.pi / 2,
        false, paint);
    canvas.drawLine(
        Offset(x - r, y), Offset(x - r - len, y), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Action button
// ─────────────────────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  const _ActionBtn(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
