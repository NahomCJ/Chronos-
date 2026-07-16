import 'package:flutter/material.dart';

class ErrorToast {
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context, String message,
      {Color? backgroundColor, Color? textColor}) {
    final overlayState = Overlay.of(context);

    // Remove existing overlay entry if it exists
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16.0,
        width: MediaQuery.of(context).size.width,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: (details) {
            if (details.delta.dx > 0) {
              // Swiped from left to right, remove the overlay
              _removeOverlay();
            }
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: backgroundColor ?? Colors.red,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8, right: 8, top: 4, bottom: 4),
                    child: Text(
                      message,
                      style: TextStyle(
                        color: textColor ?? Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(_overlayEntry!);

    Future.delayed(const Duration(seconds: 5), () {
      _removeOverlay();
    });
  }

  static void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }
}

class ToastNotifier extends ChangeNotifier {
  String? _message;
  Color backgroundColor = Colors.red;
  Color textColor = Colors.white;

  String? get message => _message;

  void show(String message,
      {Color? background = Colors.red, Color? text = Colors.white}) {
    _message = message;
    backgroundColor = background ?? Colors.red;
    textColor = text ?? Colors.white;
    notifyListeners();

    Future.delayed(const Duration(seconds: 4), () {
      _message = null;
      notifyListeners();
    });
  }
}

final toastNotifier = ToastNotifier();
