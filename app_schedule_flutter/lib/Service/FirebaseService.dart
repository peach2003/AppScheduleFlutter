import 'package:app_schedule_flutter/Model/SaveEvent.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Model/Event.dart';

class FirebaseService {
  final DatabaseReference _eventRef = FirebaseDatabase.instance.ref().child('events');
  final DatabaseReference _saveEventRef = FirebaseDatabase.instance.ref().child('save_events');

  // Trả về tham chiếu tới nhánh 'events' để có thể lắng nghe thay đổi
  DatabaseReference getEventRef() {
    return _eventRef;
  }

  DatabaseReference getSaveEventRef() {
    return _saveEventRef;
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

  // Lưu sự kiện đã đăng ký
  Future<void> saveEvent(SaveEvent saveEvent) async {
    String key = _saveEventRef.push().key ?? '';  // Tạo một key mới trong Firebase
    saveEvent.saveEventId = key;  // Gán key cho saveEventId

    await _saveEventRef.child(key).set(saveEvent.toJson());  // Lưu vào Firebase
  }

  // Lấy danh sách sự kiện đã lưu
  Future<List<SaveEvent>> getSavedEvents() async {
    List<SaveEvent> events = [];
    try {
      DataSnapshot snapshot = await _saveEventRef.get();
      if (snapshot.exists) {
        Map<dynamic, dynamic> eventMap = snapshot.value as Map<dynamic, dynamic>;
        eventMap.forEach((key, value) {
          events.add(SaveEvent.fromSnapshot(value));
        });
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách sự kiện đã lưu: $e');
    }
    return events;
  }
  // Hàm mới: Lắng nghe sự thay đổi của sự kiện theo thời gian thực từ 'events'
  Stream<List<Event>> listenToEvents() {
    return _eventRef.onValue.map((event) {
      List<Event> events = [];
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> eventMap = event.snapshot.value as Map<dynamic, dynamic>;
        eventMap.forEach((key, value) {
          events.add(Event.fromSnapshot(value));
        });
      }
      return events;
    });
  }

  // Hàm mới: Lắng nghe sự thay đổi của sự kiện đã đăng ký theo thời gian thực từ 'save_events'
  Stream<List<SaveEvent>> listenToSavedEvents() {
    return _saveEventRef.onValue.map((event) {
      List<SaveEvent> savedEvents = [];
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> savedEventMap = event.snapshot.value as Map<dynamic, dynamic>;
        savedEventMap.forEach((key, value) {
          savedEvents.add(SaveEvent.fromSnapshot(value));
        });
      }
      return savedEvents;
    });
  }
  // Hàm xóa sự kiện đã đăng ký
  Future<void> deleteSavedEvent(String saveEventId) async {
    try {
      await _saveEventRef.child(saveEventId).remove();  // Xóa sự kiện dựa trên saveEventId
      print('Sự kiện đã được xóa thành công.');
    } catch (e) {
      print('Lỗi khi xóa sự kiện đã lưu: $e');
      throw Exception('Lỗi khi xóa sự kiện đã lưu: $e');
    }
  }
}
