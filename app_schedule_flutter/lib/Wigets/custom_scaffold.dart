import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Sử dụng hình nền gradient với màu xanh nước biển đậm hơn
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0077B3), Color(0xFF66B2D9)], // Thay đổi màu xanh
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Hình ảnh logo (đã chỉnh sửa kích thước và vị trí)
          Positioned(
            top: 30, // Nâng logo lên một chút
            left: MediaQuery.of(context).size.width * 0.5 - 75, // Giữa màn hình
            child: Image.asset(
              'assets/images/logo.png',
              width: 150, // Kích thước logo
              height: 150, // Kích thước logo
            ),
          ),
          SafeArea(
            child: child!,
          ),
        ],
      ),
    );
  }
}
