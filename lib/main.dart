import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:presensi_app/screens/home/home_screen.dart';
import 'package:presensi_app/screens/home/welcome_screen.dart';
import 'package:presensi_app/utils/attendance_provider.dart';
import 'package:provider/provider.dart';

late List<CameraDescription> _camera;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _camera = await availableCameras();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AttendanceProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
