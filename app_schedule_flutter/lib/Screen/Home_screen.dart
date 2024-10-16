import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart'; // Thêm thư viện để khởi tạo locale

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _weather = "Đang tải...";
  String _currentDate = "Đang tải...";
  Position? _currentPosition;
  IconData _weatherIcon = Icons.wb_sunny_outlined; // icon mặc định

  @override
  void initState() {
    super.initState();
    // Khởi tạo dữ liệu locale cho tiếng Việt
    initializeDateFormatting('vi', null).then((_) {
      setState(() {
        _currentDate = DateFormat('d MMMM, yyyy', 'vi').format(DateTime.now());
      });
    });
    _loadWeatherFromPreferences(); // Tải dữ liệu từ shared_preferences khi khởi động
  }

  // Hàm ánh xạ mô tả thời tiết với icon
  IconData _getWeatherIcon(String weatherDescription) {
    if (weatherDescription.contains("clear")) {
      return Icons.wb_sunny_outlined; // Trời nắng
    } else if (weatherDescription.contains("rain")) {
      return Icons.beach_access_outlined; // Mưa
    } else if (weatherDescription.contains("cloud")) {
      return Icons.wb_cloudy_outlined; // Nhiều mây
    } else if (weatherDescription.contains("snow")) {
      return Icons.ac_unit_outlined; // Tuyết
    } else if (weatherDescription.contains("thunderstorm")) {
      return Icons.flash_on_outlined; // Dông bão
    } else {
      return Icons.wb_sunny_outlined; // Mặc định là nắng
    }
  }

  // Hàm chuyển thông tin thời tiết sang tiếng Việt
  String _translateWeatherDescription(String weatherDescription) {
    if (weatherDescription.contains("clear")) {
      return "Trời nắng";
    } else if (weatherDescription.contains("rain")) {
      return "Mưa";
    } else if (weatherDescription.contains("cloud")) {
      return "Nhiều mây";
    } else if (weatherDescription.contains("snow")) {
      return "Tuyết";
    } else if (weatherDescription.contains("thunderstorm")) {
      return "Dông bão";
    } else {
      return weatherDescription; // Nếu không tìm thấy từ nào, trả về nguyên văn
    }
  }

  Future<void> _fetchWeatherData(double lat, double lon) async {
    final apiKey = 'a10c2b29a19ed5f2cc6691a6c6cf1966'; // Thay bằng API key của bạn
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final weatherDescription = data['weather'][0]['description'];
        final weatherMain = data['weather'][0]['main']; // Loại thời tiết chính
        setState(() {
          _weather = _translateWeatherDescription(weatherMain.toLowerCase()); // Cập nhật mô tả thời tiết
          _weatherIcon = _getWeatherIcon(weatherMain.toLowerCase()); // Cập nhật icon
        });

        // Lưu dữ liệu vào shared_preferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('weather', _weather);
        prefs.setString('weatherIcon', weatherMain.toLowerCase());
      } else {
        setState(() {
          _weather = 'Không thể tải thông tin thời tiết: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _weather = 'Có lỗi xảy ra: $e';
      });
    }
  }

  // Hàm lấy vị trí hiện tại
  Future<void> _getCurrentLocation() async {
    bool serviceEnable;
    LocationPermission permission;

    // Kiểm tra dịch vụ định vị có bật hay không?
    serviceEnable = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnable) {
      setState(() {
        _weather = "Dịch vụ định vị bị tắt.";
      });
      return;
    }

    // Kiểm tra quyền truy cập vị trí
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _weather = "Quyền truy cập vị trí bị từ chối.";
        });
        return;
      }
    }

    // Nếu có quyền truy cập, lấy vị trí hiện tại
    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Gọi hàm để lấy thông tin thời tiết sau khi có vị trí
    _fetchWeatherData(_currentPosition!.latitude, _currentPosition!.longitude);
  }

  // Tải dữ liệu thời tiết từ shared_preferences
  Future<void> _loadWeatherFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedWeather = prefs.getString('weather');
    String? savedWeatherIcon = prefs.getString('weatherIcon');

    if (savedWeather != null && savedWeatherIcon != null) {
      setState(() {
        _weather = savedWeather;
        _weatherIcon = _getWeatherIcon(savedWeatherIcon);
      });
    } else {
      _getCurrentLocation(); // Nếu không có dữ liệu, gọi API để lấy dữ liệu mới
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 280,
              child: Stack(
                children: [
                  // Background nền phía trên
                  Container(
                    padding: EdgeInsets.all(16),
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Căn chỉnh logo, avatar, thông báo
                        Container(
                          margin: EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset(
                                "assets/images/logo.png",
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.notifications_none, size: 30),
                                    onPressed: () {
                                      // Chức năng thông báo ở đây
                                    },
                                  ),
                                  SizedBox(width: 10),
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        'https://th.bing.com/th/id/R.ea888ce8ab1a32ebdf8aac4a3ba23263?rik=ysYySzGU8J%2bzzQ&riu=http%3a%2f%2fwww.healthyfoodhouse.com%2fwp-content%2fuploads%2f2012%2f10%2fhealthy-drinks.jpg&ehk=WWaIyOgZ3UgnS%2fLWh%2bRowgeG3SHc18ccBN5bqmP9ruk%3d&risl=&pid=ImgRaw&r=0'),
                                    radius: 20,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Căn chỉnh thời tiết ngày tháng
                        Row(
                          children: [
                            Icon(_weatherIcon, size: 30),
                            SizedBox(width: 5),
                            Text('('+
                              '$_weather'+ ')',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(width: 10),
                            Text(
                              _currentDate,
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Căn chỉnh container chức năng
                  Positioned(
                    top: 160,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        border: Border.all(color: Colors.green.shade200, width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildOption(Icons.today_outlined, 'Lịch học'),
                          _buildOption(Icons.campaign_outlined, 'Sự kiện'),
                          _buildOption(Icons.event_available_outlined, 'SK đã lưu'),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HUTECH-ers sẵn sàng bùng nổ cùng Đêm hội văn hóa Chào năm học mới 2024-2025 và Phát động Miss HUTECH 2025 vào 11/10 tới',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '5/10/2024 8:00 SA',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Image(
                  image: NetworkImage(
                      'https://th.bing.com/th/id/R.ea888ce8ab1a32ebdf8aac4a3ba23263?rik=ysYySzGU8J%2bzzQ&riu=http%3a%2f%2fwww.healthyfoodhouse.com%2fwp-content%2fuploads%2f2012%2f10%2fhealthy-drinks.jpg&ehk=WWaIyOgZ3UgnS%2fLWh%2bRowgeG3SHc18ccBN5bqmP9ruk%3d&risl=&pid=ImgRaw&r=0'),
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tin sự kiện', style: TextStyle(fontSize: 16)),
                  TextButton(
                    onPressed: () {
                      // Chức năng xem tất cả sự kiện
                    },
                    child: Text('Xem thêm', style: TextStyle(fontSize: 16, color: Colors.blue)),
                  ),
                ],
              ),
            ),
            _buildEventList(),
          ],
        ),
      ),
    );
  }
}

Widget _buildOption(IconData icon, String label) {
  return Column(
    children: [
      Icon(icon, size: 35),
      SizedBox(height: 8),
      Text(label, style: TextStyle(fontSize: 15)),
    ],
  );
}

Widget _buildEventList() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: List.generate(3, (index) {
        return Column(
          children: [
            Row(
              children: [
                Image(
                  image: NetworkImage(
                      'https://th.bing.com/th/id/R.ea888ce8ab1a32ebdf8aac4a3ba23263?rik=ysYySzGU8J%2bzzQ&riu=http%3a%2f%2fwww.healthyfoodhouse.com%2fwp-content%2fuploads%2f2012%2f10%2fhealthy-drinks.jpg&ehk=WWaIyOgZ3UgnS%2fLWh%2bRowgeG3SHc18ccBN5bqmP9ruk%3d&risl=&pid=ImgRaw&r=0'),
                  width: 80,
                  height: 80,
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error);
                  },
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nội dung sự kiện', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      Text('5/10/2024 8:00 SA', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            Divider(),
          ],
        );
      }),
    ),
  );
}
