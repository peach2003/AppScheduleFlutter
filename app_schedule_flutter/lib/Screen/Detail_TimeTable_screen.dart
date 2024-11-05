import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package
import '../Model/Class.dart';
import '../Model/Room.dart';
import '../Model/Schedule.dart';
import '../Model/Subject.dart';

class ScheduleDetailScreen extends StatelessWidget {
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

  // Helper method to format date
  String formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString); // Ensure your date string is in ISO 8601 format
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Helper method to format time
  String formatTime(String timeString) {
    DateTime time = DateFormat('HH:mm').parse(timeString); // Assuming time is in HH:mm format
    return DateFormat.jm().format(time); // Formats to 'h:mm AM/PM'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi Tiết Thời Khóa Biểu'),
        centerTitle: true,
        leading:
            IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15),
            Text(
              'Tên Môn Học: ${subject?.subname ?? 'Unknown'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 15),
            Text(
              'Số Tín Chỉ Học Phần: ${subject?.credit ?? 'Unknown'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 15),
            Text(
              'Mã Lớp: ${classInfo?.claid ?? 'Unknown'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 15),
            Text(
              'Tên Lớp: ${classInfo?.claname ?? 'Unknown'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 15),
            Text(
              'Tên Phòng: ${room?.rooname ?? 'Unknown'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 15),
            Text(
              'Ngày Bắt Đầu: ${formatDate(schedule.daystart)}', // Format the date
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 15),
            Text(
              'Giờ Bắt Đầu: ${formatTime(schedule.timestart)}', // Format the start time
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 15),
            Text(
              'Giờ Kết Thúc: ${formatTime(schedule.timeend)}', // Format the end time
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
