import 'package:flutter/material.dart';
class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top:20),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: (){
                          //Chức năng quay lại trang home

                        },
                        icon: Icon(Icons.arrow_back_ios_new_outlined, size: 25,),
                      ),
                      SizedBox(
                        width: 80,
                      ),
                      Text(
                        'Tin HUTECH',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              _buildEventList(),

            ],
          ),
        ),
      ),
    );
  }
}
Widget _buildEventList(){
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: List.generate(40, (index) {
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
