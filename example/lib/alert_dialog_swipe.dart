import 'package:flutter/material.dart';
import 'package:swipe_widget/swipe_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SwipeWidget(
            key: UniqueKey(),
            onSwipe: () => Future.delayed(const Duration(milliseconds: 300), () => setState(() {})),
            child: AlertDialog(
              title: const Text('SwipeWidget'),
              content: const Text('Wait! You can swipe me instead.\nIt\'s more fun.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {},
                ),
              ],
            )),
      ),
    );
  }
}
