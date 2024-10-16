
import 'package:app_schedule_flutter/Screen/Detail_Event_screen.dart';
import 'package:app_schedule_flutter/Screen/Event_screen.dart';
import 'package:app_schedule_flutter/Screen/Home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../Timetable/timetable_screen.dart';
import 'Profile_screen.dart';

class Dashboad extends StatefulWidget {
  const Dashboad({super.key});

  @override
  State<Dashboad> createState() => _DashboadState();
}

class _DashboadState extends State<Dashboad> {
  int _selectionIndex = 0;

  //List danh sách các màn hình
  final List<Widget> _page=[
    HomeScreen(),
    DetailEvent(),
    TimetableScreen(),
    ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _page[_selectionIndex],//Hiển thị màn hình dựa trên các tab được chọn
      bottomNavigationBar: Container(
        color: Colors.lightBlueAccent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          child: GNav(
            gap: 8,
            backgroundColor: Colors.lightBlueAccent,
            activeColor: Colors.white,
            color: Colors.white,
            haptic: true,
            tabBackgroundColor: Color.fromARGB(61, 255, 255, 255)!,
            padding: EdgeInsets.all(10),
            tabs: const[
              GButton(
                icon: Icons.home_outlined,
                text: 'Trang Chủ',
              ),
              GButton(
                icon:Icons.event_available_outlined,
                text: 'SK đã lưu',
              ),
              GButton(
                icon: Icons.today_outlined,
                text: 'TKB',
              ),
              GButton(
                icon: Icons.settings_outlined,
                text: 'Cài đặt',
              )
            ],
            selectedIndex: _selectionIndex,
            onTabChange: (index){
              setState(() {
                _selectionIndex=index;
              });
            },
          ),
        ),
      ),
    );
  }
}