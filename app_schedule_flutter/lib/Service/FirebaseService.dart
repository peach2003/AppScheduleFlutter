import 'package:app_schedule_flutter/Model/SaveEvent.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Model/Class.dart';
import '../Model/Event.dart';
import '../Model/Room.dart';
import '../Model/Schedule.dart';
import '../Model/Subject.dart';
import '../Model/Teacher.dart';

class FirebaseService {
  final DatabaseReference _eventRef = FirebaseDatabase.instance.ref().child('events');
  final DatabaseReference _saveEventRef = FirebaseDatabase.instance.ref().child('save_events');
  final DatabaseReference _scheduleRef = FirebaseDatabase.instance.ref().child('schedules');
  final DatabaseReference _classRef = FirebaseDatabase.instance.ref().child('classes');
  final DatabaseReference _roomRef = FirebaseDatabase.instance.ref().child('rooms');
  final DatabaseReference _subjectRef = FirebaseDatabase.instance.ref().child('subjects');
  final DatabaseReference _teacherRef = FirebaseDatabase.instance.ref().child('teachers');
  final DatabaseReference _teaSubRef = FirebaseDatabase.instance.ref().child('tea_sub');
  final database = FirebaseDatabase.instance;
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

  // Lắng nghe sự kiện đã đăng ký theo userId
  Stream<List<SaveEvent>> listenToSavedEvents(String userId) {
    return _saveEventRef
        .orderByChild('userId')
        .equalTo(userId)
        .onValue
        .map((event) {
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
  // Lấy danh sách thời khóa biểu từ Firebase
  Future<List<Schedule>> getAllSchedules() async {
    List<Schedule> schedules = [];
    try {
      DataSnapshot snapshot = await _scheduleRef.get();
      if (snapshot.exists) {
        Map<dynamic, dynamic> scheduleMap = snapshot.value as Map<dynamic, dynamic>;
        scheduleMap.forEach((key, value) {
          schedules.add(Schedule.fromSnapshot(value as Map<dynamic, dynamic>));
        });
      }
    } catch (e) {
      print("Lỗi khi lấy danh sách thời khóa biểu: $e");
    }
    return schedules;
  }
  // Lắng nghe sự thay đổi thời khóa biểu theo thời gian thực
  Stream<List<Schedule>> listenToSchedules(String claid) {
    /*return _scheduleRef.onValue.map((event) {
      List<Schedule> schedules = [];
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> scheduleMap = event.snapshot.value as Map<dynamic, dynamic>;
        scheduleMap.forEach((key, value) {
          schedules.add(Schedule.fromSnapshot(value));
        });
      }
      return schedules;
    });*/
    return _scheduleRef
        .orderByChild('claid')
        .equalTo(claid)
        .onValue
        .map((event) {
      List<Schedule> schedules = [];
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> scheduleMap = event.snapshot.value as Map<dynamic, dynamic>;
        scheduleMap.forEach((key, value) {
          schedules.add(Schedule.fromSnapshot(value));
        });
      }
      return schedules;
    });
  }
  // Lấy thông tin lớp học theo ID
  Future<Class?> getClassById(String classId) async {
    try {
      final snapshot = await _classRef.child(classId).get();
      if (snapshot.exists) {
        return Class.fromJson(Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>));
      }
    } catch (e) {
      print("Lỗi khi lấy lớp học: $e");
    }
    return null;
  }

  // Lấy thông tin môn học theo ID
  Future<Subject?> getSubjectById(String subId) async {
    try {
      final snapshot = await _subjectRef.child(subId).get();
      if (snapshot.exists) {
        return Subject.fromJson(Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>));
      }
    } catch (e) {
      print("Lỗi khi lấy môn học: $e");
    }
    return null;
  }

  // Lấy thông tin phòng học theo ID
  Future<Room?> getRoomById(String roomId) async {
    try {
      final snapshot = await _roomRef.child(roomId).get();
      if (snapshot.exists) {
        return Room.fromJson(Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>));
      }
    } catch (e) {
      print("Lỗi khi lấy phòng học: $e");
    }
    return null;
  }
  Future<String?> getTeacherIdBySubjectId(String subId) async {
    try {
      print("Đang lấy teaid cho subid: $subId");
      DataSnapshot snapshot = await _teaSubRef.orderByChild('subid').equalTo(subId).get();

      if (snapshot.exists) {
        if (snapshot.value is List) {
          // Nếu kết quả là một danh sách
          List<dynamic> teaSubList = snapshot.value as List<dynamic>;
          for (var item in teaSubList) {
            if (item != null && item['subid'] == subId) {
              String teaid = item['teaid'].toString();
              print("Tìm thấy teaid: $teaid cho subid: $subId");
              return teaid;
            }
          }
        } else if (snapshot.value is Map) {
          // Nếu kết quả là một bản đồ
          Map<dynamic, dynamic> teaSubMap = snapshot.value as Map<dynamic, dynamic>;
          String teaid = teaSubMap.values.first['teaid'].toString();
          print("Tìm thấy teaid: $teaid cho subid: $subId");
          return teaid;
        } else {
          print("Dữ liệu trả về không đúng kiểu List hoặc Map.");
        }
      } else {
        print("Không tìm thấy dữ liệu trong tea_sub cho subid: $subId");
      }
    } catch (e) {
      print("Lỗi khi lấy teaid từ subid: $e");
    }
    return null;
  }


  // Lấy thông tin giáo viên từ teaid
  Future<Teacher?> getTeacherById(String teaid) async {
    try {
      DataSnapshot snapshot = await _teacherRef.child(teaid).get();
      if (snapshot.exists) {
        return Teacher.fromSnapshot(Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>));
      }
    } catch (e) {
      print("Lỗi khi lấy thông tin giáo viên từ teaid: $e");
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getSchedulesByClassId(String claid) async {
    try {
      // Truy vấn thời khóa biểu theo claid
      final snapshot = await FirebaseDatabase.instance
          .ref('schedules') // Đường dẫn tới node 'schedules'
          .orderByChild('claid') // Sắp xếp theo claid
          .equalTo(claid) // Lọc theo giá trị cụ thể của claid
          .get();

      if (snapshot.exists) {
        List<Map<String, dynamic>> schedules = [];
        for (var entry in snapshot.children) {
          schedules.add(Map<String, dynamic>.from(entry.value as Map));
        }
        return schedules;
      } else {
        print('Không tìm thấy thời khóa biểu cho claid: $claid');
        return [];
      }
    } catch (e) {
      print('Lỗi khi lấy thời khóa biểu: $e');
      return [];
    }
  }


}
