import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ScheduleForm extends StatefulWidget {
  final String? scheduleId;

  ScheduleForm({this.scheduleId});

  @override
  _ScheduleFormState createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseReference _scheduleRef = FirebaseDatabase.instance.ref("schedules");
  final DatabaseReference _classesRef = FirebaseDatabase.instance.ref("classes");
  final DatabaseReference _roomsRef = FirebaseDatabase.instance.ref("rooms");
  final DatabaseReference _subjectsRef = FirebaseDatabase.instance.ref("subjects");

  // Form data
  String? _selectedClassId;
  String? _selectedRoomId;
  String? _selectedSubjectId;
  final TextEditingController _daystartController = TextEditingController();
  final TextEditingController _dayendController = TextEditingController();
  final TextEditingController _timestartController = TextEditingController();
  final TextEditingController _timeendController = TextEditingController();
  final TextEditingController _weekdayController = TextEditingController();

  // Dropdown data
  Map<String, String> _classes = {};
  Map<String, String> _rooms = {};
  Map<String, String> _subjects = {};

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
    if (widget.scheduleId != null) {
      _loadScheduleData();
    }
  }

  Future<void> _loadDropdownData() async {
    try {
      // Load classes
      final classSnapshot = await _classesRef.get();
      if (classSnapshot.exists) {
        setState(() {
          _classes = (classSnapshot.value as List)
              .where((e) => e != null)
              .fold<Map<String, String>>({}, (map, element) {
            final data = Map<String, dynamic>.from(element);
            map[data['claid']] = data['claname'];
            return map;
          });
        });
      }

      // Load rooms
      final roomSnapshot = await _roomsRef.get();
      if (roomSnapshot.exists) {
        setState(() {
          _rooms = (roomSnapshot.value as Map).map((key, value) {
            final data = Map<String, dynamic>.from(value);
            return MapEntry(data['rooid'], data['rooname']);
          });
        });
      }

      // Load subjects
      final subjectSnapshot = await _subjectsRef.get();
      if (subjectSnapshot.exists) {
        setState(() {
          _subjects = (subjectSnapshot.value as List)
              .where((e) => e != null)
              .fold<Map<String, String>>({}, (map, element) {
            final data = Map<String, dynamic>.from(element);
            map[data['subid'].toString()] = data['subname'];
            return map;
          });
        });
      }
    } catch (e) {
      print("Error loading dropdown data: $e");
    }
  }

  Future<void> _loadScheduleData() async {
    final snapshot = await _scheduleRef.child(widget.scheduleId!).get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        _selectedClassId = data['claid'];
        _selectedRoomId = data['rooid'];
        _selectedSubjectId = data['subid'];
        _daystartController.text = data['daystart'];
        _dayendController.text = data['dayend'];
        _timestartController.text = data['timestart'];
        _timeendController.text = data['timeend'];
        _weekdayController.text = data['weekday'];
      });
    }
  }

  Future<void> _saveSchedule() async {
    if (_formKey.currentState!.validate()) {
      final scheduleData = {
        "claid": _selectedClassId,
        "rooid": _selectedRoomId,
        "subid": _selectedSubjectId,
        "daystart": _daystartController.text,
        "dayend": _dayendController.text,
        "timestart": _timestartController.text,
        "timeend": _timeendController.text,
        "weekday": _weekdayController.text,
      };

      if (widget.scheduleId == null) {
        // Add new schedule
        await _scheduleRef.push().set(scheduleData);
      } else {
        // Update existing schedule
        await _scheduleRef.child(widget.scheduleId!).set(scheduleData);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scheduleId == null ? "Thêm thời khóa biểu" : "Sửa thời khóa biểu"),
        backgroundColor: Colors.blue, // Blue color for the AppBar
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedClassId,
                items: _classes.entries.map((entry) {
                  return DropdownMenuItem(value: entry.key, child: Text(entry.value));
                }).toList(),
                onChanged: (value) => setState(() => _selectedClassId = value),
                decoration: InputDecoration(
                  labelText: "Lớp",
                  labelStyle: TextStyle(color: Colors.blue), // Blue label color
                  filled: true,
                  fillColor: Colors.blue.shade50, // Light blue background for dropdown
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null ? "Hãy chọn lớp" : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedRoomId,
                items: _rooms.entries.map((entry) {
                  return DropdownMenuItem(value: entry.key, child: Text(entry.value));
                }).toList(),
                onChanged: (value) => setState(() => _selectedRoomId = value),
                decoration: InputDecoration(
                  labelText: "Phòng",
                  labelStyle: TextStyle(color: Colors.blue),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null ? "Hãy chọn phòng" : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedSubjectId,
                items: _subjects.entries.map((entry) {
                  return DropdownMenuItem(value: entry.key, child: Text(entry.value));
                }).toList(),
                onChanged: (value) => setState(() => _selectedSubjectId = value),
                decoration: InputDecoration(
                  labelText: "Môn học",
                  labelStyle: TextStyle(color: Colors.blue),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null ? "Hãy chọn môn học" : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _daystartController,
                decoration: InputDecoration(
                  labelText: "Ngày bắt đầu",
                  labelStyle: TextStyle(color: Colors.blue),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Hãy nhập ngày bắt đầu" : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _dayendController,
                decoration: InputDecoration(
                  labelText: "End Date",
                  labelStyle: TextStyle(color: Colors.blue),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Hãy nhập ngày kết thúc" : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _timestartController,
                decoration: InputDecoration(
                  labelText: "Giờ bắt đầu",
                  labelStyle: TextStyle(color: Colors.blue),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Hãy nhập giờ bắt đầu" : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _timeendController,
                decoration: InputDecoration(
                  labelText: "Giờ kết thúc",
                  labelStyle: TextStyle(color: Colors.blue),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Hãy nhập giờ kết thúc" : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _weekdayController,
                decoration: InputDecoration(
                  labelText: "Weekday (2=Thứ 2, ... 7=Chủ nhật)",
                  labelStyle: TextStyle(color: Colors.blue),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Hãy nhập weekday" : null,
              ),
              SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSchedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Use backgroundColor instead of primary
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            child: Text(widget.scheduleId == null ? "Thêm thời khóa biểu" : "Cập nhật thời khóa biểu"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
