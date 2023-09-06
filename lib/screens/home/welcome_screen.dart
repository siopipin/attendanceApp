import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:presensi_app/screens/home/home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final List<CameraDescription>? cameras;
  const WelcomeScreen({
    super.key,
    this.cameras,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  TextEditingController ctrl = TextEditingController();
  var val;
  List<CameraDescription>? cameras;
  @override
  void initState() {
    ctrl = TextEditingController(text: " ");
    val = "";
    super.initState();
  }

  setValue(val) {
    setState(() {
      ctrl = TextEditingController(text: val);
      val = val;
    });

    var value = val;
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

    navigateToCamera(reversedHex);
  }

  navigateToCamera(convertedHex) {
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(
                  nokartu: convertedHex,
                  cameras: widget.cameras,
                ),
            fullscreenDialog: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Attendance App'),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(60),
            ),
          ),
          elevation: 0,
        ),
        body: ListView(
          children: [
            const SizedBox(height: 50),

            //image
            Image.asset('assets/images/tapcard.gif',
                width: MediaQuery.of(context).size.width / 2 + 100),

            const SizedBox(height: 10),

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
            const SizedBox(height: 100),

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
                      "\nVersion 1.1",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w100),
                    ),
                  ],
                )),

            TextField(
              autofocus: true,
              onChanged: (val) {
                setValue(val);
              },
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ],
        ));
  }
}
