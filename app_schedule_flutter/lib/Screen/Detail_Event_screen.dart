import 'dart:io';
import 'package:app_schedule_flutter/Model/Event.dart';
import 'package:app_schedule_flutter/Model/SaveEvent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Service/AuthService.dart';
import '../Service/FirebaseService.dart';

class DetailEvent extends StatefulWidget {
  final Event event;



  //Constructor nhận một đối tượng Event
  DetailEvent({required this.event});

  @override
  State<DetailEvent> createState() => _DetailEventState();
}

class _DetailEventState extends State<DetailEvent> {
  final TextEditingController _noteController= TextEditingController();
  FirebaseService _firebaseService = FirebaseService();
  AuthService authService = AuthService();
  bool isRegistered = false;  // Kiểm tra xem sự kiện đã được đăng ký chưa

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkIfRegistered();
  }
  // Định dạng ngày giờ
  String formatDate(DateTime date){
    return DateFormat('d/MM/yyyy, h:mm a').format(date);
  }
  // Hàm để xử lý content và chèn ngắt dòng sau 2-3 câu, đồng thời thêm thụt đầu dòng
  String formatContentWithLineBreaksAndIndent(String content) {
    // Tách nội dung thành các câu dựa trên dấu câu (., ?, !)
    List<String> sentences = content.split(RegExp(r'(?<=[.?!])\s+')); // Sử dụng regex để tách câu
    String formattedContent = '';

    // Lặp qua danh sách các câu, và thêm dấu ngắt dòng cùng thụt đầu dòng sau mỗi 2-3 câu
    int sentenceCounter = 0;
    for (int i = 0; i < sentences.length; i++) {
      formattedContent += sentences[i].trim(); // Thêm câu vào văn bản

      // Tăng bộ đếm câu
      sentenceCounter++;

      // Sau mỗi 2 hoặc 3 câu, thêm ngắt dòng và thụt đầu dòng
      if (sentenceCounter >= 2 && sentenceCounter <= 3) {
        formattedContent += '\n\t\t'; // Thêm ngắt dòng và thụt đầu dòng (bằng tab '\t')
        sentenceCounter = 0; // Đặt lại bộ đếm
      } else {
        formattedContent += ' '; // Nếu chưa đủ câu, chỉ thêm khoảng trắng
      }
    }

    return formattedContent.trim();
  }
  // Hàm chia sẻ sự kiện
  Future<void> _shareEvent() async {
    try {
      // Tải hình ảnh từ URL
      final imageUrl = widget.event.image;
      final response = await http.get(Uri.parse(imageUrl));
      final documentDirectory = await getApplicationDocumentsDirectory();
      final file = File('${documentDirectory.path}/event_image.png');
      file.writeAsBytesSync(response.bodyBytes);

      // Tạo nội dung chia sẻ
      final String shareContent = '''
      🎉 ${widget.event.title.toUpperCase()} 🎉\n\nNgày sự kiện tổ chức: ${formatDate(widget.event.createdAt)}\nXem thông tin chi tiết tại: ${widget.event.link}
    ''';

      // Sử dụng shareXFiles để chia sẻ hình ảnh và nội dung
      XFile imageFile = XFile(file.path);
      Share.shareXFiles([imageFile], text: shareContent);
    } catch (e) {
      print("Lỗi khi chia sẻ sự kiện: $e");
    }
  }
  // Hàm kiểm tra xem sự kiện đã được đăng ký hay chưa
  Future<void> _checkIfRegistered() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      return;
    }

    List<SaveEvent> savedEvents = await _firebaseService.getSavedEvents();
    bool alreadyRegistered = savedEvents.any((event) => event.userId == userId && event.eventId == widget.event.event_id);

    setState(() {
      isRegistered = alreadyRegistered;  // Cập nhật trạng thái đã đăng ký
    });
  }

  // Hàm đăng ký sự kiện
  Future<void> _registerForEvent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng đăng nhập để đăng ký sự kiện')),
      );
      return;
    }

    SaveEvent saveEvent = SaveEvent(
      userId: userId,
      eventId: widget.event.event_id!,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      status: true,
    );

    try {
      await _firebaseService.saveEvent(saveEvent);
      //Sử dụng SnackBar để hiển thị 
      /*ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng ký sự kiện thành công!')),
      );*/
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đăng ký sự kiện thành công!',
            style: TextStyle(color: Colors.white),  // Thay đổi màu chữ nếu cần
          ),
          backgroundColor: Colors.green,  // Thay đổi màu nền của Snackbar
          duration: Duration(seconds: 2),  // Thời gian hiển thị là 3 giây
          //behavior: SnackBarBehavior.floating,  // Cho phép Snackbar trôi nổi
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),  // Bo tròn các góc của Snackbar
          ),
          /*action: SnackBarAction(
            label: 'Đóng',
            textColor: Colors.white,
            onPressed: () {
              // Hành động khi nhấn nút 'Đóng'
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),*/

        ),
      );

      setState(() {
        isRegistered = true;  // Cập nhật trạng thái sau khi đăng ký
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi đăng ký sự kiện: $e')),
      );
    }
  }

  // Hàm hủy đăng ký sự kiện
  Future<void> _cancelRegistration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      return;
    }

    List<SaveEvent> savedEvents = await _firebaseService.getSavedEvents();
    SaveEvent? saveEvent = savedEvents.firstWhere(
          (event) => event.userId == userId && event.eventId == widget.event.event_id,
      orElse: () => SaveEvent(  // Thay vì trả về null, cung cấp một đối tượng SaveEvent mặc định
        saveEventId: '',
        userId: '',
        eventId: '',
        status: false,
      ),
    );

    if (saveEvent.saveEventId != '') {  // Kiểm tra nếu saveEventId không rỗng
      try {
        await _firebaseService.deleteSavedEvent(saveEvent.saveEventId!);  // Xóa sự kiện đã đăng ký
        Navigator.pop(context); // Quay lại màn hình trước đó
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hủy sự kiện đăng ký thành công!',
              style: TextStyle(color: Colors.white),  // Thay đổi màu chữ nếu cần
            ),
            backgroundColor: Colors.red.shade400,  // Thay đổi màu nền của Snackbar
            duration: Duration(seconds: 2),  // Thời gian hiển thị là 3 giây
            //behavior: SnackBarBehavior.floating,  // Cho phép Snackbar trôi nổi
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),  // Bo tròn các góc của Snackbar
            ),
            /*action: SnackBarAction(
            label: 'Đóng',
            textColor: Colors.white,
            onPressed: () {
              // Hành động khi nhấn nút 'Đóng'
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),*/

          ),
        );

        setState(() {
          isRegistered = false;  // Cập nhật trạng thái sau khi hủy đăng ký
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi hủy đăng ký sự kiện: $e')),
        );
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new), // Thay thế icon mũi tên quay lại bằng icon khác
          onPressed: () {
            Navigator.pop(context); // Điều hướng quay lại màn hình trước
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.share_outlined, size: 30,),
              onPressed: _shareEvent,
            )
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.event.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Ngày tạo: ${formatDate(widget.event.createdAt)}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade700
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Image.network(
                widget.event.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace)=> Icon(Icons.error),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                formatContentWithLineBreaksAndIndent(widget.event.content), // Sử dụng hàm xử lý nội dung
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.justify,  // Canh đều lề
                softWrap: true,  // Tự động xuống dòng
                overflow: TextOverflow.visible, // Hiển thị đầy đủ nội dung
              ),

              SizedBox(
                height: 20,
              ),
              // Nếu sự kiện chưa được đăng ký, hiển thị form ghi chú và nút đăng ký
              if (!isRegistered) ...[
                Text(
                  'Đặt câu hỏi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Divider(color: Colors.grey, thickness: 1, endIndent: 230),
                SizedBox(height: 10),
                TextField(
                  controller: _noteController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Nhập câu hỏi liên quan tới sự kiện...',
                    hintStyle: TextStyle(color: Colors.black54, fontSize: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.blue, width: 1),
                    ),
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _registerForEvent,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Text(
                      'Đăng ký sự kiện',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ] else ...[
                // Nếu sự kiện đã được đăng ký, hiển thị nút hủy đăng ký
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _cancelRegistration,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Text(
                      'Hủy đăng ký sự kiện',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
              SizedBox(
                height: 20,
              ),

            ],
          ),
        ),
      ),
    );
  }
}