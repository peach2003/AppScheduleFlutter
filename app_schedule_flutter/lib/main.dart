import 'package:app_schedule_flutter/Screen/Dashboard.dart';
import 'package:app_schedule_flutter/Screen/Login_screen.dart';
import 'package:app_schedule_flutter/Screen/WelcomeScreen.dart';
import 'package:app_schedule_flutter/Screen/Home_screen.dart';
import 'package:app_schedule_flutter/Screen/Profile_screen.dart';
import 'package:app_schedule_flutter/Screen/timetable_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  // await Firebase.initializeApp().then((value) {
  //   print('Firebase initialized');
  // }).catchError((error) {
  //   print('Firebase initialization error: $error');
  // });
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) {
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

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<bool> _checkLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );

        } else if (snapshot.hasData && snapshot.data == true) {
          return WelcomeScreen(); // Đã đăng nhập
        } else {
          return LoginScreen(); // Chưa đăng nhập
        }
      },
    );
  }
}
