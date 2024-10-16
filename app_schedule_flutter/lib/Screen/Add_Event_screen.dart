import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final  DatabaseReference _eventRef= FirebaseDatabase.instance.ref().child('events');
  final TextEditingController _tittleControler= TextEditingController();
  final TextEditingController _contentController=TextEditingController();
  final TextEditingController _imageController= TextEditingController();

  // ham them su kien vao Firebase
  void _addEvent(){
    final String tittle= _tittleControler.text;
    final String content=_contentController.text;
    final String image=_imageController.text;
    final String createAt=DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    if(tittle.isNotEmpty && content.isNotEmpty && image.isNotEmpty){
      _eventRef.push().set({
        'tittle':tittle,
        'content':content,
        'image':image,
        'user_id':1, // user tam thoi
        'create_at': createAt,
      }).then((_){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sự kiện đã được thêm thành công')),
        );
        Navigator.pop(context);// quay lại trang trước sau khi thêm sự kiện thành công
      });
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin'))
      );
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _tittleControler,
                decoration:InputDecoration(
                    labelText: 'Tiêu đề sự kiện'
                ),
              ),
              SizedBox(
                height: 16,
              ),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(
                    labelText: 'Nội dung sự kiện'
                ),
              ),
              SizedBox(
                height: 16,
              ),
              TextField(
                controller: _imageController,
                decoration: InputDecoration(
                    labelText: 'URL hình ảnh sự kiện'
                ),
              ),
              SizedBox(
                height: 16,
              ),
              ElevatedButton(
                child: Text('Thêm sự kiện'),
                onPressed: _addEvent,
              )
            ],
          ),
        )

    );
  }
}