import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết thời khóa biểu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Môn học: ${subject?.subname ?? 'Unknown'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Lớp: ${classInfo?.claname ?? 'Unknown'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Phòng: ${room?.rooname ?? 'Unknown'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Ngày bắt đầu: ${schedule.daystart}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Ngày kết thúc: ${schedule.dayend}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Thời gian: ${schedule.timestart} - ${schedule.timeend}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
