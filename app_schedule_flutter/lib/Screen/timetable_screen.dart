import 'package:app_schedule_flutter/Model/Schedule.dart';
import 'package:app_schedule_flutter/Service/FirebaseService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Model/Class.dart';
import '../Model/Room.dart';
import '../Model/Subject.dart';
import 'Detail_TimeTable_screen.dart';

const double kDefaultPadding = 20.0;

// Define the periods mapping
Map<String, int> periodStart = {
  "06:45:00": 1,
  "07:30:00": 2,
  "08:15:00": 3,
  "09:20:00": 4,
  "10:05:00": 5,
  "10:50:00": 6,
  "12:30:00": 7,
  "13:15:00": 8,
  "14:00:00": 9,
  "15:05:00": 10,
  "15:50:00": 11,
  "16:35:00": 12,
  "18:00:00": 13,
  "18:45:00": 14,
  "19:30:00": 15,
};
Map<String, int> periodEnd = {
  "07:30:00": 1,
  "08:15:00": 2,
  "09:00:00": 3,
  "10:05:00": 4,
  "10:50:00": 5,
  "11:35:00": 6,
  "13:15:00": 7,
  "14:00:00": 8,
  "14:45:00": 9,
  "15:50:00": 10,
  "16:35:00": 11,
  "17:20:00": 12,
  "18:45:00": 13,
  "19:30:00": 14,
  "20:15:00": 15,
};

// Function to convert start time to period
String convertTimeToPeriod(String startTime, String endTime) {
  int startPeriod = periodStart[startTime] ?? -1;
  int endPeriod = periodEnd[endTime] ?? -1;

  if (startPeriod == -1 || endPeriod == -1) {
    return 'Invalid time'; // Handle invalid times
  }

  if (startPeriod == endPeriod) {
    return '$startPeriod';
  } else {
    return '$startPeriod-$endPeriod';
  }
}

class TimetableScreen extends StatefulWidget {
  final bool isInDashboard;
  const TimetableScreen({Key? key, this.isInDashboard = false}) : super(key: key);
  static const String routename = 'Timetablescreen';

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  FirebaseService firebaseService = FirebaseService();
  List<Schedule> timetable = [];
  bool isLoading = true;
  DateTime currentWeekStart = DateTime.now();
  DateTime currentWeekEnd = DateTime.now();
  Map<String, Subject> subjectDetails = {};
  Map<String, Class> classDetails = {};
  Map<String, Room> roomDetails = {};

  @override
  void initState() {
    super.initState();
    _initializeWeekRange();
    _loadTimetable();
  }
  Future<void> _fetchAdditionalDetails(Schedule schedule) async {
    if (!subjectDetails.containsKey(schedule.subid)) {
      Subject? subject = await firebaseService.getSubjectById(schedule.subid);
      if (subject != null) {
        setState(() {
          subjectDetails[schedule.subid] = subject;
        });
      }
    }

    if (!classDetails.containsKey(schedule.claid)) {
      Class? classInfo = await firebaseService.getClassById(schedule.claid);
      if (classInfo != null) {
        setState(() {
          classDetails[schedule.claid] = classInfo;
        });
      }
    }

    if (!roomDetails.containsKey(schedule.rooid)) {
      Room? room = await firebaseService.getRoomById(schedule.rooid);
      if (room != null) {
        setState(() {
          roomDetails[schedule.rooid] = room;
        });
      }
    }
  }


  // Initialize the current week's range
  void _initializeWeekRange() {
    DateTime now = DateTime.now();
    currentWeekStart = now.subtract(Duration(days: now.weekday - 1)); // Start of the week (Monday)
    currentWeekEnd = currentWeekStart.add(Duration(days: 6)); // End of the week (Sunday)
  }

  // Update the week range
  void _updateWeekRange(bool isNext) {
    setState(() {
      if (isNext) {
        currentWeekStart = currentWeekStart.add(Duration(days: 7));
        currentWeekEnd = currentWeekEnd.add(Duration(days: 7));
      } else {
        currentWeekStart = currentWeekStart.subtract(Duration(days: 7));
        currentWeekEnd = currentWeekEnd.subtract(Duration(days: 7));
      }
      _loadTimetable();
    });
  }

