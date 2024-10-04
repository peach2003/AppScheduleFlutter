
import 'package:app_schedule_flutter/Timetable/timetable_data.dart';
import 'package:flutter/material.dart';

const double kDefaultPadding = 16.0;

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});
  static const String routename = 'Timetablescreen';

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timetable'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(kDefaultPadding),
                  topRight: Radius.circular(kDefaultPadding),
                ),
                color: Colors.white, // Thay đổi màu nền
              ),
              child: ListView.builder(
                itemCount: timetable.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(
                        horizontal: kDefaultPadding / 2),
                    padding: EdgeInsets.all(kDefaultPadding),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Ngày và tháng
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              timetable[index].date.toString(),
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              timetable[index].monthName,
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                        // Tên môn học
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                timetable[index].subjectName,
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                timetable[index].dayName,
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w300),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        // Thời gian
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${timetable[index].time}',
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
