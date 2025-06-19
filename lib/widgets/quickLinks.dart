import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class QuickLinks extends StatefulWidget {
  final bool quickLinksEnabled;
  final ValueChanged<bool> onToggle;
  final String showDate;

  const QuickLinks({
    Key? key,
    required this.quickLinksEnabled,
    required this.onToggle,
    required this.showDate,
  }) : super(key: key);

  @override
  _QuickLinksState createState() => _QuickLinksState();
}

class _QuickLinksState extends State<QuickLinks> {
  late bool isEnabled;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Color containerColor = Colors.transparent;
  double rightOffset = -312; // Start off-screen
  String mediumAlertLocation = " Efefjwfgguggkfbgfbggf";
  String loudAlertLocation = " Efefjwfgguggkfbgfbggf";

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
    DateFormat format = DateFormat("d EEE MMM yyyy");
    DateTime dateTime = format.parse(widget.showDate);
    _selectedDay = dateTime;
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
                    const SizedBox(height: 8),
                    TableCalendar(
                      firstDay: DateTime(2000),
                      lastDay: DateTime(2100),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarStyle: CalendarStyle(
                        selectedDecoration: BoxDecoration(
                          color: Color(0xFFFED289),
                          shape: BoxShape.circle, 
                        ),
                        selectedTextStyle: TextStyle(
                          color: Colors.black, // Sunday date color
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                          fontFamily: 'Quantico',
                        ),
                        todayDecoration: BoxDecoration(
                          color: Colors.white30,
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: TextStyle(
                          color: Colors.white, // Sunday date color
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                          fontFamily: 'Quantico',
                        ),
                        
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextFormatter: (date, locale) =>
                            '${DateFormat.MMM(locale).format(date).toUpperCase()} ${date.year}',
                        titleTextStyle: TextStyle(
                          color: Color(0xFFEBFAF9),
                          fontFamily: 'Quantico', // Your chosen font
                          fontWeight: FontWeight.bold,
                          fontSize: 20, // Customize as needed
                          letterSpacing: 1.5,
                        ),
                        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                      ),
                      calendarBuilders: CalendarBuilders(
                        dowBuilder: (context, day) {
                          final text = DateFormat.E().format(day);
                          if (day.weekday == DateTime.sunday) {
                            return Center(
                              child: Text(
                                text,
                                style: TextStyle(
                                  color: Color.fromARGB(255, 168, 55, 55), // Your custom Sunday color
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          } else if (day.weekday == DateTime.saturday) {
                            return Center(
                              child: Text(
                                text,
                                style: TextStyle(
                                  color: Colors.white54, // Your custom Sunday color
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          } else {
                            return Center(
                              child: Text(
                                text,
                                style: TextStyle(
                                  color: Color(0xFFEBFAF9), // Your custom Sunday color
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                        },
                        defaultBuilder: (context, day, focusedDay) {
                          if (day.weekday == DateTime.sunday) {
                            return Center(
                              child: Container(
                                width: 23,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 171, 86, 86), // Sunday date color
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    fontFamily: 'Quantico',
                                  ),
                                ),
                              ),
                            );
                          } else if(day.weekday == DateTime.saturday) {
                            return Center(
                              child: Container(
                                width: 23,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    fontFamily: 'Quantico',
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Center(
                              child: Container(
                                width: 23,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    color: Color(0xFFEBFAF9),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    fontFamily: 'Quantico',
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        collapsedIconColor: Color(0xFF268D8C),
                        iconColor: Color(0xFF268D8C),
                        backgroundColor: Colors.transparent,
                        collapsedBackgroundColor: Colors.transparent,
                        title: Text(
                          "Total Hours Of Tasks",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Color(0xFFFED289),
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("hello", style: TextStyle(color: Colors.white)),
                                Text("hai", style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.92,),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: Color(0xFFFFFFFF),
                    ),
                    const SizedBox(height: 9.08,),
                    Text(
                      "Notification Tone",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: const Color(0xFFFED289),
                      ),
                    ),
                    const SizedBox(height:24),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(left: 8.24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image(
                                image: AssetImage('assets/mediumAlertOn.png'),
                                width: 35,
                                height: 35,
                              ),
                              const SizedBox(width:12),
                              Text(
                                "Medium Alert",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Color(0xFFEBFAF9),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                ),
                              ),
                              Material(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xFF268D8C),
                                child: InkWell(
                                  onTap: () => {

                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                    child: Text(
                                      "Set",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF0D0C10),
                                        fontSize: 16
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image(
                                image: AssetImage("assets/tone.png"),
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 3),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap:() => {

                                  },
                                  child: Container(
                                    width: 183.97,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border: Border(
                                        left: BorderSide(color: Colors.white, width: 1.0),
                                        right: BorderSide(color: Colors.white, width: 1.0),
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        mediumAlertLocation,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w300,
                                          fontSize: 16,
                                          color: Color(0xFFEBFAF9),
                                        ),
                                      ),
                                    ),
                                  )

                                ),
                              )
                            ],
                          ),



                          const SizedBox(height: 23),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image(
                                image: AssetImage('assets/loudAlertOn.png'),
                                width: 35,
                                height: 35,
                              ),
                              const SizedBox(width:12),
                              Text(
                                "Loud Alert",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Color(0xFFEBFAF9),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                ),
                              ),
                              Material(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xFF268D8C),
                                child: InkWell(
                                  onTap: () => {

                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                    child: Text(
                                      "Set",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF0D0C10),
                                        fontSize: 16
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image(
                                image: AssetImage("assets/tone.png"),
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 3),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap:() => {

                                  },
                                  child: Container(
                                    width: 183.97,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border: Border(
                                        left: BorderSide(color: Colors.white, width: 1.0),
                                        right: BorderSide(color: Colors.white, width: 1.0),
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        loudAlertLocation,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w300,
                                          fontSize: 16,
                                          color: Color(0xFFEBFAF9),
                                        ),
                                      ),
                                    ),
                                  )

                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      
                    )

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
