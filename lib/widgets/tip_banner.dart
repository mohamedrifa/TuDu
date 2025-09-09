import 'package:flutter/material.dart';

class TipBanner extends StatefulWidget {
  final bool show;

  const TipBanner({Key? key, required this.show}) : super(key: key);

  @override
  State<TipBanner> createState() => _TipBannerState();
}

class _TipBannerState extends State<TipBanner> {
  bool _visible = false;

  @override
  void didUpdateWidget(covariant TipBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !_visible) {
      _showTip();
    }
  }

  void _showTip() async {
    setState(() => _visible = true);
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      setState(() => _visible = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !_visible, // ignore taps when hidden
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: _visible ? 1.0 : 0.0, // fade in/out
        child: Stack(
          children: [
            // semi-transparent background
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              color: _visible
                  ? const Color.fromARGB(39, 254, 209, 137)
                  : Colors.transparent,
            ),
            // sliding tip banner
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              top: _visible ? 150 : -100,
              left: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFED289),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 79,
                      decoration: const BoxDecoration(
                        color: Color(0xFF268D8C),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          bottomLeft: Radius.circular(5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Image.asset(
                      'assets/tip_logo.png',
                      width: 35,
                      height: 35,
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Plan your day at night before sleep",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF0D0C10),
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
