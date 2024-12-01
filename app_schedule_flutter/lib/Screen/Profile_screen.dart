import 'package:app_schedule_flutter/Screen/timetable_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/Class.dart';
import '../Model/Faculty.dart';
import 'UpdateProfileScreen.dart';
import 'login_screen.dart';
import 'dart:io';

// ProfileScreen Widget
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('students');
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Map<String, dynamic>? userInfo;
  String? _avatarUrl;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _fetchUserData();
    _animationController.forward();
  }

  Future<void> _fetchUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? mssv = prefs.getString('mssv');
      print('MSSV từ SharedPreferences: $mssv');

      if (mssv != null) {
        // Truy xuất toàn bộ danh sách `students`
        DataSnapshot studentSnapshot = await _dbRef.get();
        print('Student snapshot tồn tại: ${studentSnapshot.exists}');

        if (studentSnapshot.exists && studentSnapshot.value is List) {
          // Chuyển đổi dữ liệu thành một List, bỏ qua giá trị `null`
          List<dynamic> studentData = (studentSnapshot.value as List).where((entry) => entry != null).toList();
          print('Dữ liệu sinh viên (sau khi bỏ qua null): $studentData');

          // Lọc sinh viên với MSSV phù hợp
          var matchedStudent = studentData.firstWhere(
                  (student) => student['stuid'].toString() == mssv,
              orElse: () => null
          );

          if (matchedStudent != null) {
            Map<String, dynamic> student = Map<String, dynamic>.from(matchedStudent);
            print('Thông tin sinh viên tìm thấy: $student');

            String? claid = student['claid']?.toString();
            print('ClaID: $claid');

            String className = 'Chưa có lớp';
            String facultyName = 'Chưa có khoa';

            if (claid != null) {
              DataSnapshot classSnapshot = await FirebaseDatabase.instance.ref().child('classes').child(claid).get();
              print('Class snapshot tồn tại: ${classSnapshot.exists}');

              if (classSnapshot.exists) {
                Map<String, dynamic> classData = Map<String, dynamic>.from(classSnapshot.value as Map);
                className = classData['claname'];
                print('Tên lớp: $className');

                String facid = classData['facid'];
                DataSnapshot facultySnapshot = await FirebaseDatabase.instance.ref().child('faculty').orderByChild('facid').equalTo(facid).get();
                print('Faculty snapshot tồn tại: ${facultySnapshot.exists}');

                if (facultySnapshot.exists) {
                  Map<String, dynamic> facultyData = Map<String, dynamic>.from((facultySnapshot.value as Map).values.first);
                  facultyName = facultyData['facname'];
                  print('Tên khoa: $facultyName');
                } else {
                  print('Không tìm thấy thông tin khoa cho FacID: $facid');
                }
              } else {
                print('Không tìm thấy thông tin lớp cho ClaID: $claid');
              }
            }

            setState(() {
              userInfo = student;
              _avatarUrl = student['avatar'] ?? '';
              userInfo!['claid'] = className;
              userInfo!['facuname'] = facultyName;
            });
          } else {
            print('Không tìm thấy dữ liệu sinh viên cho MSSV: $mssv');
          }
        } else {
          print('Dữ liệu sinh viên không tồn tại hoặc không phải là dạng List');
        }
      } else {
        print('MSSV chưa được lưu trong SharedPreferences');
      }
    } catch (e) {
      print('Lỗi khi lấy dữ liệu sinh viên: $e');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      await _uploadImage(image);
    }
  }

  Future<void> _uploadImage(XFile image) async {
    try {
      final String fileName = 'profile_images/${userInfo!['stuid']}.jpg';
      final UploadTask uploadTask = _storage.ref(fileName).putFile(File(image.path));
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        _avatarUrl = downloadUrl;
      });

      // Cập nhật URL vào Firebase Database
      await _dbRef.child(userInfo!['stuid'].toString()).update({'avatar': downloadUrl});
    } catch (e) {
      print('Lỗi khi tải lên hình ảnh: $e');
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Xác nhận đăng xuất',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: userInfo == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade400, Colors.blue.shade50],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildProfileInfo(),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.blue,
                    backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                    child: _avatarUrl == null ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userInfo!['stuname'] ?? 'Chưa có tên',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 3,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateProfileScreen(userInfo: {
                              ...userInfo!, // Dữ liệu sinh viên hiện tại
                              'claid': userInfo!['claid'] ?? 'Chưa có lớp', // Lớp
                              'facuname': userInfo!['facuname'] ?? 'Chưa có khoa', // Khoa
                            },),
                          ),
                        );
                        if (result != null) {
                          _fetchUserData();
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        backgroundColor: Colors.black12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.edit,
                            size: 18,
                            color: Colors.white,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'Cập nhật thông tin cá nhân',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Tổng Quan',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(Icons.badge_outlined, "MSSV", userInfo!['stuid'].toString()),
              _buildInfoRow(Icons.email_outlined, "Email", userInfo!['gmail']),
              _buildInfoRow(Icons.class_outlined, "Lớp", userInfo!['claid'] ?? 'Chưa có lớp'),
              _buildInfoRow(Icons.school_outlined, "Khoa", userInfo!['facuname'] ?? 'Chưa có khoa'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.blue.shade700, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildActionButton(
            icon: Icons.support_agent_outlined,
            title: 'Hỗ trợ',
            subtitle: 'Liên hệ với chúng tôi',
            onTap: () {
              // TODO: Implement support
            },
          ),
          const SizedBox(height: 16),

          _buildActionButton(
            icon: Icons.star_outline,
            title: 'Đánh giá ứng dụng',
            subtitle: 'Chia sẻ ý kiến của bạn',
            onTap: () {
              // TODO: Implement app rating
            },
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            icon: Icons.logout_outlined,
            title: 'Đăng xuất',
            subtitle: 'Đăng xuất khỏi tài khoản',
            onTap: _logout,
            isLogout: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isLogout ? Colors.red.shade50 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: isLogout ? Colors.red.shade400 : Colors.blue.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isLogout ? Colors.red.shade400 : Colors.black87),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
