import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/chris_action_service.dart';
import '../services/tts_service.dart';

class VoiceConfirmationSheet extends StatefulWidget {
  final ChrisActionPlan plan;
  final VoidCallback? onDismiss;

  const VoiceConfirmationSheet({
    super.key,
    required this.plan,
    this.onDismiss,
  });

  static Future<bool?> show(BuildContext context, ChrisActionPlan plan) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => VoiceConfirmationSheet(plan: plan),
    );
  }

  @override
  State<VoiceConfirmationSheet> createState() => _VoiceConfirmationSheetState();
}

class _VoiceConfirmationSheetState extends State<VoiceConfirmationSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  bool _isExecuting = false;
  ChrisActionResult? _result;

  static const _bg = Color(0xFF0D0D1A);
  static const _teal = Color(0xFF14B8A6);
  static const _amber = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    // Speak the plan title
    Future.delayed(const Duration(milliseconds: 300), () {
      TtsService().speak('Here\'s what I\'ll do. ${widget.plan.title}. ${widget.plan.subtitle}. Should I proceed?');
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    TtsService().stop();
    super.dispose();
  }

  Future<void> _confirm() async {
    setState(() => _isExecuting = true);
    TtsService().speak('On it.');
    final result = await widget.plan.execute();
    if (mounted) {
      setState(() {
        _isExecuting = false;
        _result = result;
      });
      TtsService().speak(result.message);
      if (result.success) {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context, true);
      }
    }
  }

  void _cancel() {
    TtsService().stop();
    TtsService().speak('Okay, cancelled.');
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: const BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 20),
                _buildDetails(),
                if (widget.plan.warning != null) ...[
                  const SizedBox(height: 14),
                  _buildWarning(widget.plan.warning!),
                ],
                const SizedBox(height: 24),
                if (_result != null)
                  _buildResult(_result!)
                else
                  _buildButtons(),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _teal.withValues(alpha: 0.12),
            border: Border.all(color: _teal.withValues(alpha: 0.3), width: 1.5),
          ),
          child: const Icon(Icons.record_voice_over_rounded, color: _teal, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.plan.title,
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                widget.plan.subtitle,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: widget.plan.details.map((d) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(d.$1, style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13)),
                Text(d.$2, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWarning(String warning) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _amber.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: _amber, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(warning, style: TextStyle(color: _amber.withValues(alpha: 0.9), fontSize: 12, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _isExecuting ? null : _cancel,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              alignment: Alignment.center,
              child: Text('Cancel', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: _isExecuting ? null : _confirm,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: _teal,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: _teal.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 4))],
              ),
              alignment: Alignment.center,
              child: _isExecuting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Confirm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResult(ChrisActionResult result) {
    final isSuccess = result.success;
    final color = isSuccess ? _teal : const Color(0xFFEF4444);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(isSuccess ? Icons.check_circle_rounded : Icons.error_rounded, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(result.message, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
