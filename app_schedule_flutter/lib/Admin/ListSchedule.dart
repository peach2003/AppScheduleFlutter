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
      SnackBar(content: Text("Deleted schedule $id")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List Schedule"),
      ),
      body: ListView.builder(
        itemCount: _schedules.length,
        itemBuilder: (context, index) {
          final schedule = _schedules[index];
          return ListTile(
            title: Text("Schedule ${schedule['scheid']}"),
            subtitle: Text("Class ID: ${schedule['claid']}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
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
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteSchedule(schedule['id']),
                ),
              ],
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
        child: Icon(Icons.add),
      ),
    );
  }
}