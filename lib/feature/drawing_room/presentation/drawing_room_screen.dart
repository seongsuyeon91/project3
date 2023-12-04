import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/core/theme/app_color.dart';
import 'package:project/feature/drawing_room/model/drawing_point.dart';
import 'package:project/feature/drawing_room/presentation/text_room_screen.dart';

late FirebaseApp fbApp;

class DrawingRoomScreen extends StatefulWidget {
  final String sNum;
  DrawingRoomScreen(this.sNum, {Key? key}) : super(key: key);

  @override
  State<DrawingRoomScreen> createState() => _DrawingRoomScreenState();
}

late String sNum;

class _DrawingRoomScreenState extends State<DrawingRoomScreen> {
  var avaiableColor = [
    Colors.white,
    Colors.red,
    Colors.pink,
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.brown,
    Colors.black,
  ];

  var historyDrawingPoints = <DrawingPoint>[];
  var drawingPoints = <DrawingPoint>[];

  var selectedColor = Colors.black;
  var selectedWidth = 2.0;
  var globalKey = GlobalKey();
  var scaffoldKey = GlobalKey<ScaffoldState>();

  DrawingPoint? currentDrawingPoint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('내가 그린 일기'),
        actions: [
          TextButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              child: Text(
                '취소',
                style: TextStyle(fontSize: 20, color: Colors.black),
              )),
          TextButton(
              child: Text(
                '저장',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              onPressed: () {
                _capture();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TextRoom(
                      sNum: '',
                    ),
                  ),
                );
              })
        ],
      ),     
      body: Stack(
        children: [
          /// Canvas
          RepaintBoundary(
            key: globalKey,
            child: Container(
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    currentDrawingPoint = DrawingPoint(
                      id: DateTime.now().microsecondsSinceEpoch,
                      offsets: [
                        details.localPosition,
                      ],
                      color: selectedColor,
                      width: selectedWidth,
                    );

                    if (currentDrawingPoint == null) return;
                    drawingPoints.add(currentDrawingPoint!);
                    historyDrawingPoints = List.of(drawingPoints);
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    if (currentDrawingPoint == null) return;

                    currentDrawingPoint = currentDrawingPoint?.copyWith(
                      offsets: currentDrawingPoint!.offsets
                        ..add(details.localPosition),
                    );
                    drawingPoints.last = currentDrawingPoint!;
                    historyDrawingPoints = List.of(drawingPoints);
                  });
                },
                onPanEnd: (_) {
                  currentDrawingPoint = null;
                },
                child: CustomPaint(
                  painter: DrawingPainter(
                    drawingPoints: drawingPoints,
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
                ),
              ),
            ),
          ),

          /// color pallet
          Positioned(
            top: MediaQuery.of(context).padding.bottom,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: avaiableColor.length,
                separatorBuilder: (_, __) {
                  return const SizedBox(
                    width: 8,
                  );
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = avaiableColor[index];
                      });
                    },
                    child: Container(
                      width: 30,
                      height: 32,
                      decoration: BoxDecoration(
                        color: avaiableColor[index],
                        shape: BoxShape.circle,
                        border: Border.all(),
                      ),
                      foregroundDecoration: BoxDecoration(
                        border: selectedColor == avaiableColor[index]
                            ? Border.all(color: AppColor.primaryColor, width: 3)
                            : null,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 50,
            // right: 0,
            //bottom:150,
            child: Container(
              width: 350,
              //quarterTurns: 3, // 270 degree
              child: Slider(
                value: selectedWidth,
                min: 1,
                max: 20,
                onChanged: (value) {
                  setState(() {
                    selectedWidth = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "Undo",
            onPressed: () {
              if (drawingPoints.isNotEmpty && historyDrawingPoints.isNotEmpty) {
                setState(() {
                  drawingPoints.removeLast();
                });
              }
            },
            child: const Icon(Icons.undo),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: "Redo",
            onPressed: () {
              setState(() {
                if (drawingPoints.length < historyDrawingPoints.length) {
                  // 6 length 7
                  final index = drawingPoints.length;
                  drawingPoints.add(historyDrawingPoints[index]);
                }
              });
            },
            child: const Icon(Icons.redo),
          ),
        ],
      ),
    );
  }

  void _capture() async {
    print("START CAPTURE");
    var renderObject = globalKey.currentContext?.findRenderObject();
    if (renderObject is RenderRepaintBoundary) {
      var boundary = renderObject;
      ui.Image image = await boundary.toImage();
      final directory = (await getApplicationDocumentsDirectory()).path;
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      File imgFile = new File('$directory/screenshot.png');
      imgFile.writeAsBytes(pngBytes);
      print("FINISH CAPTURE ${imgFile.path}");

      late CollectionReference titles;
      titles = FirebaseFirestore.instance.collection('titles');
      var documentSnapshot = await titles.doc(widget.sNum).get();
      sNum = widget.sNum;
      int count = documentSnapshot.get('count');

      Reference reference = FirebaseStorage.instance
          .ref()
          .child('/images')
          .child('/${widget.sNum}')
          .child("title$count");

      await reference.putFile(imgFile);
    }
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> drawingPoints;

  DrawingPainter({required this.drawingPoints});

  @override
  void paint(Canvas canvas, Size size) {
    for (var drawingPoint in drawingPoints) {
      final paint = Paint()
        ..color = drawingPoint.color
        ..isAntiAlias = true
        ..strokeWidth = drawingPoint.width
        ..strokeCap = StrokeCap.round;

      for (var i = 0; i < drawingPoint.offsets.length; i++) {
        var notLastOffset = i != drawingPoint.offsets.length - 1;

        if (notLastOffset) {
          final current = drawingPoint.offsets[i];
          final next = drawingPoint.offsets[i + 1];
          canvas.drawLine(current, next, paint);
        } else {
          /// we do nothing
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
