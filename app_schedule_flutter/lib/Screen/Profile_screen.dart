import 'package:app_schedule_flutter/Screen/timetable_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'UpdateProfileScreen.dart';
import 'login_screen.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child(
      'students');
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Map<String, dynamic>? userInfo;
  String? _imageUrl;
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? mssv = prefs.getString('mssv');

      if (mssv != null) {
        DataSnapshot snapshot = await _dbRef.orderByChild('stuid').equalTo(
            int.parse(mssv)).get();

        if (snapshot.exists) {
          Map<dynamic, dynamic> studentData = snapshot.value as Map<
              dynamic,
              dynamic>;
          if (studentData.isNotEmpty) {
            setState(() {
              userInfo = Map<String, dynamic>.from(studentData.values.first);
              _imageUrl = userInfo!['imageUrl'] ??
                  ''; // Lưu URL hình đại diện, mặc định là chuỗi rỗng
            });
          }
        }
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
      final UploadTask uploadTask = _storage.ref(fileName).putFile(
          File(image.path));
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        _imageUrl = downloadUrl;
      });

      // Cập nhật URL vào Firebase Database
      await _dbRef.child(userInfo!['stuid'].toString()).update(
          {'imageUrl': downloadUrl});
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
              onPressed: () => Navigator.pop(context), // Đóng hộp thoại
              child: Text('Hủy', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () async {
                // Xóa dữ liệu đăng nhập từ SharedPreferences
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // Xóa tất cả dữ liệu

                // Chuyển đến màn hình đăng nhập
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (Route<
                      dynamic> route) => false, // Loại bỏ tất cả các route trước đó
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
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
                onTap: _pickImage, // Gọi hàm chọn hình khi nhấn vào avatar
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
                    backgroundImage: _imageUrl != null ? NetworkImage(
                        _imageUrl!) : null,
                    child: _imageUrl == null ? const Icon(
                        Icons.person, size: 40, color: Colors.white) : null,
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
                            builder: (context) =>
                                UpdateProfileScreen(userInfo: userInfo!),
                          ),
                        );
                        if (result != null) {
                          _fetchUserData();
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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
              _buildInfoRow(
                  Icons.badge_outlined, "MSSV", userInfo!['stuid'].toString()),
              _buildInfoRow(Icons.email_outlined, "Email", userInfo!['gmail']),
              _buildInfoRow(Icons.class_outlined, "Lớp",
                  userInfo!['claname'] ?? 'Chưa có lớp'),
              _buildInfoRow(Icons.school_outlined, "Khoa",
                  userInfo!['facuname'] ?? 'Chưa có khoa'),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
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
            icon: Icons.star_outline,
            title: 'Đánh giá ứng dụng',
            subtitle: 'Chia sẻ ý kiến của bạn',
            onTap: () {
              // TODO: Implement app rating
            },
          ),
          const SizedBox(height: 16),
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
                    color: isLogout ? Colors.red.shade400 : Colors.blue
                        .shade600,
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isLogout ? Colors.red.shade400 : Colors
                              .black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
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

