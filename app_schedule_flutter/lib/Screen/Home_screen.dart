import 'package:app_schedule_flutter/Screen/Dashboard.dart';
import 'package:app_schedule_flutter/Screen/Detail_Event_screen.dart';
import 'package:app_schedule_flutter/Screen/Event_screen.dart';
import 'package:app_schedule_flutter/Screen/Save_Event_screen.dart';
import 'package:app_schedule_flutter/Screen/timetable_screen.dart';
import 'package:app_schedule_flutter/Service/FirebaseService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../Model/Event.dart'; // Thêm thư viện để khởi tạo locale

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
  FirebaseService firebaseService= FirebaseService();
  List<Event> events=[];
  Event? latesEvent;


  @override
  void initState() {
    super.initState();
    // Khởi tạo dữ liệu locale cho tiếng Việt
    initializeDateFormatting('vi', null).then((_) {
      setState(() {
        _currentDate = DateFormat('d MMMM, yyyy', 'vi').format(DateTime.now());
      });
    });
    _fetchEvents();
    _loadWeatherFromPreferences(); // Tải dữ liệu từ shared_preferences khi khởi động
  }
  Future<void> _fetchEvents() async {
    firebaseService.getEventRef().onValue.listen((event) {
      final dataSnapshot = event.snapshot;
      if (dataSnapshot.exists) {
        Map<dynamic, dynamic> eventMap = dataSnapshot.value as Map<dynamic, dynamic>;
        List<Event> allEvents = [];
        eventMap.forEach((key, value) {
          allEvents.add(Event.fromSnapshot(value));
        });
        // Sắp xếp sự kiện theo thời gian giảm dần
        allEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        setState(() {
          latesEvent = allEvents.isNotEmpty ? allEvents.removeAt(0) : null; // Sự kiện mới nhất
          events = allEvents;
        });
      } else {
        setState(() {
          events = [];
          latesEvent = null;
        });
      }
    });
  }

  Widget _buildEventList() {
    if(events.isEmpty){
      return Center(child: Text('Không có sự kiện nào.'));
    }
    //Giới hạn chỉ lấy 3 sự kiện mới nhất
    List<Event> recentEvents= events.take(3).toList();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: recentEvents.map((event){
            return GestureDetector(
              onTap: (){
                // Điều hướng sang màn hình chi tiết sự kiện khi nhấp vào
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context)=>DetailEvent(event: event,),
                  ),
                );
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.network(
                        event.image,
                        width: 90,
                        height: 70,
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
                            Text(event.title, style: TextStyle(fontSize: 19), maxLines: 2, overflow: TextOverflow.ellipsis,),
                            SizedBox(height: 8),
                            Text(
                              DateFormat('d/MM/yyyy, h:mm a').format(event.createdAt),
                              style: TextStyle(color: Colors.grey, fontSize: 17),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                ],
              ),
            );
          }).toList(),
        ),
      );
  }


  // Hàm ánh xạ mô tả thời tiết với icon
  IconData _getWeatherIcon(String weatherDescription) {
    if (weatherDescription.contains("clear")) {
      return Icons.wb_sunny_outlined;
    } else if (weatherDescription.contains("rain")) {
      return Icons.beach_access_outlined;
    } else if (weatherDescription.contains("cloud")) {
      return Icons.wb_cloudy_outlined;
    } else if (weatherDescription.contains("snow")) {
      return Icons.ac_unit_outlined;
    } else if (weatherDescription.contains("thunderstorm")) {
      return Icons.flash_on_outlined;
    } else {
      return Icons.wb_sunny_outlined;
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
      return weatherDescription;
    }
  }

  Future<void> _fetchWeatherData(double lat, double lon) async {
    final apiKey = 'a10c2b29a19ed5f2cc6691a6c6cf1966';
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
      _getCurrentLocation();
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
              height: 310,
              child: Stack(
                children: [
                  // Background nền phía trên
                  Container(
                    padding: EdgeInsets.all(16),
                    height: 230,
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
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
                        SizedBox(
                          height: 10,
                        ),
                        // Căn chỉnh thời tiết ngày tháng
                        Row(
                          children: [
                            Icon(_weatherIcon, size: 30),
                            SizedBox(width: 5),
                            Text('('+
                              '$_weather'+ ')',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(width: 10),
                            Text(
                              _currentDate,
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Căn chỉnh container chức năng
                  Positioned(
                    top: 170,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        border: Border.all(color: Colors.grey.shade400, width: 3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildOption('assets/images/conference.png', 'Thời khóa biểu',(){
                            //Hàm click vào sẽ chuyển hướng
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context)=> TimetableScreen(),
                              )
                            );
                          }),
                          _buildOption('assets/images/party.png', 'Sự kiện',(){
                            //Hàm click vào sẽ chuyển hướng
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context)=> EventScreen(),
                              )
                            );
                          }),
                          _buildOption('assets/images/event-list.png', 'Sự kiện đã lưu',(){
                            //Hàm click vào sẽ chuyển hướng
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context)=> SaveEventScreen(),
                                )
                            );
                          }),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            if(latesEvent!=null)...[
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context)=>DetailEvent(event: latesEvent!,),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        latesEvent!.title,
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        DateFormat('d/MM/yyyy, h:mm:a'). format(latesEvent!.createdAt),
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                            child: Image.network(
                              latesEvent!.image,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress){
                                if(loadingProgress== null) return child;
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (context, error, stackTrace){
                                return Icon(Icons.error_outline);
                              },
                            )
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
            else ...[
              Center(child: CircularProgressIndicator()),
            ],
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tin sự kiện', style: TextStyle(fontSize: 20,)),
                  TextButton(
                    onPressed: () {
                      // Chức năng xem tất cả sự kiện
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context)=> EventScreen(),
                        )
                      );
                    },
                    child: Text('Xem thêm', style: TextStyle(fontSize: 20, color: Colors.blue)),
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


Widget _buildOption(String  imagePath, String label, Function onTap) {
  return GestureDetector(
    onTap: () => onTap(), // Chuyển hướng khi nhấp vào
    child: Column(
      children: [
        Container(
          padding: EdgeInsets.all(10), //
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.shade300, width: 3),
            borderRadius: BorderRadius.circular(15), // Bo tròn góc viền
          ),
          child: Image.asset(imagePath, width: 40, height: 40),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 15, color: Colors.black),
        ),
      ],
    ),
  );
}


