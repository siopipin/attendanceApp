import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:presensi_app/main.dart';
import 'package:presensi_app/screens/home/message_page.dart';
import 'package:presensi_app/utils/attendance_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String nokartu;
  const HomeScreen({
    super.key,
    required this.nokartu,
    required this.cameras,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraController _cameraController;
  TextEditingController ctrlID = TextEditingController();
  XFile? picture;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future initCamera() async {
    _cameraController =
        CameraController(widget.cameras[1], ResolutionPreset.medium);
    try {
      await _cameraController.initialize().then((_) async {
        if (!mounted) return;
        setState(() {});

        // Menunggu beberapa detik sebelum mengambil gambar,
        // asumsi kamera akan fokus dalam waktu ini
        Future.delayed(Duration(milliseconds: 500), () {
          takePicture();
        });
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await _cameraController.setFlashMode(FlashMode.off);
      XFile imgFile = await _cameraController.takePicture();
      setState(() {
        picture = imgFile;
        print('Letak gambar: ${picture!.path}');
      });

      await Future.delayed(const Duration(seconds: 1),
          () async => await postAttendance(widget.nokartu));
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  Future postAttendance(nokartu) async {
    final provider = context.read<AttendanceProvider>();
    await context
        .read<AttendanceProvider>()
        .apiPostAttendance(no_kartu: nokartu, capture: picture!.path)
        .then((value) async {
      if (provider.statePage == StatePage.loaded) {
        // provider.setResultData = "Tidak ada kartu yang terdeteksi";
        provider.setKartuTerdeteksi = false;

        setState(() {
          picture = null;
        });
        print("===== Response : $value");
        navigateToMessagePage(value);
      } else {
        final player = AudioPlayer();
        await player.play(AssetSource('audios/wrong.mp3'));
        navigateToMyApp();
      }
    });
  }

  navigateToMyApp() {
    return Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
        (route) => false);
  }

  navigateToMessagePage(status) {
    return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessagePage(
            status: status,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(children: [
            Align(
              child: (_cameraController.value.isInitialized)
                  ? CameraPreview(_cameraController)
                  : Container(
                      color: Colors.black,
                      child: const Center(child: CircularProgressIndicator())),
            ),
            Align(
              alignment: Alignment.topRight,
              child: picture == null
                  ? Container(
                      width: 100,
                      height: 145,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_outline_sharp,
                            size: 50,
                          ),
                          Text(
                            "Photo result",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 10,
                            ),
                          )
                        ],
                      ),
                    )
                  : Container(
                      margin: EdgeInsets.only(right: 20, top: 20),
                      width: 100,
                      height: 145,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10)),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.file(
                            File(picture!.path),
                            fit: BoxFit.cover,
                          )),
                    ),
            ),
          ]),
        ));
  }
}
