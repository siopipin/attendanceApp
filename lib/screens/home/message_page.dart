import 'package:flutter/material.dart';
import 'package:presensi_app/main.dart';

class MessagePage extends StatefulWidget {
  final List status;
  final String nokartu;
  const MessagePage({super.key, required this.status, required this.nokartu});

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
        const Duration(seconds: 1),
        () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MyApp()),
            (route) => false));
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
              child: widget.status[0] == 1
                  ? Image.asset('assets/images/verified.gif', width: 230)
                  : widget.status[0] == 2
                      ? Image.asset('assets/images/happy.gif', width: 230)
                      : widget.status[0] == 3
                          ? Image.asset('assets/images/in-love.gif', width: 230)
                          : widget.status[0] == 4
                              ? Image.asset('assets/images/party.gif',
                                  width: 230)
                              : widget.status[0] == 5
                                  ? Image.asset('assets/images/cry.gif',
                                      width: 230)
                                  : Icon(Icons.close),
            ),
            const SizedBox(height: 30),
            Text(
              widget.status[1],
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
            ),
            SizedBox(height: 20),
          ]),
    );
  }
}
