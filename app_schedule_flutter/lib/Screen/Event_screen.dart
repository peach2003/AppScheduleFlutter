import 'package:app_schedule_flutter/Screen/Detail_Event_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Model/Event.dart';
import '../Service/FirebaseService.dart';

class EventScreen extends StatefulWidget {
  final bool isInDashboard;

  const EventScreen({Key? key, this.isInDashboard=false}) : super(key:key);

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  FirebaseService firebaseService = FirebaseService();
  List<Event> events = [];
  bool isLoading = true; // Biến để hiển thị trạng thái tải

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  // Lấy danh sách sự kiện từ Firebase và cập nhật trạng thái
  Future<void> _fetchEvents() async {
    List<Event> eventList = await firebaseService.getAllEvents();

    // Sắp xếp các sự kiện theo thời gian giảm dần (mới nhất trước)
    eventList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() {
      events = eventList;
      isLoading = false; // Khi dữ liệu đã tải xong, ẩn trạng thái tải
    });
  }

  // Hàm định dạng ngày giờ
  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy  hh:mm a').format(date); // Định dạng ngày giờ: dd/MM/yyyy hh:mm AM/PM
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.isInDashboard
        ? null
        : IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title:
            Text(
              'Tin sự kiện',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
        centerTitle: true,
        elevation: 0, // Bỏ độ nổi của AppBar để đường kẻ rõ ràng hơn
      ),
      body: Column(
        children: [
          // Thêm Divider để tạo đường ngăn cách giữa AppBar và body
          Divider(
            color: Colors.grey, // Màu của đường kẻ
            thickness: 1, // Độ dày của đường kẻ
            //indent: 20, // Thụt lề bên trái
            //endIndent: 70, // Thụt lề bên phải
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator()) // Hiển thị loading khi chưa có dữ liệu
                : events.isEmpty
                ? Center(child: Text('Không có sự kiện nào để hiển thị.')) // Khi không có dữ liệu
                : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                Event event = events[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  title: Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 19,
                      // fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(formatDate(event.createdAt), style: TextStyle(fontSize: 16),), // Định dạng ngày
                  leading: ClipRRect(
                    //borderRadius: BorderRadius.circular(8.0), // Bo góc cho hình ảnh
                    child: SizedBox(
                      width: 90, // Đặt kích thước chiều rộng
                      height: 70, // Đặt kích thước chiều cao
                      child: Image.network(
                        event.image,
                        fit: BoxFit.cover, // Đảm bảo hình ảnh vừa với kích thước
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.error), // Xử lý lỗi khi không tải được hình ảnh
                      ),
                    ),
                  ),
                  onTap: () {
                    // Chức năng chuyển hướng đến chi tiết sự kiện khi nhấn vào item sự kiện
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context)=> DetailEvent(event: event,), // Chuyển đến trang chi tiết sự kiện
                      )
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
