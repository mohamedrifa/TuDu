import 'package:flutter/material.dart';

class QuickLinks extends StatefulWidget {
  final bool quickLinksEnabled;
  final ValueChanged<bool> onToggle;

  const QuickLinks({
    Key? key,
    required this.quickLinksEnabled,
    required this.onToggle,
  }) : super(key: key);

  @override
  _QuickLinksState createState() => _QuickLinksState();
}

class _QuickLinksState extends State<QuickLinks> {
  late bool isEnabled;

  Color containerColor = Colors.transparent;
  double rightOffset = -312; // Start off-screen

  @override
  void initState() {
    super.initState();
    isEnabled = widget.quickLinksEnabled;

    // Show panel after short delay
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      setState(() {
        containerColor = const Color.fromARGB(69, 0, 0, 0);
        rightOffset = 0;
      });
    });
  }

  void _toggleQuickLinks() {
    if (!mounted) return;
    setState(() {
      isEnabled = !isEnabled;
    });
    widget.onToggle(isEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background tap closes panel
        GestureDetector(
          onTap: () {
            if (!mounted) return;
            setState(() {
              containerColor = Colors.transparent;
              rightOffset = -312; // Slide out
            });

            // Wait for animation to finish
            Future.delayed(const Duration(milliseconds: 300), () {
              if (!mounted) return;
              _toggleQuickLinks();
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: double.infinity,
            color: containerColor,
          ),
        ),

        // Sliding panel
        AnimatedPositioned(
          key: const ValueKey('quickLinksPanel'),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          top: 0,
          right: rightOffset,
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: 312,
            decoration: BoxDecoration(
              color: const Color(0xFF313036),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
            ), 
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 82),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quick Links",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: const Color(0xFFFED289),
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFFFED289),
                        decorationStyle: TextDecorationStyle.solid, 
                      ),
                    ),
                    const SizedBox(height: 24),
                    Material(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(5),
                        onTap: () => {

                        },
                        child: Text(
                          "Importants",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: const Color(0xFFFED289),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Task On Other Days",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: const Color(0xFFFED289),
                      ),
                    ),
                  ],
                ),
              ),
            ) 
          ),
        ),
      ],
    );
  }
}
