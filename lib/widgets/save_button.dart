import 'package:flutter/material.dart';

class SaveButton extends StatefulWidget {
  final bool isEdit;
  final VoidCallback onPressed;

  const SaveButton({super.key, this.isEdit = false, required this.onPressed});

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  bool _pressed = false;

  void _handleTap() {
    setState(() => _pressed = true);

    // Reset back after short delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _pressed = false);
      }
    });

    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // keeps ripple
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(25),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 56,
          width: 130,
          decoration: BoxDecoration(
            color: _pressed ? const Color(0xFF268D8C) : const Color(0xFF0D0C10),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.isEdit ? "Save" : "ADD",
                  style: const TextStyle(
                    color: Color(0xFFEBFAF9),
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.isEdit)
                  Icon(
                    Icons.check,
                    size: 26,
                    color: _pressed ? const Color(0xFF0D0C10) : const Color(0xFF268D8C),
                  ),
                if (!widget.isEdit)
                  Image(
                    image: _pressed ? AssetImage("assets/addTaskIcon1.png"): AssetImage("assets/addTaskIcon.png"), 
                    width: 30, 
                    height: 30
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
