import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/main.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
            title: Text('내가 그린 일기'),
          //    actions: [
          //        TextButton(
          //   child: Text('취소', style: TextStyle(fontSize: 20, color: Colors.black),),
          //  onPressed: (){                   
          //    Navigator.of(context).popUntil((route) => route.isFirst);
          //   }
          //  )  
          //   ]
          ),   
           drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(              
              decoration: BoxDecoration(
                color: Colors.green,
              ),
               child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 65.0, // 동그라미 크기 조절
                    backgroundImage: AssetImage('assets/images/하리보.jpg'), // 이미지 파일 경로 설정
                  ),         
                ],
              ),
            ),
             ListTile(              
              leading: const Icon(Icons.account_circle),              
              title: Row(
                children: [             
                const SizedBox(width:8),
                TextButton(
                  onPressed: () { 
                    Navigator.of(context).push( MaterialPageRoute(builder: (_) => const ProfileScreen())); 
                    }, 
                  child:const Text('프로필',
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.w900),)
                )
                ]
              ) 
            ),
               ListTile(              
              leading: Icon(Icons.calendar_month),              
              title: Row(
                children: [             
                SizedBox(width:8),
                TextButton(
                  onPressed: () {
                         Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MyHomePage(title: '',),
                          ),
                        );
                  },
                  
                  child:Text('달력 보기',
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.w900),)
                )
                ]
              ) 
            ),
             ListTile(              
              leading: Icon(Icons.close),              
              title: Row(
                children: [             
                SizedBox(width:8),
                TextButton(
                 onPressed: () async {
                    Navigator.pop(context);
                  },
                  child:Text('메뉴 닫기',
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.w900),)
                )
                ]
              ) 
            ),
    
          ],
        ),
      ),         
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 70,
              backgroundImage: AssetImage('assets/images/a.jpg'),
            ),
            const SizedBox(height: 20),
            itemProfile('이름', 'Cookie', CupertinoIcons.person),
            const SizedBox(height: 10),
            itemProfile('전화번호', '010-6385-4698', CupertinoIcons.phone),
            const SizedBox(height: 10),
            itemProfile('주소', 'abc address, xyz city', CupertinoIcons.location),
            const SizedBox(height: 10),
            itemProfile('Email', 'sungsy91@gmail.com', CupertinoIcons.mail),
            const SizedBox(height: 20,),
           
          ],
        ),
      ),
    );
  }

  itemProfile(String title, String subtitle, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 5),
                color: Color.fromARGB(255, 189, 189, 189).withOpacity(.2),
                spreadRadius: 2,
                blurRadius: 10
            )
          ]
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(iconData),
        trailing: Icon(Icons.arrow_forward, color: Colors.grey.shade400),
        tileColor: Colors.white,
      ),
    );
  }
}

