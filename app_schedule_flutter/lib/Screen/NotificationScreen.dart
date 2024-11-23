import 'package:app_schedule_flutter/Screen/Detail_Event_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];  // Danh sách thông báo

  @override
  void initState() {
    super.initState();
    _listenForNewNotifications();
  }

  // Lắng nghe thông báo mới từ Firebase
  void _listenForNewNotifications() {
    final notificationsRef = FirebaseDatabase.instance.ref('notifications');
    notificationsRef.onChildAdded.listen((event) {
      final notificationData = event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        notifications.add(Map<String, dynamic>.from(notificationData));
      });
    });
  }

  // Chuyển đến chi tiết sự kiện khi nhấn vào thông báo
  // void _navigateToEventDetail(String eventId) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => DetailEvent(eventId: eventId),  // Truyền eventId vào constructor
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('Không có thông báo'))
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            title: Text(notification['title'] ?? 'Không có tiêu đề'),
            subtitle: Text(notification['description'] ?? 'Không có mô tả'),
            trailing: const Icon(Icons.arrow_forward),
            // onTap: () => _navigateToEventDetail(notification['eventId']),
          );
        },
      ),
    );
  }
}
