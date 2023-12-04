import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/main.dart';
import 'package:project/screen/profilePage.dart'; 


late FirebaseApp fbApp;

class DiaryTotal extends StatefulWidget {
  final String sNum;
  final MyList myList;
 

  const DiaryTotal({
    super.key,
    required this.sNum,
    required this.myList,
  });

  @override
  State<DiaryTotal> createState() => _DiaryTotalState();
}

class _DiaryTotalState extends State<DiaryTotal> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  late String imgUrl;

  @override
  void initState() {
    super.initState();
    imgUrl = '';
    _getImageUrl();
  }

  Future<void> _getImageUrl() async {
    late CollectionReference titles;
    titles = FirebaseFirestore.instance.collection('titles');

    var documentSnapshot = await titles.doc(sNum).get();
    int count = documentSnapshot.get('count');

    try {
      Reference _ref = _storage
          .ref()
          .child('/images')
          .child('${sNum}')
          .child("/title${widget.myList.order}");

      imgUrl = await _ref.getDownloadURL();

      setState(() {});
    } catch (e) {
      print('Error getting image URL: $e');
    }
  }

  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawerEnableOpenDragGesture: true,
        key: scaffoldKey,
        appBar: AppBar(
            title: Text(''),
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer()),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                },
                child: Text(
                  '나가기',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                )),
              ]),
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
                          builder: (context) => MyHomePage(title: '내가 그린 일기',),
                        ),
                      );
                    },                  
                    child:Text('달력 보기',
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.w900),
                    )
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
          padding: const EdgeInsets.all(15.0),
          child: CustomScrollView(slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.white,
              floating: true,
              expandedHeight: 300.0,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  imgUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SliverToBoxAdapter(
               child: Column(
                children: [
                  Text('제목: ${widget.myList.title}',
                  style: TextStyle(
                    fontSize: 50.0,
                    fontFamily: 'Nanoom',
                    fontWeight: FontWeight.w100,
                  )),
                  Divider(
                    color:Colors.black,
                    thickness: 2.0,
                  )
                ]
               )
            ),
            SliverToBoxAdapter(
              child: Text(widget.myList.content,
                  style: TextStyle(
                    fontSize: 40.0,
                    fontFamily: 'Nanoom',
                    fontWeight: FontWeight.w100,
                  )),
            )
          ]),
        ));
  }
}
