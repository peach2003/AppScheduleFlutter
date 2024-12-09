import 'package:app_schedule_flutter/Admin/EventListScreen.dart';
import 'package:app_schedule_flutter/Admin/ListSchedule.dart';
import 'package:app_schedule_flutter/Admin/StudentListScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Screen/Login_screen.dart';

class admindashboard extends StatefulWidget {
  const admindashboard({super.key});

  @override
  State<admindashboard> createState() => _admindashboardState();
}

class _admindashboardState extends State<admindashboard> {
  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Xác nhận đăng xuất',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Drawer(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      DrawerHeader(
                        child: Image.asset("assets/images/logo.png"),
                      ),
                      DrawerListTile(
                        title: 'Dashboard',
                        svgSrc: "assets/images/icondashboard.svg",
                        press: () {
                          // Xử lý khi nhấn vào Dashboard
                        },
                      ),
                      DrawerListTile(
                        title: 'Sinh Viên',
                        svgSrc: "assets/images/icondashboard.svg",
                        press: () {
                          // Điều hướng đến StudentListScreen khi nhấn vào "Sinh Viên"
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentListScreen(),
                            ),
                          );
                        },
                      ),
                      DrawerListTile(
                        title: 'Thời Khóa Biểu',
                        svgSrc: "assets/images/icondashboard.svg",
                        press: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                              builder: (context) => ListSchedule(),
                              ),
                          );
                        },
                      ),
                      DrawerListTile(
                        title: 'Sự Kiện',
                        svgSrc: "assets/images/icondashboard.svg",
                        press: () {
                          // Xử lý khi nhấn vào Sự Kiện
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventListScreen(),
                            ),
                          );
                        },
                      ),
                      Divider(),
                      DrawerListTile(
                        title: 'Đăng Xuất',
                        svgSrc: "assets/images/iconlogout.svg",
                        press: _logout,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                color: Colors.lightBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class DrawerListTile extends StatelessWidget {

  final String title, svgSrc;
  final VoidCallback press;

  const DrawerListTile({
    Key? key,
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
