import 'package:app_schedule_flutter/Admin/ScheduleForm.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ListSchedule extends StatefulWidget {
  @override
  _ListScheduleState createState() => _ListScheduleState();
}

class _ListScheduleState extends State<ListSchedule> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("schedules");
  List<Map<String, dynamic>> _schedules = [];

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  void _fetchSchedules() {
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          _schedules = data.entries
              .map((e) => {"id": e.key, ...Map<String, dynamic>.from(e.value)})
              .toList();
        });
      }
    });
  }

  void _deleteSchedule(String id) async {
    await _dbRef.child(id).remove();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Xóa thời khóa biểu $id"),
        backgroundColor: Colors.blue, // Blue background for SnackBar
        behavior: SnackBarBehavior.floating, // Floating behavior
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh sách thời khóa biểu",
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto'
          ),
        ),
        backgroundColor: Color.fromARGB(255, 6, 138, 246), // Blue AppBar
        elevation: 4.0,
        centerTitle:true,

        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 25, color: Colors.white,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),

      body: ListView.builder(
        itemCount: _schedules.length,
        itemBuilder: (context, index) {
          final schedule = _schedules[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(15),
              title: Text(
                "Schedule ${schedule['scheid']}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                "Class ID: ${schedule['claid']}",
                style: TextStyle(fontSize: 14),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ScheduleForm(scheduleId: schedule['id']),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteSchedule(schedule['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ScheduleForm()),
          );
        },
        child: Icon(Icons.add, color: Colors.white,),
        backgroundColor: Color.fromARGB(255, 47, 100, 253), // Blue FAB
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