  // Load the timetable and filter for the current week
  void _loadTimetable() async {
    firebaseService.listenToSchedules().listen((scheduleList) async {
      for (var schedule in scheduleList) {
        await _fetchAdditionalDetails(schedule);
      }

      setState(() {
        timetable = scheduleList.where((schedule) {
          DateTime scheduleDate = DateFormat("yyyy-MM-dd").parse(schedule.daystart);
          return scheduleDate.isAfter(currentWeekStart.subtract(Duration(days: 1))) &&
              scheduleDate.isBefore(currentWeekEnd.add(Duration(milliseconds: 1)));
        }).toList();

        // Sort the timetable by day and time
        timetable.sort((a, b) {
          DateTime dateA = DateFormat("yyyy-MM-dd HH:mm:ss").parse('${a.daystart} ${a.timestart}');
          DateTime dateB = DateFormat("yyyy-MM-dd HH:mm:ss").parse('${b.daystart} ${b.timestart}');
          return dateA.compareTo(dateB);
        });
        isLoading = false;
      });
    });
  }

  Widget _buildDashedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: List.generate(100 ~/ 1, (index) => Expanded(
          child: Container(
            color: index % 2 == 0 ? Colors.transparent : Colors.grey,
            height: 1,
            width: index % 2 == 0 ? 3 : 6, // Điều chỉnh chiều dài dash và khoảng cách
          ),
        )),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thời khóa biểu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.lightBlueAccent,
        elevation: 0,
        actions: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.lightBlueAccent,
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: Text(
                  'Ngày',
                  style: TextStyle(
                    color: Colors.lightBlueAccent,
                    fontSize: 16,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.lightBlueAccent,
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: Text(
                  'Tuần',
                  style: TextStyle(
                    color: Colors.lightBlueAccent,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_left_outlined, color: Colors.white, size: 25),
                  onPressed: () {
                    _updateWeekRange(false);
                  },
                ),
                Text(
                  'Từ ${DateFormat("dd/MM/yyyy").format(currentWeekStart)} đến ${DateFormat("dd/MM/yyyy").format(currentWeekEnd)}',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_right_outlined, color: Colors.white, size: 25),
                  onPressed: () {
                    _updateWeekRange(true);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/tableload.gif',
                width: 370,
                height: 230,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 25),
              const Text(
                'Đang tải thời khóa biểu...',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      )
          : timetable.isEmpty
          ? Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/tableload.gif',
                width: 370,
                height: 230,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 25),
              const Text(
                'Không có lịch học trong thời khóa biểu',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      )

          : Padding(
          padding: const EdgeInsets.only(top: 25.0), // Khoảng cách 16 pixel từ phía trên
            child: ListView.builder(
                    itemCount: timetable.length,
                    itemBuilder: (context, index) {
            final schedule = timetable[index];
            final subject = subjectDetails[schedule.subid];
            final classInfo = classDetails[schedule.claid];
            final room = roomDetails[schedule.rooid];
            String period = convertTimeToPeriod(schedule.timestart, schedule.timeend);

            DateTime scheduleDate = DateFormat("yyyy-MM-dd").parse(schedule.daystart);
            String formattedDate = "${DateFormat('EEEE', 'vi').format(scheduleDate)}, ngày ${DateFormat('dd/MM').format(scheduleDate)}";

            return ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScheduleDetailScreen(
                      schedule: schedule,
                      subject: subject,
                      classInfo: classInfo,
                      room: room,
                    ),
                  ),
                );
              },
              title:Container(

                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$formattedDate ',
                      style: TextStyle(color: Colors.red, fontSize: 18),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Divider(
                      height: 0.5,
                      color: Colors.green,
                      //thickness: ,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Tiết',
                              style: TextStyle(
                                fontSize: 20
                              ),
                            ),
                            Text(
                              '$period',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                         '${subject?.subname ?? 'Unknown Subject'}',
                              style: TextStyle(
                                fontSize: 20,
                                //fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5,),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, color: Colors.green,size: 25,),
                                Text(
                                  'Phòng: ${room?.rooname }',
                                  style: TextStyle(

                                      fontSize: 18
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Icon(Icons.class_outlined, color: Colors.green,size: 25,),
                                Text(
                                  'Lớp: ${classInfo?.claname }',
                                  style: TextStyle(
                                      fontSize: 18
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 5,),
                    //_buildDashedDivider(), // Thêm đường nét đứt bên dưới mỗi mục
                  ],
                ),
              )
              /*Text(
                '$formattedDate - $period (${schedule.timestart} đến ${schedule.timeend})',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Lớp: ${schedule.claid} - Phòng: ${schedule.rooid}'),*/
            );
                    },
                  ),
          ),
    );
  }
}
