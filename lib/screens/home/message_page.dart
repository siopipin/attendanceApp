import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:presensi_app/main.dart';
import 'package:flutter_html/flutter_html.dart';

class MessagePage extends StatefulWidget {
  final List status;
  const MessagePage({super.key, required this.status});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  void initState() {
    setNotif();
    timer();
    super.initState();
  }

  setNotif() async {
    final player = AudioPlayer();
    await player.play(AssetSource('audios/notif.wav'));
  }

  timer() {
    Future.delayed(
        const Duration(seconds: 2),
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
                                  : Image.asset('assets/images/alarm.gif',
                                      width: 230),
            ),
            const SizedBox(height: 30),
            Html(
              data: """
                ${widget.status[1]}
                """,
              style: {
                'html': Style(textAlign: TextAlign.center),
              },
            ),
            const SizedBox(height: 20),
          ]),
    );
  }
}
