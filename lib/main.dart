import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const MallNavigationApp());
}

class MallNavigationApp extends StatelessWidget {
  const MallNavigationApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '商场导航',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
