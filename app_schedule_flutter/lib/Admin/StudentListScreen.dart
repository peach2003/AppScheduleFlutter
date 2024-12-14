import 'package:app_schedule_flutter/Admin/StudentForm.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class StudentListScreen extends StatefulWidget {
  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<Map<String, dynamic>> studentList = []; // List to store student maps
  List<Map<String, dynamic>> classList = []; // List to store classes

  @override
  void initState() {
    super.initState();
    _fetchData(); // Fetch students and classes
  }

  // Fetch both student and class data
  Future<void> _fetchData() async {
    final studentData = await FirebaseDatabase.instance.ref('students').get();

    if (studentData.exists) {
      setState(() {
        // Kiểm tra nếu dữ liệu là List
        if (studentData.value is List) {
          // Lọc các phần tử null và chuyển đổi thành Map<String, dynamic>
          studentList = List<Map<String, dynamic>>.from(
              (studentData.value as List)
                  .where((e) => e != null) // Lọc các phần tử null
                  .map((e) => Map<String, dynamic>.from(e))
          );
        }
      });
    } else {
      setState(() {
        studentList = [];
      });
    }
  }

  // Show student form when adding or editing a student
  void _showStudentForm({Map<String, dynamic>? student}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StudentForm(
          student: student != null ? student : null, // Truyền thông tin sinh viên nếu có
          onSave: (stuid, studentData) async {
            // Hàm onSave xử lý thêm hoặc cập nhật dữ liệu sinh viên
            final studentDataRef = FirebaseDatabase.instance.ref('students');
            final snapshot = await studentDataRef.get();

            List<dynamic> students = [];
            if (snapshot.exists) {
              if (snapshot.value is List) {
                students = (snapshot.value as List).whereType<Map<String, dynamic>>().toList();
              } else if (snapshot.value is Map) {
                students = (snapshot.value as Map).values.map((item) {
                  return Map<String, dynamic>.from(item);
                }).toList();
              }
            }

            if (stuid == 0 || stuid == null) {
              // Nếu là sinh viên mới (stuid chưa tồn tại), thêm vào danh sách
              students.add(studentData);
            } else {
              // Nếu đã tồn tại stuid, cập nhật dữ liệu
              final index = students.indexWhere((s) => s['stuid'] == stuid);
              if (index != -1) {
                students[index] = studentData;
              }
            }

            // Cập nhật lại dữ liệu trên Firebase
            await studentDataRef.set(students);

            // Reload danh sách sinh viên
            _fetchData();
          },
          classList: classList, // Truyền danh sách lớp hiện tại
        );
      },
    );
  }

  // Save or update student
  void _saveStudent(int? stuid, Map<String, dynamic> studentData) async {
    final studentDataRef = FirebaseDatabase.instance.ref('students');
    final snapshot = await studentDataRef.get();
    List<Map<String, dynamic>> students = [];

    if (snapshot.exists) {
      if (snapshot.value is List) {
        students = (snapshot.value as List).whereType<Map<String, dynamic>>().toList();
      } else if (snapshot.value is Map) {
        students = (snapshot.value as Map).values.map((item) {
          return Map<String, dynamic>.from(item);
        }).toList();
      }
    }

    if (stuid == null || stuid == 0) {
      // Add new student to the list
      students.add(studentData); // Add new student data to the list
    } else {
      // Update existing student
      students[stuid] = studentData; // Update the student in the list
    }

    // Save the updated student list to Firebase (still keeping it as a List)
    await studentDataRef.set(students);

    // After saving, reload the student list
    _fetchData();
  }

  // Delete student with confirmation
  void _deleteStudent(int stuid) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text('Bạn có muốn xóa sinh viên này không?'),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
            ),
            TextButton(
              child: Text('Xóa'),
              onPressed: () async {
                final studentDataRef = FirebaseDatabase.instance.ref('students');
                final snapshot = await studentDataRef.get();

                if (snapshot.exists) {
                  List<dynamic> students = [];

                  if (snapshot.value is List) {
                    students = (snapshot.value as List).whereType<Map<String, dynamic>>().toList();
                  } else if (snapshot.value is Map) {
                    students = (snapshot.value as Map).values
                        .map((item) => Map<String, dynamic>.from(item))
                        .toList();
                  }

                  // Find the index of the student to delete based on stuid
                  final studentToDeleteIndex = students.indexWhere((student) => student['stuid'] == stuid);

                  if (studentToDeleteIndex != -1) {
                    // If student is found, remove it from Firebase
                    students.removeAt(studentToDeleteIndex);

                    // Update the student list in Firebase by setting the updated list
                    await studentDataRef.set(students);

                    // Remove the student from the local list
                    setState(() {
                      studentList.removeWhere((student) => student['stuid'] == stuid);
                    });

                    // Close the dialog and show success message
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xóa sinh  viên thành công')));
                  } else {
                    // Show an error if the student wasn't found
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không tìm thấy sinh viên')));
                  }
                } else {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không tìm thấy dữ liệu')));
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh sách sinh viên"),
        backgroundColor: Colors.blue, // Blue app bar
      ),
      body: ListView.builder(
        itemCount: studentList.length,
        itemBuilder: (context, index) {
          final student = studentList[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(15),
              title: Text(
                student['stuname'] ?? 'Không có tên',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(
                student['gmail'] ?? 'Không có Email',
                style: TextStyle(fontSize: 14),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showStudentForm(student: student), // Show form to edit
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteStudent(student['stuid']), // Delete student with confirmation
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStudentForm(), // Show form to add a new student
        child: Icon(Icons.add),
        backgroundColor: Colors.blue, // Blue FAB
      ),
    );
  }
}
