import 'package:flutter/material.dart';
import '../widgets/pressable_button.dart';
/// Show the animated confirm-delete dialog.
/// Usage:
///   await showConfirmDeleteDialog(
///     context,
///     onConfirm: deletetask,
///   );
Future<void> showConfirmDeleteDialog(
  BuildContext context, {
  required VoidCallback onConfirm,
}) {
  return showGeneralDialog(
    context: context,
    barrierLabel: 'Confirm Delete',
    barrierDismissible: true,               // ✅ close when tapping outside
    barrierColor: Colors.black54,           // Dim background
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, secondaryAnimation, _) {
      // Pure slide (no fade). Enter: top->center. Exit: center->top.
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      final slide = Tween<Offset>(
        begin: const Offset(0, -1), // fully offscreen above
        end: Offset.zero,           // centered
      ).animate(curved);

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Align(
            alignment: Alignment.center,
            child: SlideTransition(
              position: slide,
              child: _ConfirmDeleteCard(
                onConfirm: () {
                  Navigator.of(context).pop();
                  onConfirm();
                },
                onCancel: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _ConfirmDeleteCard extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _ConfirmDeleteCard({
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF313036),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 19.77),
            const Text(
              "Are You Sure ?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFFED289),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "all consecutive days of this task also got deleted",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFF4F4F5),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PressableButton(
                  label: "No",
                  normalColor: const Color(0xFF313036),  // dark gray
                  pressedColor: const Color(0xFF82808E), // lighter gray when pressed
                  onPressed: onCancel,
                ),
                PressableButton(
                  label: "Yes! Delete",
                  normalColor: const Color(0xFF313036),  // dark gray
                  pressedColor: const Color(0xFF268D8C), // teal when pressed
                  onPressed: onConfirm,
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
