import 'package:flutter/material.dart';
import '../Theme/theme.dart';
import '../Wigets/custom_scaffold.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  bool rememberPassword = true;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Spacer(flex: 1), // Thay thế Expanded bằng Spacer để tối ưu hóa
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
                      _buildEmailField(),
                      const SizedBox(height: 20),
                      _buildPasswordField(),
                      const SizedBox(height: 20),
                      _buildRememberPasswordRow(),
                      const SizedBox(height: 30),
                      _buildLoginButton(context),
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

  // Hàm xây dựng TextFormField Email
  Widget _buildEmailField() {
    return TextFormField(
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
        GestureDetector(
          child: Text(
            'Quên mật khẩu?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: lightColorScheme.primary,
            ),
          ),
          onTap: () {
            // Xử lý khi người dùng nhấn "Quên mật khẩu"
          },
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
          if (_formSignInKey.currentState!.validate() && rememberPassword) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Processing Data')),
            );
          } else if (!rememberPassword) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please agree to the processing of your data'),
              ),
            );
          }
        },
        child: const Text('Đăng nhập'),
      ),
    );
  }
}
