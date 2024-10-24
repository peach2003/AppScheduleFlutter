import 'package:firebase_database/firebase_database.dart';
import '../Model/Event.dart';

class FirebaseService {
  final DatabaseReference _eventRef = FirebaseDatabase.instance.ref().child('events');

  // Trả về tham chiếu tới nhánh 'events' để có thể lắng nghe thay đổi
  DatabaseReference getEventRef() {
    return _eventRef;
  }

  // Hàm lấy danh sách sự kiện một lần (nếu cần)
  Future<List<Event>> getAllEvents() async {
    List<Event> events = [];
    try {
      DataSnapshot snapshot = await _eventRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> eventMap = snapshot.value as Map<dynamic, dynamic>;
        eventMap.forEach((key, value) {
          events.add(Event.fromSnapshot(value));
        });
      }
    } catch (e) {
      print("Lỗi khi lấy danh sách sự kiện: $e");
    }
    return events;
  }
}

