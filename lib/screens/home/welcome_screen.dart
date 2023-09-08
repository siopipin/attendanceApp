import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presensi_app/screens/home/home_screen.dart';
import 'package:presensi_app/screens/home/widgets/time_widget.dart';
import 'package:presensi_app/utils/attendance_provider.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const WelcomeScreen({
    super.key,
    required this.cameras,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? value;
  List<CameraDescription>? cameras;
  FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    setTime();
    super.initState();
  }

  setValue(val) async {
    final player = AudioPlayer();
    await player.play(AssetSource('audios/ping.mp3'));

    var provider = context.read<AttendanceProvider>();
    provider.setNoKartu = val;

    // "0314008171"
    var value = int.parse(provider.noKartu);
    String hex = value.toRadixString(16).padLeft(8, "0");

    List<String> hexChunks = [];
    String reversedHex = "";

    for (int i = 0; i < hex.length; i += 2) {
      hexChunks.add(hex.substring(i, i + 2));
    }

    for (int i = hexChunks.length - 1; i >= 0; i--) {
      reversedHex += hexChunks[i];
    }

    print('Reversed Hex: $reversedHex');

    navigateToCamera(reversedHex.toUpperCase());
  }

  navigateToCamera(convertedHex) {
    return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(
                  nokartu: convertedHex,
                  cameras: widget.cameras,
                )));
  }

  //Time
  String? _timeString;
  Timer? _timer;
  setTime() {
    _timeString = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(Duration(seconds: 1), (timer) => _getTime());
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('hh:mm:ss').format(dateTime);
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Attendance App'),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(60),
            ),
          ),
          backgroundColor: const Color(0xff01a89f),
          elevation: 0,
        ),
        body: ListView(
          children: [
            const SizedBox(height: 50),

            //image
            Image.asset('assets/images/tap-img.gif',
                width: MediaQuery.of(context).size.width / 2 + 200),

            // const SizedBox(height: 10),

            //text
            const Text(
              textAlign: TextAlign.center,
              "Tap Kartu Anda",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            // version

            const SizedBox(height: 50),
            TimeWidget(timeString: _timeString!),
            const SizedBox(height: 10),

            const Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  children: [
                    Text(
                      "Powered By",
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "NEOSCHOOL INDONESIA",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "\nVersion 1.0",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w100),
                    ),
                  ],
                )),

            TextField(
              controller: provider.ctrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              onChanged: (val) async {
                if (val.length >= 10) {
                  setValue(val);
                }
              },
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ],
        ));
  }
}
