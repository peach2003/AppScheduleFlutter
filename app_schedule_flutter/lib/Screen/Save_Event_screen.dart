import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Service/FirebaseService.dart';
import '../Model/SaveEvent.dart';
import '../Model/Event.dart';
import 'Detail_Event_screen.dart';
import 'package:transparent_image/transparent_image.dart';

class SaveEventScreen extends StatefulWidget {
  final bool isInDashboard;
  const SaveEventScreen({Key? key, this.isInDashboard = false}) : super(key: key);

  @override
  State<SaveEventScreen> createState() => _SaveEventScreenState();
}

class _SaveEventScreenState extends State<SaveEventScreen> {
  FirebaseService firebaseService = FirebaseService();
  List<SaveEvent> saveEvents = [];
  Map<String, Event> eventDetails = {}; // Lưu trữ tất cả các sự kiện theo eventId

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
  }

  // Lấy tất cả sự kiện và lưu vào Map theo eventId
  Future<void> _fetchEventDetails() async {
    List<Event> events = await firebaseService.getAllEvents();
    Map<String, Event> eventMap = {
      for (var event in events) event.event_id!: event
    };

    setState(() {
      eventDetails = eventMap;
    });
  }

  /*// Định dạng ngày sự kiện
  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }*/
  // Hàm định dạng ngày giờ
  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy  hh:mm a').format(date); // Định dạng ngày giờ: dd/MM/yyyy hh:mm AM/PM
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sự kiện đã đăng ký',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,)
          ,),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Thêm đường kẻ giữa AppBar và body
          const Divider(
            color: Colors.grey,
            thickness: 1,
          ),
          Expanded(
            child: StreamBuilder<List<SaveEvent>>(
              stream: firebaseService.listenToSavedEvents(), // Lắng nghe sự kiện theo thời gian thực
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                List<SaveEvent> saveEvents = snapshot.data!;

                if (saveEvents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Sử dụng Image.asset() để hiển thị tệp GIF từ assets
                        Image.asset(
                          'assets/images/loading.gif',
                          width: 310,
                          height: 230,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 25),
                        const Text(
                          'Không có sự kiện nào đã đăng ký',
                          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: saveEvents.length,
                  itemBuilder: (context, index) {
                    SaveEvent saveEvent = saveEvents[index];
                    Event? eventDetail = eventDetails[saveEvent.eventId];

                    if (eventDetail == null) {
                      return ListTile(
                        title: const Text('Đang tải...'),
                        subtitle: const Text('Đang lấy thông tin sự kiện.'),
                      );
                    }

                    return GestureDetector(
                      onTap: () {
                        // Điều hướng đến màn hình chi tiết sự kiện
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailEvent(event: eventDetail),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: SizedBox(
                                width: 90,
                                height: 70,
                                child: Image.network(
                                  eventDetail.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.error),
                                ),
                              ),
                            ),
                            title: Text(
                              eventDetail.title,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                                  ' ${formatDate(eventDetail.createdAt)}',
                                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                                /*Text(
                                  'Trạng thái: ${saveEvent.status ? 'Đã đăng ký' : 'Chưa đăng ký'}',
                                  style: const TextStyle(fontSize: 14, color: Colors.green),
                                ),*/
                            ),
                        ],
                      ),
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