import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _weather="Loading...";
  String _currentDate=DateFormat('EEE d MMM'). format(DateTime.now());
  Position? _currentPosition;
  IconData _weatherIcon= Icons.wb_sunny_outlined;//icon mac dinh
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentLocation();  // Gọi hàm lấy vị trí ngay khi khởi tạo widget
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
  Future<void> _fetchWeatherData(double lat, double lon) async {
    final apiKey = 'a10c2b29a19ed5f2cc6691a6c6cf1966'; // Thay bằng API key của bạn
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

    // In ra URL để kiểm tra
    print("URL API: $url");

    try {
      final response = await http.get(Uri.parse(url));
      print("Response status: ${response.statusCode}"); // In ra mã trạng thái phản hồi
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Weather data: $data"); // In ra dữ liệu thời tiết
        final weatherDescription = data['weather'][0]['description'];
        final weatherMain = data['weather'][0]['main']; // Loại thời tiết chính
        setState(() {
          _weather = weatherDescription.toUpperCase(); // Cập nhật mô tả thời tiết
          _weatherIcon = _getWeatherIcon(weatherMain.toLowerCase()); // Cập nhật icon
        });
      } else {
        setState(() {
          _weather = 'Failed to load weather: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _weather = 'Error occurred: $e';
      });
    }
  }

  // lay vi tri hien tai
  Future<void> _getCurrentLocation() async{
    bool serviceEnable;
    LocationPermission permission;

    //kiem tra dich vu dinh vi co bat hay khong?
    serviceEnable=await Geolocator.isLocationServiceEnabled();
    if(!serviceEnable){
      setState(() {
        _weather="Location service are disable.";
      });
      return;
    }
    //Kiem tra quyen truy cap vi tri
    permission = await Geolocator.checkPermission();
    if(permission==LocationPermission.denied){
      permission= await Geolocator.requestPermission();
      if(permission==LocationPermission.denied){
        setState(() {
          _weather= "Location permissions are denied.";
        });
        return;
      }
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _weather = "Location permissions are denied.";
        });
        return;
      }

      //Neu co quyen truy cap, lay vi tri hien tai
      _currentPosition=await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      //goi ham de lay thong tin thoi tiet sau khi co vi tri
      _fetchWeatherData(_currentPosition!.latitude, _currentPosition!.longitude);
    }
    // ham lau thong tin thoi tiet tu API dua tren toa do

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
                  //Background nền phía trên
                  Container(
                    padding:EdgeInsets.all(16),
                    height: 200,
                    decoration:BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(30),
                          bottomLeft: Radius.circular(30),
                        )
                    ),

                    child: Column(
                      children: [
                        //Căn chỉnh logo, avatar, thông báo
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
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.notifications_none, size: 30),
                                      onPressed: (){
                                        //chuc nang thong bao day
                                      },
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    CircleAvatar(
                                      backgroundImage: NetworkImage('https://th.bing.com/th/id/R.ea888ce8ab1a32ebdf8aac4a3ba23263?rik=ysYySzGU8J%2bzzQ&riu=http%3a%2f%2fwww.healthyfoodhouse.com%2fwp-content%2fuploads%2f2012%2f10%2fhealthy-drinks.jpg&ehk=WWaIyOgZ3UgnS%2fLWh%2bRowgeG3SHc18ccBN5bqmP9ruk%3d&risl=&pid=ImgRaw&r=0'),
                                      radius: 20,
                                    )
                                  ],
                                ),
                              ),

                            ],
                          ),
                        ),
                        //Căn chỉnh thời tiết ngày tháng
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(_weatherIcon, size: 30,),
                            SizedBox(width: 5,),
                            Text(
                              '('+
                                  //hien thi ngay hien tai
                                  _weather.toUpperCase() +')',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(width: 10,),
                            Text(
                              //hien thi ngay hien tai
                              _currentDate.toUpperCase(),
                              style: TextStyle(fontSize: 16),
                            ),

                          ],
                        )
                      ],
                    ),
                  ),
                  //Căn chỉnh contaner chức năng
                  Positioned(
                    top: 160,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration:BoxDecoration(
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
                  children:[
                    Text(
                      'HUTECH-ers sẵn sàng bùng nổ cùng Đêm hội văn hóa Chào năm học mới 2024-2025 và Phát động Miss HUTECH 2025 vào 11/10 tới',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '5/10/2024 8:00 SA',
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                )
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Image(
                  image: NetworkImage('https://th.bing.com/th/id/R.ea888ce8ab1a32ebdf8aac4a3ba23263?rik=ysYySzGU8J%2bzzQ&riu=http%3a%2f%2fwww.healthyfoodhouse.com%2fwp-content%2fuploads%2f2012%2f10%2fhealthy-drinks.jpg&ehk=WWaIyOgZ3UgnS%2fLWh%2bRowgeG3SHc18ccBN5bqmP9ruk%3d&risl=&pid=ImgRaw&r=0'),
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),    Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tin HUTECH', style: TextStyle(fontSize: 16),),
                  TextButton(
                      onPressed: (){
                        //Chức năng xem tất các sự kiện
                      },
                      child: Text('Xem thêm', style:TextStyle(fontSize: 16, color: Colors.blue),)
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
Widget _buildOption(IconData icon, String label){
  return  Column(
    children: [
      Icon(icon, size: 35,),
      SizedBox(height: 8,),
      Text(label, style: TextStyle(fontSize: 15),),
    ],
  );
}

Widget _buildEventList(){
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: List.generate(3, (index) {
        return Column(
          children: [
            Row(
              children: [
                Image(
                  image: NetworkImage('https://th.bing.com/th/id/R.ea888ce8ab1a32ebdf8aac4a3ba23263?rik=ysYySzGU8J%2bzzQ&riu=http%3a%2f%2fwww.healthyfoodhouse.com%2fwp-content%2fuploads%2f2012%2f10%2fhealthy-drinks.jpg&ehk=WWaIyOgZ3UgnS%2fLWh%2bRowgeG3SHc18ccBN5bqmP9ruk%3d&risl=&pid=ImgRaw&r=0'),
                  width: 80,
                  height: 80,

                  loadingBuilder: (context, child, progress){
                    return progress==null
                        ?child
                        :Center(
                        child: CircularProgressIndicator()
                    );
                  },
                  errorBuilder: (context, error, stackTrace){
                    return Icon(Icons.error);
                  },
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nội dung sự kiện', style: TextStyle(fontSize: 16)),
                      SizedBox(
                        height: 8,
                      ),
                      Text('5/10/2024 8:00 SA', style: TextStyle(color: Colors.grey),)
                    ],
                  ),
                )
              ],
            ),
            Divider(),
          ],
        );
      }),
    ),
  );
}