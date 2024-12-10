import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class StudentForm extends StatefulWidget {
  final Map<String, dynamic>? student;
  final Function(int stuid, List<dynamic> studentData) onSave;
  final List<Map<String, dynamic>> classList; // List of class data with class ID and name

  const StudentForm({
    super.key,
    this.student,
    required this.onSave,
    required this.classList,
  });

  @override
  State<StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _avatarController;
  late TextEditingController _passwordController;
  late TextEditingController _stuidController;
  late TextEditingController _dateOfBirthController;
  String? _gender = "Nam";
  String? _selectedClassId;
  String? _rule = "user"; // Default role

  late List<Map<String, dynamic>> classList = [];  // Khởi tạo danh sách lớp rỗng

  @override
  void initState() {
    super.initState();

    // Khởi tạo các controller
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _avatarController = TextEditingController();
    _passwordController = TextEditingController();
    _stuidController = TextEditingController();
    _dateOfBirthController = TextEditingController();

    // Lấy dữ liệu lớp từ Firebase
    getClassData().then((data) {
      setState(() {
        classList = data;  // Cập nhật lại classList
        // Nếu classList không trống, chọn lớp đầu tiên làm mặc định
        if (classList.isNotEmpty) {
          _selectedClassId = classList[0]['claid'];
        }
      });
    });

    // Nếu có dữ liệu student, gán các giá trị vào các controller
    if (widget.student != null) {
      _nameController.text = widget.student!['stuname'] ?? '';
      _emailController.text = widget.student!['gmail'] ?? '';
      _addressController.text = widget.student!['address'] ?? '';
      _avatarController.text = widget.student!['avatar'] ?? '';
      _passwordController.text = widget.student!['password'] ?? '';
      _stuidController.text = widget.student!['stuid'].toString();
      _rule = widget.student!['rule'] ?? 'user';
      _dateOfBirthController.text = widget.student!['dateofbirth'] ?? '';
      _selectedClassId = widget.student!['claid'];
      _gender = widget.student!['sex'];
    }
  }

  Future<List<Map<String, dynamic>>> getClassData() async {
    final databaseReference = FirebaseDatabase.instance.ref('classes');
    final snapshot = await databaseReference.get();

    if (snapshot.exists) {
      List<dynamic> data = snapshot.value as List<dynamic>;
      List<Map<String, dynamic>> classList = [];

      for (var item in data) {
        if (item != null) {
          classList.add(Map<String, dynamic>.from(item));
        }
      }
      print('Dữ liệu lớp lấy từ Firebase: $classList');
      return classList;
    } else {
      print('Không có dữ liệu lớp từ Firebase');
      return [];
    }
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final stuid = int.tryParse(_stuidController.text) ?? 0;

      // Tạo đối tượng Map để lưu trữ thông tin sinh viên
      Map<String, dynamic> studentData = {
        "stuid": stuid,
        "stuname": _nameController.text,
        "gmail": _emailController.text,
        "password": _passwordController.text,
        "address": _addressController.text,
        "avatar": _avatarController.text,
        "claid": _selectedClassId,
        "dateofbirth": _dateOfBirthController.text,
        "sex": _gender,
        "rule": _rule,
      };

      final databaseReference = FirebaseDatabase.instance.ref('students');
      final snapshot = await databaseReference.get();

      if (snapshot.exists) {
        List<dynamic> students = snapshot.value as List<dynamic>;
        students = students.where((item) => item != null).toList();

        if (widget.student != null) {
          // Cập nhật
          final int index = students.indexWhere((item) => item['stuid'] == stuid);

          if (index != -1) {
            bool isDuplicate = students.any((item) {
              return item['stuid'] == stuid && students.indexOf(item) != index;
            });

            if (isDuplicate) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Mã sinh viên này đã tồn tại!")),
              );
            } else {
              students[index] = studentData;

              try {
                await databaseReference.set(students);
                _showSuccessDialog(message: "Cập nhật dữ liệu thành công!");
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Lỗi khi lưu dữ liệu: $error")),
                );
              }
            }
          }
        } else {
          // Thêm mới
          bool isDuplicate = students.any((item) => item['stuid'] == stuid);

          if (isDuplicate) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Mã sinh viên này đã tồn tại!")),
            );
          } else {
            students.add(studentData); // Thêm dưới dạng Map

            try {
              await databaseReference.set(students);
              _showSuccessDialog(message: "Thêm dữ liệu thành công!");
            } catch (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Lỗi khi lưu dữ liệu: $error")),
              );
            }
          }
        }
      } else {
        // Danh sách trống, thêm sinh viên đầu tiên
        try {
          await databaseReference.set([studentData]); // Lưu dưới dạng danh sách Map
          _showSuccessDialog(message: "Thêm dữ liệu thành công!");
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi khi lưu dữ liệu: $error")),
          );
        }
      }
    }
  }

  void _showSuccessDialog({required String message}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Success"),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Return to the previous screen
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            TextFormField(
              controller: _stuidController,
              decoration: InputDecoration(labelText: "Mã sinh viên"),

              keyboardType: TextInputType.number,

              validator: (value) =>
              value!.isEmpty ? "Mã sinh viên không được để trống" : null,
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Tên sinh viên"),
              validator: (value) =>
              value!.isEmpty ? "Tên không được để trống" : null,
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
              validator: (value) =>
              value!.isEmpty ? "Email không được để trống" : null,
            ),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: "Địa chỉ"),
            ),
            TextFormField(
              controller: _avatarController,
              decoration: InputDecoration(labelText: "Avatar URL"),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Mật khẩu"),
            ),
            TextFormField(
              controller: _dateOfBirthController,
              decoration: InputDecoration(labelText: "Ngày sinh"),
              validator: (value) =>
              value!.isEmpty ? "Ngày sinh không được để trống" : null,
            ),
            DropdownButtonFormField<String>(
              value: _rule, // Giá trị mặc định
              onChanged: null, // Không cho phép thay đổi
              items: [
                DropdownMenuItem(
                  value: "user",
                  child: Text("user"), // Chỉ hiển thị "user"
                ),
              ],
              decoration: InputDecoration(labelText: "Quyền"),
            ),

            DropdownButtonFormField<String>(
              value: _gender,
              onChanged: (value) => setState(() => _gender = value),
              items: ["Nam", "Nữ"].map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              decoration: InputDecoration(labelText: "Giới tính"),
            ),
            // Dropdown cho lớp
            DropdownButtonFormField<String>(
              value: _selectedClassId,
              onChanged: (value) {
                setState(() {
                  _selectedClassId = value;
                });
              },
              items: classList.map((classData) {
                return DropdownMenuItem<String>(
                  value: classData['claid'], // ID lớp
                  child: Text(classData['claname']), // Tên lớp
                );
              }).toList(),
              decoration: InputDecoration(labelText: "Tên lớp"),
              validator: (value) =>
              value == null ? "Lớp không được để trống" : null,
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveForm();
                } else {
                  print('Dữ liệu không hợp lệ');
                }
              },
              child: Text("Lưu"),
            ),
          ],
        ),
      ),
    );
  }
}