import 'package:app_schedule_flutter/Screen/Dashboard.dart';
import 'package:app_schedule_flutter/Screen/Home_screen.dart';
import 'package:app_schedule_flutter/Screen/Login_screen.dart';
import 'package:app_schedule_flutter/Screen/Profile_screen.dart';
import 'package:app_schedule_flutter/Timetable/timetable_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:app_schedule_flutter/Screen/Login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp().then((value) {
    print('Firebase initialized');
  }).catchError((error) {
    print('Firebase initialization error: $error');
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

// Wrapper để kiểm tra trạng thái xác thực
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return Dashboad(); // Nếu người dùng đã đăng nhập
        } else {
          return LoginScreen(); // Nếu người dùng chưa đăng nhập
        }
      },
    );
  }
}
