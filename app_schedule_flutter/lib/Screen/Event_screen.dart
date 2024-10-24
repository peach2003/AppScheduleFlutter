import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import 'Add_Event_screen.dart';


class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final DatabaseReference _eventRef = FirebaseDatabase.instance.ref().child('events');
  List<Map<dynamic, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEventsFromFirebase();  // Tải sự kiện khi khởi động
  }

  // Hàm lắng nghe và tải dữ liệu từ Firebase
  void _loadEventsFromFirebase() {
    _eventRef.onValue.listen((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        final List<Map<dynamic, dynamic>> loadedEvents = [];
        data.forEach((key, value) {
          loadedEvents.add(value);
        });

        // Sắp xếp sự kiện theo thứ tự ngày mới nhất về trước
        loadedEvents.sort((a, b) {
          DateTime dateA = DateFormat('yyyy-MM-dd HH:mm:ss').parse(a['create_at']);
          DateTime dateB = DateFormat('yyyy-MM-dd HH:mm:ss').parse(b['create_at']);
          return dateB.compareTo(dateA); // Sắp xếp theo ngày mới nhất
        });

        setState(() {
          _events = loadedEvents;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách sự kiện'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddEventScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildEventList(),
    );
  }

  // Widget để hiển thị danh sách sự kiện
  Widget _buildEventList() {
    return _events.isEmpty
        ? Center(child: Text('Chưa có sự kiện nào.'))
        : ListView.builder(
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return ListTile(
          leading: Image.network(
            event['image'],
            width: 50,
            height: 50,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.error);
            },
          ),
          title: Text(event['title']),
          subtitle: Text(event['create_at']),
        );
      },
    );
  }
}