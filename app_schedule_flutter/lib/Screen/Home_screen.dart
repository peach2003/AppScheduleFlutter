import 'package:flutter/material.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                        color: Colors.purple.shade100,
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
                                "image/1.png",
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.notifications_none, size: 30,),
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
                            IconButton(
                              icon: Icon(Icons.wb_sunny_outlined),
                              onPressed: (){
                                //Chức năng xem thông báo
                              },
                            ),
                            SizedBox(width: 8,),
                            Text('TUES 11 JUL', style: TextStyle(fontSize: 16),),
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
                          _buildOption(Icons.calendar_today_outlined, 'Lịch học'),
                          _buildOption(Icons.campaign_outlined, 'Sự kiện'),
                          _buildOption(Icons.event_available_outlined, 'Sự kiện đã lưu'),
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
      Icon(icon, size: 45,),
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
