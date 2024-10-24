import 'package:app_schedule_flutter/Screen/Home_screen.dart';
import 'package:app_schedule_flutter/Screen/Reset_Password_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Nhập thư viện shared_preferences
import '../Theme/theme.dart';
import '../Wigets/custom_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  final TextEditingController _mssvController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool rememberPassword = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials(); // Gọi hàm để lấy thông tin lưu trữ khi khởi động
  }

  // Hàm lấy MSSV và mật khẩu đã lưu
  Future<void> _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _mssvController.text = prefs.getString('mssv') ?? '';
    _passwordController.text = prefs.getString('password') ?? '';
  }

  // Hàm lưu MSSV và mật khẩu
  Future<void> _rememberPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (rememberPassword) {
      await prefs.setString('mssv', _mssvController.text);
      await prefs.setString('password', _passwordController.text);
    } else {
      await prefs.remove('mssv');
      await prefs.remove('password');
    }
  }

  // Hàm đăng nhập với MSSV
  Future<void> _loginWithMSSV(String mssv, String password) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('students');

    DataSnapshot snapshot = await ref.orderByChild('stuid').equalTo(int.parse(mssv)).get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> studentData = snapshot.value as Map<dynamic, dynamic>;

      if (studentData.isNotEmpty) {
        String storedPassword = studentData.values.first['password'];
        if (storedPassword == password) {
          // Chuyển đến màn hình chính sau khi đăng nhập thành công
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng nhập thành công')),
          );

          // Ghi nhớ thông tin đăng nhập
          await _rememberPassword();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mật khẩu không đúng')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MSSV không tồn tại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Spacer(flex: 1),
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
                  key: _formSignInKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildWelcomeText(),
                      const SizedBox(height: 20),
                      _buildMSSVField(),
                      const SizedBox(height: 20),
                      _buildPasswordField(),
                      const SizedBox(height: 20),
                      _buildRememberPasswordRow(),
                      const SizedBox(height: 30),
                      _buildLoginButton(context),
                      const SizedBox(height: 20),
                      GestureDetector(
                        child: Text(
                          'Quên mật khẩu?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: lightColorScheme.primary,
                          ),
                        ),
                        onTap: () {
                          // Chuyển đến màn hình quên mật khẩu
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 60),
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

  // Hàm xây dựng Text chào mừng
  Widget _buildWelcomeText() {
    return Text(
      'Chào mừng',
      style: TextStyle(
        fontSize: 35.0,
        fontWeight: FontWeight.w900,
        color: lightColorScheme.primary,
      ),
    );
  }

  // Hàm xây dựng TextFormField cho MSSV
  Widget _buildMSSVField() {
    return TextFormField(
      controller: _mssvController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập MSSV';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'MSSV',
        hintText: 'Nhập MSSV',
        hintStyle: const TextStyle(color: Colors.black26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
        ),
      ),
    );
  }

  // Hàm xây dựng TextFormField mật khẩu
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      obscuringCharacter: '*',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập mật khẩu';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Mật khẩu',
        hintText: 'Nhập mật khẩu',
        hintStyle: const TextStyle(color: Colors.black26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
        ),
      ),
    );
  }

  // Hàm xây dựng hàng checkbox và quên mật khẩu
  Widget _buildRememberPasswordRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: rememberPassword,
              onChanged: (bool? value) {
                setState(() {
                  rememberPassword = value!;
                });
              },
              activeColor: lightColorScheme.primary,
            ),
            const Text(
              'Ghi nhớ mật khẩu',
              style: TextStyle(color: Colors.black45),
            ),
          ],
        ),
      ],
    );
  }

  // Hàm xây dựng nút đăng nhập
  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formSignInKey.currentState!.validate()) {
            _loginWithMSSV(_mssvController.text, _passwordController.text);
          }
        },
        child: const Text('Đăng nhập'),
      ),
    );
  }
}
