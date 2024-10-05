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
                padding: EdgeInsets.all(25),
                color: Colors.purple.shade100,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image(
                          width: 10,
                          height: 10,
                          fit: BoxFit.cover,
                          image: AssetImage('image/1.png'),
                        ),
                        Container(
                          child: Row(
                            children: [
                              IconButton(onPressed:(){}, icon: Icon(Icons.notifications_none)),
                              SizedBox(width: 10,),
                              CircleAvatar(
                                backgroundImage: NetworkImage('https://th.bing.com/th/id/R.ea888ce8ab1a32ebdf8aac4a3ba23263?rik=ysYySzGU8J%2bzzQ&riu=http%3a%2f%2fwww.healthyfoodhouse.com%2fwp-content%2fuploads%2f2012%2f10%2fhealthy-drinks.jpg&ehk=WWaIyOgZ3UgnS%2fLWh%2bRowgeG3SHc18ccBN5bqmP9ruk%3d&risl=&pid=ImgRaw&r=0'),
                                radius: 20,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Icon(Icons.wb_sunny_outlined),
                        SizedBox(width: 8,),
                        Text('TUES 11 JUL', style: TextStyle(fontSize: 16),),
                      ],
                    )
                  ],
                )
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildOption(Icons.calendar_today, 'Lịch học'),
                  _buildOption(Icons.campaign, 'Sự kiện'),
                  _buildOption(Icons.event_available, 'Sự kiện đã lưu'),
                ],
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nội dung sự kiện mới nhất',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '5/10/2024 8:00 SA',
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                )
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Image(
                image: NetworkImage('https://th.bing.com/th/id/R.ea888ce8ab1a32ebdf8aac4a3ba23263?rik=ysYySzGU8J%2bzzQ&riu=http%3a%2f%2fwww.healthyfoodhouse.com%2fwp-content%2fuploads%2f2012%2f10%2fhealthy-drinks.jpg&ehk=WWaIyOgZ3UgnS%2fLWh%2bRowgeG3SHc18ccBN5bqmP9ruk%3d&risl=&pid=ImgRaw&r=0'),
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tin HUTECH', style: TextStyle(fontSize: 16),),
                  TextButton(onPressed: (){}, child: Text('Xem thêm', style:TextStyle(fontSize: 16, color: Colors.blue),)),
                ],
              ),
            ),
            _buildEventList(),
          ],
        ),
      ),
    );
  }
  Widget _buildOption(IconData icon, String label){
    return Column(
      children: [
        Icon(icon, size: 45,),
        SizedBox(height: 8,),
        Text(label),
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
                  Image.network(
                    "https://www.brookfieldengineering.uk/-/media/ametekbrookfield/applications-graphs-and-images/texture--application-notes/food-and--beverages/food-and-beverages-application-notes-image.jpg?la=en-gb&revision=3ecb42b8-2019-45e1-bd32-696d3086c71b&hash=C8D4B0E6F004137E78EE1F7B3EC641B6",
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
}
