import 'dart:io';

import 'package:app_schedule_flutter/Model/Event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

class DetailEvent extends StatefulWidget {
  final Event event;

  //Constructor nhận một đối tượng Event
  DetailEvent({required this.event});

  @override
  State<DetailEvent> createState() => _DetailEventState();
}

class _DetailEventState extends State<DetailEvent> {
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
      🎉 ${widget.event.title.toUpperCase()} 🎉\n\nNgày sự kiện tổ chức: ${formatDate(widget.event.createdAt)}\nXem thêm sự kiện tại app!
    ''';

      // Sử dụng shareXFiles để chia sẻ hình ảnh và nội dung
      XFile imageFile = XFile(file.path);
      Share.shareXFiles([imageFile], text: shareContent);
    } catch (e) {
      print("Lỗi khi chia sẻ sự kiện: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                  color: Colors.grey
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
              )

            ],
          ),
        ),
      ),
    );
  }
}