import 'package:flutter/material.dart';
import 'pages/dashboard_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final DatabaseReference healthScoreRef = FirebaseDatabase.instance.ref().child('health_score');

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDwoWkipnXI-tdSRY8SRFzHtdVsdxsrnmQ",
      authDomain: "greenpulsedash.firebaseapp.com",
      databaseURL: "https://greenpulsedash-default-rtdb.asia-southeast1.firebasedatabase.app",
      projectId: "greenpulsedash",
      storageBucket: "greenpulsedash.firebasestorage.app",
      messagingSenderId: "592045837216",
      appId: "1:592045837216:web:39a29ded84c02b392172c5",
      measurementId: "G-M84QBGR0TZ"
    ),
  );
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