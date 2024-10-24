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

class NotificacaoCard extends StatefulWidget {
  final String message;
  final Color color;
  final Duration duration;

  const NotificacaoCard({
    Key? key,
    required this.message,
    required this.color,
    this.duration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  _NotificacaoCardState createState() => _NotificacaoCardState();
}

class _NotificacaoCardState extends State<NotificacaoCard> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Exibe o card ao carregar o widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isVisible = true;
      });

      // Remove o card após a duração especificada
      if (widget.duration != Duration.zero) {
        Future.delayed(widget.duration, () {
          if (mounted) {
            setState(() {
              _isVisible = false;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isVisible
        ? Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    widget.message,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          )
        : const SizedBox.shrink(); // Se não estiver visível, retorna um widget vazio
  }
}
