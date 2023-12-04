import 'package:flutter/material.dart';
import 'package:project/event.dart';
import 'package:project/feature/drawing_room/presentation/diary_total.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/feature/drawing_room/presentation/drawing_room_screen.dart';
import 'package:project/screen/profilePage.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
late FirebaseApp fbApp;
final today = DateUtils.dateOnly(DateTime.now());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  fbApp = await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '내가 그린 일기',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ko', ''),
      ],
      debugShowCheckedModeBanner: false,
      home: FlutterSplashScreen.gif(
       gifPath:'assets/images/해.gif',
        gifWidth: 1080,
          gifHeight: 2220,
          defaultNextScreen: const MyHomePage(title: '내가 그린 일기'),
          backgroundColor: Colors.white,
          duration: const Duration(milliseconds: 5000),
          onInit: () async {
            debugPrint("onInit 1");
            await Future.delayed(const Duration(milliseconds: 0));
            debugPrint("onInit 2");
          },
          onEnd: () async {
            debugPrint("onEnd 1");
            debugPrint("onEnd 2");
          },

        )
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

late String sNum;
late String dContent = '';

class _MyHomePageState extends State<MyHomePage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
//store the events created
  Map<DateTime, List<Event>> events = {};
  TextEditingController _eventController = TextEditingController();
  late final ValueNotifier<List<Event>> _selectedEvents;
  late CollectionReference titles;
  late List<MyList> myLists = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    titles = FirebaseFirestore.instance.collection('titles');
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      myLists.clear();
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedEvents.value = _getEventsForDay(selectedDay);
      doSelectOne();
      setState(() {});
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    //return all event from the selected day
    return events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      drawerEnableOpenDragGesture: true,
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('내가 그린 일기'),
        leading: Builder(
          builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer()),
        ),
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
                            builder: (context) => MyHomePage(title: '내가 그린 일기',),
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
            //    const ListTile(
            //   leading: Icon(Icons.calendar_month),
            //   title: Text('달력'),
            // ),
            // ListTile(
            //   leading: const Icon(Icons.close),
            //   title: const Text('메뉴 닫기'),
            //   onTap: (() {
            //     //Closing programmatically
            //     scaffoldKey.currentState!.openEndDrawer();
            //   }),
            // )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  scrollable: true,
                  title: const Text("그림 일기 제목"),
                  content: Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: _eventController,
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () async {
                        await doSelectedOne11();

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DrawingRoomScreen(sNum),
                          ),
                        );
                      },
                      child: Text("그림 그리러 가기"),
                    )
                  ],
                );
              });
        },
        child: const Icon(Icons.add),
      ),
      resizeToAvoidBottomInset: true, 
      body: Column(
        children: [
          Expanded(child: ListView( 
          children:[
          TableCalendar(
            firstDay: DateTime.utc(1990, 1, 01),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.monday,
            eventLoader: _getEventsForDay,
            onDaySelected: _onDaySelected,
            
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Color.fromARGB(126, 76, 175, 79),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
            ),
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          Container(
            width: double.infinity, // like Match_parent in Android
            height: 250,
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.all(8),
                itemCount: myLists.length,
                itemBuilder: (
                  BuildContext context,
                  int indexNote,
                ) {
                  return MyListTile(
                      myLists[indexNote], indexNote, sNum, dContent);
                }),
                ),
              ],
            ),
          )
        ],
      )
    );
  }

