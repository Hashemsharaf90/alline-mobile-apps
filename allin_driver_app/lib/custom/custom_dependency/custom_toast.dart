import 'package:flutter/material.dart';
import 'dart:async';

class Toast {
  // Constants for duration
  static const int lengthShort = 2; // Short duration in seconds
  static const int lengthLong = 5; // Long duration in seconds

  // Constants for gravity
  static const ToastGravity center = ToastGravity.CENTER;
  static const ToastGravity bottom = ToastGravity.BOTTOM;
  static const ToastGravity top = ToastGravity.TOP;

  static void show(
    String msg,
    BuildContext context, {
    int duration = lengthShort,
    ToastGravity gravity = bottom,
    Color backgroundColor = const Color.fromRGBO(0, 0, 0, 0.7),
    TextStyle textStyle = const TextStyle(color: Colors.white, fontSize: 14.0),
    Border? border,
    double backgroundRadius = 8.0,
  }) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: msg,
        gravity: gravity,
        backgroundColor: backgroundColor,
        textStyle: textStyle,
        border: border,
        backgroundRadius: backgroundRadius,
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Timer(Duration(seconds: duration), () {
      overlayEntry.remove();
    });
  }
}

enum ToastGravity {
  TOP,
  BOTTOM,
  CENTER,
}

class _ToastWidget extends StatelessWidget {
  final String message;
  final ToastGravity gravity;
  final Color backgroundColor;
  final TextStyle textStyle;
  final Border? border;
  final double backgroundRadius;

  const _ToastWidget({
    required this.message,
    required this.gravity,
    required this.backgroundColor,
    required this.textStyle,
    this.border,
    required this.backgroundRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: _getAlignment(gravity),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(backgroundRadius),
                  border: border,
                ),
                child: Text(
                  message,
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Determines the alignment for the toast based on the gravity
  Alignment _getAlignment(ToastGravity gravity) {
    switch (gravity) {
      case ToastGravity.TOP:
        return Alignment.topCenter;
      case ToastGravity.BOTTOM:
        return Alignment.bottomCenter;
      case ToastGravity.CENTER:
      default:
        return Alignment.center;
    }
  }
}
