import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/route_constants.dart';
import '../../features/panther_ai/presentation/widgets/chris_voice_orb.dart';

/// Persistent "Ask Chris" floating button  placed in floatingActionButton
/// or manually as a Positioned widget in a Stack.
/// Opens the PantherAI chat so Chris can handle voice/text commands
/// (transfer, exchange, check balance, etc.) with final user confirmation.
class ChrisFab extends StatelessWidget {
  const ChrisFab({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteConstants.pantherAiChat.toPath),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3A2A0E), Color(0xFF1A0A00)],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFDC8F4A).withValues(alpha: 0.55),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFDC8F4A).withValues(alpha: 0.35),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: ChrisVoiceOrb(state: OrbState.idle, size: 32),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Same as ChrisFab but positioned inside a Stack at bottom-right,
/// above the bottom nav. Use this inside pages that already use Stack body.
class ChrisFabPositioned extends StatelessWidget {
  const ChrisFabPositioned({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 100,
      child: const ChrisFab(),
    );
  }
}
