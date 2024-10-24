import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Theme/theme.dart'; // Import theme for color usage
import '../Wigets/custom_scaffold.dart'; // Import custom scaffold

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _mssvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(height: 10), // Space at the top
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Quên Mật Khẩu',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildMSSVField(),
                      const SizedBox(height: 20),
                      _buildResetPasswordButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build TextFormField for MSSV
  Widget _buildMSSVField() {
    return TextFormField(
      controller: _mssvController,
      decoration: InputDecoration(
        labelText: 'MSSV',
        hintText: 'Nhập MSSV của bạn',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: lightColorScheme.primary), // Color when focused
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập MSSV'; // Validation message
        }
        return null;
      },
    );
  }

  // Build button to reset password
  Widget _buildResetPasswordButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          String mssv = _mssvController.text;
          await _resetPassword(mssv, context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: lightColorScheme.primary, // Use color from theme
          padding: const EdgeInsets.symmetric(vertical: 15), // Increase button padding
        ),
        child: const Text('Đặt Lại Mật Khẩu', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  // Reset password function
  Future<void> _resetPassword(String mssv, BuildContext context) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('students');

    try {
      DataSnapshot snapshot = await ref.orderByChild('stuid').equalTo(int.parse(mssv)).get();

      if (snapshot.exists) {
        // Get data from snapshot
        Map<dynamic, dynamic> studentData = snapshot.value as Map<dynamic, dynamic>;

        // Get the key of the first object
        String studentKey = studentData.keys.first; // Access the first key
        String newPassword = '123456'; // New password

        // Update password
        await ref.child(studentKey).update({'password': newPassword});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mật khẩu đã được đặt lại. Mật khẩu mới là: $newPassword')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('MSSV không tồn tại')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: ${e.toString()}')),
      );
    }
  }
}
