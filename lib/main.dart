import 'package:flutter/material.dart';
import 'package:flutter_app/home_page.dart';

void main() async {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 132, 231, 74),
          // ···
          brightness: Brightness.light,
        )),
        debugShowCheckedModeBanner: false,
        home: const HomePage());
  }
}
