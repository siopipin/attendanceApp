import 'package:flutter/material.dart';

class TimeWidget extends StatelessWidget {
  final String timeString;
  const TimeWidget({super.key, required this.timeString});

  @override
  Widget build(BuildContext context) {
    return Text(
      timeString,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    );
  }
}
