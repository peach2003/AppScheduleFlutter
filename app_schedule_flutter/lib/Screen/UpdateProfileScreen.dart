import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UpdateProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userInfo;

  const UpdateProfileScreen({Key? key, required this.userInfo}) : super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('students');
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _mssvController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _facultyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _mssvController.text = widget.userInfo['stuid']?.toString() ?? '';
    _nameController.text = widget.userInfo['stuname'] ?? '';
    _emailController.text = widget.userInfo['gmail'] ?? '';
    _classController.text = widget.userInfo['claname'] ?? '';
    _facultyController.text = widget.userInfo['facuname'] ?? '';
    _imageUrl = widget.userInfo['imageUrl'];
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> updatedData = {
        'stuname': _nameController.text.trim(),
        'gmail': _emailController.text.trim(),
        'claname': _classController.text.trim(),
        'facuname': _facultyController.text.trim(),
      };

      // Only update the image URL if a new image has been uploaded
      if (_imageUrl != null) {
        updatedData['imageUrl'] = _imageUrl;
      }

      await _dbRef.child(widget.userInfo['stuid'].toString()).update(updatedData);

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _isLoading = true);

      try {
        File imageFile = File(pickedFile.path);
        String fileName = '${widget.userInfo['stuid']}_profile.jpg';
        Reference storageRef = _storage.ref().child('profile_images/$fileName');
        UploadTask uploadTask = storageRef.putFile(imageFile);

        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() => _imageUrl = downloadUrl);
      } catch (e) {
        _showErrorSnackBar('Error uploading image: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Thành công'),
          ],
        ),
        content: const Text('Thông tin đã được cập nhật thành công!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, 'Cập nhật thông tin thành công!');
            },
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }


  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Lỗi khi cập nhật thông tin: $error')),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(),
              _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: const Text(
        'Cập nhật thông tin',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.black87),
      centerTitle: true,
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildProfileImage(),
          const SizedBox(height: 16),
          Text(
            _nameController.text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          // Remove the MSSV Text widget
          // const SizedBox(height: 8), // You can keep this if you want some spacing
          const SizedBox(height: 20),
        ],
      ),
    );
  }


  Widget _buildProfileImage() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: _imageUrl != null
              ? NetworkImage(_imageUrl!)
              : const AssetImage('assets/images/default_profile.png') as ImageProvider,
          backgroundColor: Colors.transparent,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputField(
              controller: _mssvController,
              label: 'MSSV',
              icon: Icons.badge_outlined,
              enabled: false,
              backgroundColor: Colors.grey[100]!,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _nameController,
              label: 'Tên sinh viên',
              icon: Icons.person_outline,
              enabled: false,
              backgroundColor: Colors.grey[100]!,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _classController,
              label: 'Lớp',
              icon: Icons.class_outlined,
              enabled: false,
              backgroundColor: Colors.grey[100]!,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _facultyController,
              label: 'Khoa',
              icon: Icons.school_outlined,
              enabled: false,
              backgroundColor: Colors.grey[100]!,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              enabled: true,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateProfile,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Cập nhật thông tin'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    Color backgroundColor = Colors.white,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label không được để trống';
        }
        return null;
      },
    );
  }
}
