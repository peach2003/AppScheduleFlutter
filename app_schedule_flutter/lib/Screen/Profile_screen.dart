import 'package:app_schedule_flutter/Screen/timetable_screen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thông tin cá nhân"),
        centerTitle: true,
        //report nếu muốn thêm
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(kDefaultPadding * 2),
                bottomLeft: Radius.circular(kDefaultPadding * 2),
              )
            ),
            child:  Row(
              children: [

                CircleAvatar(
                  maxRadius: 53.0,
                  minRadius: 53.0,
                  backgroundColor: Colors.blue,
                  backgroundImage: NetworkImage(
                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRuIZbU5T0ncHQY1T2fL0rgzMErgjZ7UK7ELw&s"),
                ),
                SizedBox(
                  width: 20,
                ), //thêm 1 size box để căn lề
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        'Lê Trường An',
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold),

                ),
                    Text(
                      'leantruong101203@gmail.com',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal),
                    )
                  ],
                )

              ],
            ),


      )
        ],
            ),
          );
        
  }
}
