import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(XChangeLearnApp());
}

class XChangeLearnApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(bodyLarge: TextStyle(fontSize: 18)),
      ),
      home: SplashScreen(),
    );
  }
}
