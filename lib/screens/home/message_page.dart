import 'package:flutter/material.dart';
import 'package:presensi_app/main.dart';

class MessagePage extends StatefulWidget {
  final int status;
  const MessagePage({super.key, required this.status});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  void initState() {
    super.initState();
    timer();
  }

  timer() {
    Future.delayed(
        const Duration(milliseconds: 2500),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const MyApp())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              minRadius: 80,
              backgroundColor: const Color.fromARGB(255, 240, 231, 242),
              child: widget.status == 1
                  ? Image.asset('assets/images/verified.gif')
                  : widget.status == 2
                      ? Image.asset('assets/images/happy.gif')
                      : widget.status == 3
                          ? Image.asset('assets/images/in-love.gif')
                          : widget.status == 4
                              ? Image.asset('assets/images/party.gif')
                              : widget.status == 5
                                  ? Image.asset('assets/images/cry.gif')
                                  : Icon(Icons.close),
            ),
            const SizedBox(height: 30),
            Text(
              "PRESENCE MOBILE",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              "Terima kasih telah melakukan presensi,\nsampai jumpa lagi!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            )
          ]),
    );
  }
}
