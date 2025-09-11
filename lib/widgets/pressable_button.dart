import 'package:flutter/material.dart';

class PressableButton extends StatefulWidget {
  final String label;
  final Color normalColor;
  final Color pressedColor;
  final VoidCallback onPressed;

  const PressableButton({
    required this.label,
    required this.normalColor,
    required this.pressedColor,
    required this.onPressed,
  });

  @override
  State<PressableButton> createState() => PressableButtonState();
}

class PressableButtonState extends State<PressableButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: _isPressed ? widget.pressedColor : widget.normalColor,
            borderRadius: widget.label == "No"
                ? const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                  )
                : const BorderRadius.only(
                    bottomRight: Radius.circular(25),
                  ),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Color(0xFFEBFAF9),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

