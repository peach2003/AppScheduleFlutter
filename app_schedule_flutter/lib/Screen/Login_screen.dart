
import 'package:app_schedule_flutter/Screen/Dashboard.dart';
import 'package:app_schedule_flutter/Screen/Home_screen.dart';
import 'package:app_schedule_flutter/Screen/Reset_Password_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Admin/Admindashboard.dart';
import '../Theme/theme.dart';
import '../Wigets/custom_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formSignInKey = GlobalKey<FormState>();
  final TextEditingController _mssvController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool rememberPassword = true;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadSavedCredentials();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mssvController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _mssvController.text = prefs.getString('mssv') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
    });
  }

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

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 15),
                const Text(
                  'Đang đăng nhập...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  Future<void> _loginWithMSSV(String mssv, String password) async {
    if (!_isLoading) {
      setState(() => _isLoading = true);
      _showLoadingDialog();

      try {
        final int parsedMssv = int.parse(mssv);

        // Kiểm tra tài khoản trong bảng students
        DatabaseReference studentRef = FirebaseDatabase.instance.ref().child('students');
        DataSnapshot studentSnapshot = await studentRef.orderByChild('stuid').equalTo(parsedMssv).get();

        // Kiểm tra tài khoản trong bảng admins
        DatabaseReference adminRef = FirebaseDatabase.instance.ref().child('admins');
        DataSnapshot adminSnapshot = await adminRef.orderByChild('adminid').equalTo(parsedMssv).get();

        // Kiểm tra nếu tài khoản là sinh viên
        if (studentSnapshot.exists) {
          print("Dữ liệu từ students: ${studentSnapshot.value}");

          if (studentSnapshot.value is Map) {
            // Nếu dữ liệu là Map, chuyển sang kiểu Map để xử lý
            Map<dynamic, dynamic> studentMap = studentSnapshot.value as Map<dynamic, dynamic>;

            // Tìm kiếm sinh viên theo stuid
            var studentData = studentMap.values.firstWhere(
                  (student) => student['stuid'] == parsedMssv,
              orElse: () => null,
            );

            if (studentData != null && studentData['password'] == password) {
              // Lưu thông tin đăng nhập
              await _rememberPassword();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('userId', mssv);
              await prefs.setBool('isLoggedIn', true);

              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Dashboad()), // Trang dashboard sinh viên
              );
              return;
            } else {
              Navigator.of(context).pop();
              _showErrorSnackBar('Mật khẩu không đúng');
              return;
            }
          } else if (studentSnapshot.value is List) {
            // Nếu dữ liệu là List, xử lý theo cách của List
            List<dynamic> studentList = studentSnapshot.value as List<dynamic>;

            // Tìm kiếm sinh viên theo stuid
            var studentData = studentList.firstWhere(
                  (student) => student['stuid'] == parsedMssv,
              orElse: () => null,
            );

            if (studentData != null && studentData['password'] == password) {
              // Lưu thông tin đăng nhập
              await _rememberPassword();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('userId', mssv);
              await prefs.setBool('isLoggedIn', true);

              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Dashboad()), // Trang dashboard sinh viên
              );
              return;
            } else {
              Navigator.of(context).pop();
              _showErrorSnackBar('Mật khẩu không đúng');
              return;
            }
          }
        }

        // Kiểm tra nếu tài khoản là admin
        if (adminSnapshot.exists) {
          print("Dữ liệu từ admins: ${adminSnapshot.value}");

          if (adminSnapshot.value is Map) {
            // Nếu dữ liệu là Map, chuyển sang kiểu Map để xử lý
            Map<dynamic, dynamic> adminMap = adminSnapshot.value as Map<dynamic, dynamic>;

            // Tìm kiếm admin theo adminid
            var adminData = adminMap.values.firstWhere(
                  (admin) => admin['adminid'] == parsedMssv,
              orElse: () => null,
            );

            if (adminData != null && adminData['password'] == password) {
              // Lưu thông tin đăng nhập
              await _rememberPassword();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('userId', mssv);
              await prefs.setBool('isLoggedIn', true);

              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => admindashboard()), // Trang dashboard admin
              );
            } else {
              Navigator.of(context).pop();
              _showErrorSnackBar('Mật khẩu không đúng');
            }
          } else if (adminSnapshot.value is List) {
            // Nếu dữ liệu là List, xử lý theo cách của List
            List<dynamic> adminList = adminSnapshot.value as List<dynamic>;

            // Tìm kiếm admin theo adminid
            var adminData = adminList.firstWhere(
                  (admin) => admin['adminid'] == parsedMssv,
              orElse: () => null,
            );

            if (adminData != null && adminData['password'] == password) {
              // Lưu thông tin đăng nhập
              await _rememberPassword();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('userId', mssv);
              await prefs.setBool('isLoggedIn', true);

              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => admindashboard()), // Trang dashboard admin
              );
            } else {
              Navigator.of(context).pop();
              _showErrorSnackBar('Mật khẩu không đúng');
            }
          }
        } else {
          Navigator.of(context).pop();
          _showErrorSnackBar('Tài khoản không tồn tại');
        }
      } catch (e) {
        Navigator.of(context).pop();
        _showErrorSnackBar('Đã có lỗi xảy ra. Vui lòng thử lại sau.\nLỗi: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }





  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Stack(
        children: [
          Column(
            children: [
              const Spacer(),
              Expanded(
                flex: 7,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formSignInKey,
                        child: Column(
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 40),
                            _buildLoginForm(),
                            const SizedBox(height: 30),
                            _buildLoginButton(),
                            const SizedBox(height: 20),
                            _buildForgotPassword(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Chào mừng',
          style: TextStyle(
            fontSize: 35.0,
            fontWeight: FontWeight.w900,
            color: lightColorScheme.primary,
            letterSpacing: 1.5,
            shadows: [
              Shadow(
                offset: const Offset(1, 1),
                blurRadius: 2.0,
                color: Colors.black.withOpacity(0.1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Đăng nhập để tiếp tục',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        _buildInputField(
          controller: _mssvController,
          label: 'MSSV',
          hint: 'Nhập MSSV của bạn',
          prefixIcon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập MSSV';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildInputField(
          controller: _passwordController,
          label: 'Mật khẩu',
          hint: 'Nhập mật khẩu của bạn',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập mật khẩu';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        _buildRememberPasswordRow(),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        validator: validator,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(prefixIcon, color: lightColorScheme.primary),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() => _isPasswordVisible = !_isPasswordVisible);
            },
          )
              : null,
        ),
      ),
    );
  }

  Widget _buildRememberPasswordRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          value: rememberPassword,
          onChanged: (value) {
            setState(() => rememberPassword = value!);
          },
        ),
        Text(
          'Lưu thông tin đăng nhập',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () {
          if (_formSignInKey.currentState!.validate()) {
            _loginWithMSSV(_mssvController.text, _passwordController.text);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: lightColorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'Đăng nhập',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
        );
      },
      child: Text(
        'Quên mật khẩu?',
        style: TextStyle(
          color: lightColorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