void goToProfilePage(){
  Navigator.pop(context);

  Navigator.push(context,
  MaterialPageRoute(builder: (context) => const ProfileScreen(),)
  );  
}


  Future<void> doInsert() async {
    sNum = _selectedDay.toString().substring(0, 10);
   var documentSnapshot = await titles.doc(sNum).get();
    titles.doc(sNum).set({
      'title1': _eventController.text,
      'count': 1,
    });
  }

  

  Future<void> doSelectedOne11() async {
    sNum = _selectedDay.toString().substring(0, 10);
    var documentSnapshot = await titles.doc(sNum).get();
    if (documentSnapshot.data() != null) {
      doUpdate(documentSnapshot);
    } else {
      doInsert();
    }
  }

  void doSelectOne() async {
    sNum = _selectedDay.toString().substring(0, 10);
    myLists.clear();

    var documentSnapshot = await titles.doc(sNum).get();

    if (documentSnapshot.data() != null) {
      int count = documentSnapshot.get('count');

      for (int i = 1; i <= count; i++) {
        final titleKey = 'title$i';
        final contentKey = 'content$i';
        final data = documentSnapshot.data() as Map<String, dynamic>?;

        if (data != null &&
            data.containsKey(titleKey) &&
            data.containsKey(contentKey)) {
          // 필드가 삭제되지 않았을 때만 추가
          if (data[titleKey] != '삭제됨' && data[contentKey] != '삭제됨') {
            myLists.add(MyList(i, data[titleKey], data[contentKey]));
            dContent = data[contentKey];
            print(dContent);
          }
        }
      }
      setState(() {});
    }
  }

  Future<void> doUpdate(var A) async {
    sNum = _selectedDay.toString().substring(0, 10);
    var documentSnapshot = A;
    if (A != null) {
      int count = documentSnapshot.get('count');
      count++;
      titles.doc(sNum).update({
        'count': count,
        'title$count': _eventController.text,
      });
    } else {}
  }

  Future<void> doDelete() async {
    sNum = _selectedDay.toString();
    var documentSnapshot = await titles.doc(sNum).get();
    if (documentSnapshot.data() != null) {
      var documentReference = await titles.doc(sNum);
      documentReference.delete();
    }
  }

  static void deleteMyList(String sNum, int order) async {
    var titles = FirebaseFirestore.instance.collection('titles');
    var field = 'title$order';

    await titles.doc(sNum).get().then((documentSnapshot) async {
      if (documentSnapshot.exists) {
        String title = documentSnapshot.get(field);
        String content = documentSnapshot.get('content$order');

        await titles.doc(sNum).update({
          field: FieldValue.delete(),
          'content$order': FieldValue.delete(),
        });

        print('문서가 삭제되었습니다: $title, $content');
      }
    });
  }

    Future<void> doModify() async {
    sNum = _selectedDay.toString().substring(0, 10);
    var documentSnapshot = await titles.doc(sNum).get();

    if (documentSnapshot != null) {
      int count = documentSnapshot.get('count');
      titles.doc(sNum).update({
        
        'title$count': _eventController.text,
      });
    } else {}
  }
}

class MyList {
  int order;
  String title;
  String content;

  MyList(this.order, this.title, this.content);
}

class MyListTile extends StatelessWidget {
  final MyList _myList;
  final int indexList;
  late String sNum;
  final String dContent;

  MyListTile(this._myList, this.indexList, this.sNum, this.dContent);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber[100],
      elevation:4,
      shape: RoundedRectangleBorder(
        
        // side: BorderSide(color: Colors.black, width: 1),
        // borderRadius: BorderRadius.circular(0),
      ),
      child: InkWell(
        splashColor: Colors.green[200],
        onTap: () async {                         
          await _showProgressDialog(context, 'loading..');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DiaryTotal(
                sNum: '',
                myList: _myList,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity, // like Match_parent in Android
              height: 50,
              alignment: Alignment.center,
              color: const Color.fromARGB(255, 255, 245, 159),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SingleChildScrollView( 
                      scrollDirection: Axis.horizontal,
                      child:Text(
                        "    ${_myList.title}",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_rounded,
                      color: Colors.grey,
                      size: 35.0,
                    ),
                    onPressed: () async {
                      // Call the delete method of _MyHomePageState
                      _MyHomePageState.deleteMyList(sNum, _myList.order);
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

 Future _showProgressDialog(BuildContext context, String message) async {
    await showDialog(
      context: context,
       builder: (BuildContext context) {

        Future.delayed(const Duration(seconds: 2),() {
          Navigator.pop(context);
        });

        return Theme(
          data: ThemeData(dialogBackgroundColor: Colors.white),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)
            ),
            content: SizedBox(
              height: 200,
              child: Center(
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height : 50.0,
                      width: 50.0,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color.fromARGB(255, 0, 255, 149)),
                        strokeWidth: 5.0,
                      ),
                    ),
                    const SizedBox(height: 20.0,),
                    Text(
                      message,
                      style: const TextStyle(fontSize:24, height: 1.5),
                    )
                  ],
                )
              ),
            ),
          ),
        );
      },
    );
  }


