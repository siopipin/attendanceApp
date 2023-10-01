import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presensi_app/screens/home/home_screen.dart';
import 'package:presensi_app/screens/home/message_page.dart';
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
  bool? isLoading;
  String? nfcData = "";
  String? idKartu = "";
  String? statusNfc = "";
  String? value;
  List<CameraDescription>? cameras;
  TextEditingController ctrl = TextEditingController();

  //handle onchangeTextfield
  FocusNode _focusNode = FocusNode();
  StreamController<String> _streamController = StreamController<String>();

  @override
  void initState() {
    // setDebounceStream();

    //atudofocus
    // Future.delayed(const Duration(seconds: 0), () {
    //   _focusNode.requestFocus(); //auto focus on second text field.
    // });
    isLoading = false;

    checkNFC();
    setTime();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamController.close();
    super.dispose();
  }

  //Chech NFC
  Future<void> checkNFC() async {
    bool isAvailable = await NfcManager.instance.isAvailable();

    print('status nfc $isAvailable');
    setState(() {
      statusNfc = isAvailable.toString();
    });
    if (isAvailable) {
      // Start Session
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          await getNFCTagValue(tag);
        },
      );
    } else {
      Fluttertoast.showToast(msg: "NFC tidak tersedia");
    }
  }

  //Get NFCTag Value
  Future<void> getNFCTagValue(NfcTag tag) async {
    // Membaca ID kartu dari instance NfcTag

    var nfcaData = tag.data['nfca'];
    var identifier = nfcaData?['identifier'];

    // var id = tag.data['id']; // ID dalam bentuk byte array

    List<int> identifierDummy = [107, 98, 183, 18];

    // xTODO=> ganti identifierDummy dengan identifier dari tag
    String idString = identifier.map((e) => e.toString()).join();

    setState(() {
      nfcData = identifier.toString();
      idKartu = idString;
    });

    print('Tag ID: $idString');

    if (idString != null) {
      await setValue(idString);
    }

    // Menghentikan sesi setelah membaca tagR
    // NfcManager.instance.stopSession();
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
    //xTODO: ganti ke provider.noKartu
    var value = int.parse(val);
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
    print('hasil hexa ======== ${reversedHex}');
    File imageFile = await getImageFileFromAssets();

    setState(() {
      isLoading = true;
    });
    await cekPresensi(reversedHex.toUpperCase(), imageFile.path).then(
      (value) {
        if (mounted) {
          // Cek apakah State object masih ada di widget tree
          setState(() {
            isLoading = false;
          });
        }
        if (value == null) {
          return null;
        } else if (value[0] == 1 || value[0] == 4) {
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
        .apiCekAttendance(no_kartu: nokartu)
        .then((value) async {
      print('Hasil cek presensi: $value');
      if (provider.statePage == StatePage.loaded) {
        if (value[2] == 200) {
          provider.setKartuTerdeteksi = false;
          values = value;
        } else {
          final player = AudioPlayer();
          await player.play(AssetSource('audios/wrong.mp3'));

          print("ada error-2");
          //munculkan popup error.
          await _showDialogAlert();
          // return null;
        }
      } else {
        final player = AudioPlayer();
        await player.play(AssetSource('audios/wrong.mp3'));
        print("ada error");
        //munculkan popup error.
        await _showDialogAlert();
        values = value;
      }
    });
    return values;
  }

  Future<void> _showDialogAlert() async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          _timer = Timer(Duration(seconds: 2), () {
            Navigator.of(context).pop();
          });
          return AlertDialog(
            title: const Text(
              'Connection Error',
              textAlign: TextAlign.center,
            ),
            content: Container(
              color: Colors.transparent,
              height: 150,
              child: Center(
                child: Image.asset(
                  'assets/images/alarm.gif',
                  width: 230,
                ),
              ),
            ),
          );
        }).then((value) {
      if (_timer!.isActive) {
        _timer!.cancel();
      }
    });
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
    if (mounted) {
      return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessagePage(status: status),
        ),
      );
    }
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
    final prov = context.watch<AttendanceProvider>();
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
          // actions: [
          //   Switch(
          //       value: prov.enableDarkMode,
          //       activeColor: Colors.green,
          //       onChanged: (val) {
          //         print(val);
          //         prov.setBrightness = val;
          //       })
          // ],
        ),
        body: Stack(
          children: [
            ListView(
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

                Text(nfcData ?? ""),
                Text(idKartu ?? "-", style: TextStyle(color: Colors.red)),
                Text("nfc data: ${nfcData ?? "-"}",
                    style: TextStyle(color: Colors.blue)),
                Text("status nfc: ${statusNfc ?? "-"}",
                    style: TextStyle(color: Colors.blue)),

                // version
                SizedBox(height: MediaQuery.of(context).size.height / 2 - 250),
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
              ],
            ),
            if (isLoading!) // variabel isLoading yang Anda definisikan sebelumnya
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ));
  }
}
