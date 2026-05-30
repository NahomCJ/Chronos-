import 'package:equatable/equatable.dart';

/// A quick-access action tile on the Shortcuts screen.
class ShortcutAction extends Equatable {
  final String label;
  final String iconAsset;

  const ShortcutAction({
    required this.label,
    required this.iconAsset,
  });

  @override
  List<Object?> get props => [label, iconAsset];
}
