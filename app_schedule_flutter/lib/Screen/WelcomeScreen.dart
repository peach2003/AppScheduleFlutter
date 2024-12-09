import 'package:app_schedule_flutter/Screen/Login_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Dashboard.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('students');
  String userName = ''; // Biến để lưu tên người dùng
  bool isLoading = false; // Biến để theo dõi trạng thái loading

  @override
  void initState() {
    super.initState();
    _checkLoggedInStatus();
  }

  Future<void> _fetchUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? mssv = prefs.getString('mssv');

      if (mssv != null) {
        DataSnapshot snapshot = await _dbRef.orderByChild('stuid').equalTo(int.parse(mssv)).get();

        if (snapshot.exists) {
          Map<dynamic, dynamic> studentData = snapshot.value as Map<dynamic, dynamic>;
          if (studentData.isNotEmpty) {
            setState(() {
              userName = studentData.values.first['stuname']; // Lấy tên sinh viên
            });
          }
        }
      }
    } catch (e) {
      print('Lỗi khi lấy dữ liệu sinh viên: $e');
    }
  }

  Future<void> _checkLoggedInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      // Bắt đầu hiệu ứng loading
      setState(() {
        isLoading = true;
      });

      // Lấy tên người dùng từ Firebase
      await _fetchUserData();

      // Hiển thị WelcomeScreen trong vài giây trước khi điều hướng đến Dashboard
      await Future.delayed(Duration(seconds: 2)); // Thay đổi thời gian nếu cần

      setState(() {
        isLoading = false; // Kết thúc hiệu ứng loading
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Dashboad()), // Chỉnh sửa tên class nếu cần
      );
    } else {
      // Nếu chưa đăng nhập, điều hướng đến màn hình đăng nhập
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // Thay LoginScreen bằng tên màn hình đăng nhập của bạn
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0), // Thêm khoảng cách bên trái và bên phải
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Căn giữa tất cả các phần tử
              children: [
                // Logo
                Container(
                  child: Image.asset(
                    'assets/images/logo.png', // Đường dẫn đến logo của bạn
                    width: 120, // Điều chỉnh kích thước logo
                    height: 120,
                  ),
                ),
                SizedBox(height: 20),
                // Tiêu đề
                Text(
                  'Hệ thống hỗ trợ học tập cho Sinh viên',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40),
                // Chào mừng
                Text(
                  'Xin chào, $userName', // Hiển thị tên người dùng
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                // Hiệu ứng loading
                if (isLoading)
                  CircularProgressIndicator() // Hiển thị hiệu ứng loading
                else
                  Container(), // Không hiển thị gì khi không loading
              ],
            ),
          ),
        ),
      ),
    );
  }
}