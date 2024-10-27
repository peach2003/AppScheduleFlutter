
import 'package:app_schedule_flutter/Screen/Detail_Event_screen.dart';
import 'package:app_schedule_flutter/Screen/Event_screen.dart';
import 'package:app_schedule_flutter/Screen/Home_screen.dart';
import 'package:app_schedule_flutter/Screen/Save_Event_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../Timetable/timetable_screen.dart';
import 'Profile_screen.dart';

class Dashboad extends StatefulWidget {
  final int selectedIndex;

  const Dashboad({super.key, this.selectedIndex=0});// mặc định tab đầu tiên bằng 0

  @override
  State<Dashboad> createState() => _DashboadState();
}

class _DashboadState extends State<Dashboad> {
  int _selectionIndex = 0;

  //List danh sách các màn hình
  final List<Widget> _page=[
    HomeScreen(),
    SaveEventScreen(isInDashboard: true),
    TimetableScreen(isInDashboard: true),
    ProfileScreen()
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectionIndex= widget.selectedIndex; // Thiết lập tab từ giá trị truyền vào
  }
  void _navigateToSelectedTab(int index){
    if(_selectionIndex != index){
      setState(() {
        _selectionIndex=index;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _page[_selectionIndex],//Hiển thị màn hình dựa trên các tab được chọn
      bottomNavigationBar: Container(

        decoration: BoxDecoration(
          color: Colors.lightBlueAccent,
          borderRadius: BorderRadius.only( topLeft: Radius.circular(10), topRight: Radius.circular(10), ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
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
                textSize: 20,
              ),
              GButton(
                icon:Icons.event_available_outlined,
                text: 'Sự kiện đã lưu',
                textSize: 20,
              ),
              GButton(
                icon: Icons.today_outlined,
                text: 'Thời khóa biểu',
                textSize: 20,
              ),
              GButton(
                icon: Icons.settings_outlined,
                text: 'Tài khoản',
                textSize: 20,
              )
            ],
            selectedIndex: _selectionIndex,
            onTabChange: (index){
              _navigateToSelectedTab(index);
            },
          ),
        ),
      ),
    );
  }
}