import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:input_with_keyboard_control/input_with_keyboard_control.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presensi_app/screens/home/home_screen.dart';
import 'package:presensi_app/screens/home/message_page.dart';
import 'package:presensi_app/screens/home/widgets/textfield_customer.dart';
import 'package:presensi_app/screens/home/widgets/time_widget.dart';
import 'package:presensi_app/utils/attendance_provider.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

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
  TextEditingController ctrl = TextEditingController();

  //handle onchangeTextfield
  FocusNode _focusNode = FocusNode();
  StreamController<String> _streamController = StreamController<String>();

  @override
  void initState() {
    // setDebounceStream();
    setTime();

    //atudofocus
    Future.delayed(Duration(seconds: 0), () {
      _focusNode.requestFocus(); //auto focus on second text field.
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamController.close();

    super.dispose();
  }

  setDebounceStream() {
    _streamController.stream
        .debounceTime(Duration(milliseconds: 1000))
        .listen((val) async {
      await setValue(val);
      _focusNode.requestFocus(); // Pindahkan fokus kembali ke TextField
    });
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

    // ambil dummy gambar (karena API POST butuh perlu gambar)
    File imageFile = await getImageFileFromAssets();
    await cekPresensi(reversedHex.toUpperCase(), imageFile.path).then(
      (value) {
        print(value);
        if (value[0] == 1 || value[0] == 4) {
          //jika respon statuscode 001 dan 004
          navigateToCamera(reversedHex.toUpperCase());
          ctrl.clear();
        } else {
          navigateToMessagePage(value);
          ctrl.clear();
        }
      },
    );
    ctrl.clear();
  }

  Future cekPresensi(nokartu, path) async {
    final provider = context.read<AttendanceProvider>();
    var values;
    await context
        .read<AttendanceProvider>()
        .apiPostAttendance(no_kartu: nokartu, capture: path)
        .then((value) async {
      if (provider.statePage == StatePage.loaded) {
        provider.setKartuTerdeteksi = false;
        values = value;
      } else {
        final player = AudioPlayer();
        await player.play(AssetSource('audios/wrong.mp3'));
        values = value;
      }
    });
    return values;
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

  navigateToMessagePage(status) {
    return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessagePage(status: status),
        ));
  }

  Future<File> getImageFileFromAssets() async {
    final byteData = await rootBundle.load('assets/images/people.jpg');

    final file = File('${(await getTemporaryDirectory()).path}/people.jpg');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  //Time
  String? _timeString;
  Timer? _timer;
  setTime() {
    _timeString = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _getTime());
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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Neos Tap Box'),
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
            Container(
              child: Image.asset(
                'assets/images/iconhome.png',
              ),
              margin: EdgeInsets.symmetric(horizontal: 60),
            ),
            const SizedBox(height: 50),

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
            const SizedBox(height: 20),

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
              // autofocus: true,
              focusNode: _focusNode,
              controller: ctrl,
              style: const TextStyle(color: Colors.white),
              onChanged: (val) async {
                // _streamController.add(val);
                if (val.length >= 10) {
                  setValue(val);
                }
              },
              decoration: const InputDecoration(border: InputBorder.none),
              cursorColor: Colors.white,
              // readOnly: true,
            ),
          ],
        ));
  }
}
