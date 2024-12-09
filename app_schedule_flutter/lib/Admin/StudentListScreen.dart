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

  // Delete student
  void _deleteStudent(int stuid) async {
    final studentDataRef = FirebaseDatabase.instance.ref('students');

    // Fetch the students data from Firebase
    final snapshot = await studentDataRef.get();

    if (snapshot.exists) {
      List<dynamic> students = [];

      if (snapshot.value is List) {
        // Convert the List<dynamic> to List<Map<String, dynamic>>
        students = (snapshot.value as List).whereType<Map<String, dynamic>>().toList();
      } else if (snapshot.value is Map) {
        // Handle the case where data is a Map, not a List
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

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Student deleted successfully')));
      } else {
        // Show an error if the student wasn't found
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Student not found')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No data found')));
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Student List")),
      body: ListView.builder(
        itemCount: studentList.length,
        itemBuilder: (context, index) {
          final student = studentList[index];
          return ListTile(
            title: Text(student['stuname'] ?? 'No Name'), // student['stuname']
            subtitle: Text(student['gmail'] ?? 'No Email'), // student['gmail']
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showStudentForm(student: student), // Show form to edit
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteStudent(student['stuid']), // Delete student
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStudentForm(), // Show form to add a new student
        child: Icon(Icons.add),
      ),
    );
  }

}