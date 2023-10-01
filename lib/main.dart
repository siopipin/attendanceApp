import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:mifare_nfc_reader/mifare_nfc_reader.dart';
// import 'package:nfc_manager/nfc_manager.dart';
import 'package:presensi_app/screens/home/home_screen.dart';
import 'package:presensi_app/screens/home/welcome_screen.dart';
import 'package:presensi_app/utils/attendance_provider.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

late List<CameraDescription> _camera;
late bool isAvailable;
const channelName = "mifare_nfc_reader";
const methodChannel = MethodChannel(channelName);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WakelockPlus.enable();

  // Check availability
  _camera = await availableCameras();
  // isAvailable = await NfcManager.instance.isAvailable();
  MifareNfcReader.init();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AttendanceProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  void initState() {
    initCam();
    super.initState();
  }

  initCam() async {
    _camera = await availableCameras();
    // isAvailable = await NfcManager.instance.isAvailable();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: provider.enableDarkMode ? provider.dark : provider.light,
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(cameras: _camera),
    );
  }
}
