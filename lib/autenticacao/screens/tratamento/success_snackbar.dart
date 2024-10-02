import 'package:flutter/material.dart';

class MensagemDeSucesso {
  void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}

class TopBar {
  static OverlayEntry? _currentOverlayEntry;

  static void show(BuildContext context, String message, Color color,
      {Duration duration = const Duration(seconds: 3)}) {
    _currentOverlayEntry
        ?.remove(); // Remove a TopBar anterior se estiver sendo exibida
    _currentOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 1,
        left: MediaQuery.of(context).size.width * 0.005,
        right: MediaQuery.of(context).size.width * 0.005,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_currentOverlayEntry!);

    // Remova a TopBar após a duração, se não for indefinida
    if (duration != const Duration(days: 356)) {
      Future.delayed(duration, () => _currentOverlayEntry?.remove());
    }
  }

  static void hide() {
    _currentOverlayEntry?.remove();
    _currentOverlayEntry = null;
  }
}
