import 'package:app_schedule_flutter/Admin/EventForm.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class EventListScreen extends StatefulWidget {
  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  List<Map<String, dynamic>> eventList = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final eventData = await FirebaseDatabase.instance.ref('events').get();
    if (eventData.exists) {
      setState(() {
        eventList = (eventData.value as Map).entries.map((e) {
          return {
            "key": e.key,
            ...Map<String, dynamic>.from(e.value),
          };
        }).toList();
      });
    } else {
      setState(() {
        eventList = [];
      });
    }
  }

  void _showEventForm({Map<String, dynamic>? event}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return EventForm(
          event: event,
          onSave: (key, eventData) async {
            final eventRef = FirebaseDatabase.instance.ref('events');
            if (key == null) {
              final newKey = eventRef.push().key;
              await eventRef.child(newKey!).set(eventData);
            } else {
              await eventRef.child(key).set(eventData);
            }
            _fetchEvents();
          },
        );
      },
    );
  }

  void _deleteEvent(String key) async {
    final eventRef = FirebaseDatabase.instance.ref('events');
    await eventRef.child(key).remove();
    _fetchEvents();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xóa sự kiện thành công')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh sách sự kiện",
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: eventList.length,
          itemBuilder: (context, index) {
            final event = eventList[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              shadowColor: Colors.blueGrey,
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade100, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['Tiêu đề'] ?? 'Không tiêu đề',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      event['content'] != null && event['content'].length > 100
                          ? event['content'].substring(0, 100) + "..."
                          : event['content'] ?? 'Không có nội dung',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Ngày: ${event['date'] ?? 'N/A'}",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blueAccent),
                              onPressed: () => _showEventForm(event: event),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _deleteEvent(event['key']),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventForm(),
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add),
      ),
    );
  }
}