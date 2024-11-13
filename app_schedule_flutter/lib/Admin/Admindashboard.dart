import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class admindashboard extends StatefulWidget {
  const admindashboard({super.key});

  @override
  State<admindashboard> createState() => _admindashboardState();
}

class _admindashboardState extends State<admindashboard> {
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
                          // Xử lý khi nhấn vào Dashboard
                        },
                      ),
                      DrawerListTile(
                        title: 'Giảng Viên',
                        svgSrc: "assets/images/icondashboard.svg",
                        press: () {
                          // Xử lý khi nhấn vào Dashboard
                        },
                      ),
                      DrawerListTile(
                        title: 'Lớp',
                        svgSrc: "assets/images/icondashboard.svg",
                        press: () {
                          // Xử lý khi nhấn vào Dashboard
                        },
                      ),
                      DrawerListTile(
                        title: 'Sự Kiện',
                        svgSrc: "assets/images/icondashboard.svg",
                        press: () {
                          // Xử lý khi nhấn vào Dashboard
                        },
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