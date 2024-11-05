import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Model/Class.dart';
import '../Model/Room.dart';
import '../Model/Schedule.dart';
import '../Model/Subject.dart';
import '../Model/Teacher.dart';
import '../Service/FirebaseService.dart';

class ScheduleDetailScreen extends StatefulWidget {
  final Schedule schedule;
  final Subject? subject;
  final Class? classInfo;
  final Room? room;

  const ScheduleDetailScreen({
    Key? key,
    required this.schedule,
    this.subject,
    this.classInfo,
    this.room,
  }) : super(key: key);

  @override
  _ScheduleDetailScreenState createState() => _ScheduleDetailScreenState();
}

class _ScheduleDetailScreenState extends State<ScheduleDetailScreen> {
  FirebaseService firebaseService = FirebaseService();
  Teacher? teacher;
  bool isLoadingTeacher = true;

  @override
  void initState() {
    super.initState();
    _loadTeacher();
  }

  Future<void> _loadTeacher() async {

    // Lấy `teaid` dựa trên `subid` của môn học
    String? teaid = await firebaseService.getTeacherIdBySubjectId(widget.schedule.subid);

    if (teaid != null) {
      print("Đang truy xuất thông tin giáo viên với teaid: $teaid");
      Teacher? fetchedTeacher = await firebaseService.getTeacherById(teaid);
      setState(() {
        teacher = fetchedTeacher;
      });
      if (teacher != null) {
        print("Tìm thấy giáo viên: ${teacher!.teaname}");
      } else {
        print("Không tìm thấy thông tin giáo viên cho teaid: $teaid");
      }
    } else {
      setState(() {
        isLoadingTeacher = false;
      });
      print("Không tìm thấy ID giáo viên cho môn học này.");
    }
  }

  // Helper method to format date
  String formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Helper method to format time
  String formatTime(String timeString) {
    DateTime time = DateFormat('HH:mm').parse(timeString);
    return DateFormat.jm().format(time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết thời khóa biểu',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25
        ),),
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 7),
            Text(
              'Tên môn học: ${widget.subject?.subname ?? 'Unknown'}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Text(
              'Số tín chỉ học phần: ${widget.subject?.credit ?? 'Unknown'}',
              style: TextStyle(fontSize: 19),
            ),
            SizedBox(height: 15),
            Text(
              'Giờ bắt đầu: ${formatTime(widget.schedule.timestart)}',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Text(
              'Giờ kết thúc: ${formatTime(widget.schedule.timeend)}',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Text(
              'Mã lớp: ${widget.classInfo?.claid ?? 'Unknown'}',
              style: TextStyle(fontSize: 19),
            ),
            SizedBox(height: 15),
            Text(
              'Tên lớp: ${widget.classInfo?.claname ?? 'Unknown'}',
              style: TextStyle(fontSize: 19),
            ),
            SizedBox(height: 15),
            Text(
              'Tên phòng: ${widget.room?.rooname ?? 'Unknown'}',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Text(
              'Ngày học: ${formatDate(widget.schedule.daystart)}',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Text(
              'Tên giảng viên: ${teacher?.teaname}',
              style: TextStyle(fontSize: 19),
            ),


          ],
        ),
      ),
    );
  }
}
