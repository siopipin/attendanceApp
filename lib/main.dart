import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:presensi_app/screens/home/home_screen.dart';
import 'package:presensi_app/screens/home/welcome_screen.dart';
import 'package:presensi_app/utils/attendance_provider.dart';
import 'package:provider/provider.dart';

late List<CameraDescription> _camera;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _camera = await availableCameras();
  var status = await Permission.camera.status;
  print(status);

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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xffFDFEFE),
        primaryColor: Colors.blue,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[800],
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(cameras: _camera),
    );
  }
}
