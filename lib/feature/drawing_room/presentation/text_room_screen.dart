import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/main.dart';

late FirebaseApp fbApp;

class TextRoom extends StatefulWidget {
  final String sNum;
  const TextRoom({
    super.key,
    required this.sNum,
  });
  
  @override
  State<TextRoom> createState() => _TextRoomState();
}



class _TextRoomState extends State<TextRoom> {

  var globalKey = GlobalKey();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _eventController = TextEditingController();
  late CollectionReference titles;

@override
void initState(){
 super.initState();
 setState(() {
  

 });
}


  @override
   Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(     
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,       
        title: Text('내가 그린 일기'),
        actions: [
          TextButton(onPressed: ()async {
                     Navigator.pop(context);
                  },
           child: Text('취소', style: TextStyle(fontSize: 20, color: Colors.black),)),
         
           TextButton(
            child: Text('저장', style: TextStyle(fontSize: 20, color: Colors.black),),
           onPressed: (){          
            doUpdate();            
             Navigator.of(context).popUntil((route) => route.isFirst);
            }
           )     
        ],
        ), 
     
      body: Center(
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '일기장',
              style: TextStyle(fontSize: 30.0),
            ),
            Expanded(
              child: TextField(
                 controller: _eventController,
                style: TextStyle(
                  fontSize: 30
                ),
                maxLength: 150,
                maxLines: 30,
                decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.greenAccent, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 1.0),
                  ),
                  labelText: '내용 입력',
                  //counterText: "", //maxLength 를 감춘다

                  counterStyle: TextStyle(
                    fontSize: 20.0,
                    color: Colors.red,
                  ),
                ),
                onChanged: (text) {
                  print(text);
                },
                onSubmitted: (text) {
                  print('Submitted : $text');
                }
              ),
            ),
            ElevatedButton(
               child: const Text('키보드 내리기', 
                                  style: TextStyle(fontSize: 24,
                                            color: Colors.white)),
                onPressed: () => _onClick(),
            ),
          ],
        ),
      ),
     );
  }
 
 void _onClick(){
  FocusScope.of(context).unfocus();
 } 



 Future<void> doUpdate() async{
    titles = FirebaseFirestore.instance.collection('titles'); 
    var documentSnapshot = await titles.doc(sNum).get();    
    int count = documentSnapshot.get('count');
      print(documentSnapshot);
      print(count);
      print("여기");
      print(sNum);
      
   
      titles.doc(sNum).update({
        'count' : count,
        'content$count': _eventController.text
              });
  
  }
}
