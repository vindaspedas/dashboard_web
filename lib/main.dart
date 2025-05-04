import 'package:flutter/material.dart';
import 'pages/dashboard_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard Web',
      debugShowCheckedModeBanner: false,
      home: DashboardPage(),
    );
  }
}