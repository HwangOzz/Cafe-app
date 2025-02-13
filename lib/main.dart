import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart'; // ✅ Google Fonts 추가
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(), // ✅ 메인 화면을 첫 화면으로 설정
    );
  }
}

// ✅ 메인 화면 (배경 흰색, 내부 회색 라운드 박스 + "Cafe" 제목 추가)
class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ 바깥 배경을 흰색으로 설정
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9, // ✅ 화면의 90% 크기
          height: MediaQuery.of(context).size.height * 0.85, // ✅ 화면의 85% 크기
          decoration: BoxDecoration(
            color: Colors.grey[300], // ✅ 내부(컨텐츠 영역) 색상을 회색으로 설정
            borderRadius: BorderRadius.circular(30), // ✅ 모서리를 둥글게 설정
            boxShadow: [
              BoxShadow(
                color: Colors.black26, // ✅ 그림자 효과
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(height: 40), // ✅ 상단 여백 추가
              // ✅ "Cafe" 제목 추가
              Text(
                "Cafe",
                style: GoogleFonts.pacifico( // ✅ 예쁜 필기체 폰트 적용
                  fontSize: 36, // ✅ 폰트 크기
                  fontWeight: FontWeight.bold, // ✅ 굵기 설정
                  color: Colors.brown[800], // ✅ 커피 느낌의 갈색 계열 색상
                ),
              ),
              Spacer(), // ✅ 제목과 버튼 사이 여백을 최대한 확보
              ElevatedButton(
                onPressed: () {
                  // ✅ 1번 버튼 → 이미지 선택 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ImagePickerScreen()),
                  );
                },
                child: Text("이미지 선택"),
              ),
              SizedBox(height: 20), // ✅ 버튼 간 간격 조정
              ElevatedButton(
                onPressed: () {
                  // ✅ 2번 버튼 → 그리기 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DrawScreen()),
                  );
                },
                child: Text("그림 그리기"),
              ),
              SizedBox(height: 20), // ✅ 버튼 간 간격 조정
              ElevatedButton(
                onPressed: () {
                  // ✅ 3번 버튼 (현재 기능 없음)
                },
                child: Text("3번 버튼"),
              ),
              SizedBox(height: 40), // ✅ 하단 여백 추가
            ],
          ),
        ),
      ),
    );
  }
}
// ✅ 그리기 화면 (DrawScreen)
class DrawScreen extends StatefulWidget {
  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  List<Offset?> points = []; // ✅ 사용자가 터치한 점들의 리스트

  @override
  Widget build(BuildContext context) {
    double appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight; // ✅ AppBar + StatusBar 높이

    return Scaffold(
      appBar: AppBar(
        title: Text("그리기 화면"),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              setState(() {
                points.clear(); // ✅ 그림 초기화 (모든 점 삭제)
              });
            },
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent, // ✅ 터치 감지 문제 해결
        onPanUpdate: (details) {
          setState(() {
            RenderBox box = context.findRenderObject() as RenderBox;
            Offset localPosition = box.globalToLocal(details.globalPosition);
            points.add(Offset(localPosition.dx, localPosition.dy - appBarHeight)); // ✅ AppBar 높이만큼 y좌표 조정
          });
        },
        onPanEnd: (details) {
          setState(() {
            points.add(null); // ✅ 손을 떼면 새로운 선을 그릴 수 있도록 `null` 추가
          });
        },
        child: CustomPaint(
          painter: DrawPainter(points), // ✅ 그림을 그리는 Painter 적용
          size: Size.infinite,
        ),
      ),
    );
  }
}

// ✅ 그림을 그리는 Painter 클래스
class DrawPainter extends CustomPainter {
  List<Offset?> points; // ✅ 터치한 점들의 리스트

  DrawPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black // ✅ 선 색상을 검은색으로 설정
      ..strokeCap = StrokeCap.round // ✅ 선 끝을 둥글게 설정
      ..strokeWidth = 5.0; // ✅ 선 두께 설정

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint); // ✅ 두 점을 잇는 선을 그림
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true; // ✅ 변경 사항이 있을 때마다 다시 그림
  }
}



// ✅ 이미지 선택 화면 (1번 버튼 기능)
class ImagePickerScreen extends StatefulWidget {
  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

// ✅ 상태를 관리하는 클래스 (이미지 선택 기능 추가)
class _ImagePickerScreenState extends State<ImagePickerScreen> {
  File? _image; // ✅ 선택한 이미지 파일을 저장할 변수

  // ✅ 갤러리에서 이미지 선택하는 함수
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker(); // ✅ 이미지 선택을 위한 객체 생성
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery); // ✅ 갤러리에서 이미지 선택

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // ✅ 선택한 이미지를 `_image` 변수에 저장
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이미지 선택 화면'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          _image != null
              ? Image.file(_image!, width: double.infinity, height: double.infinity, fit: BoxFit.cover)
              : Center(child: Text("이미지를 선택하세요!", style: TextStyle(fontSize: 18))),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: ElevatedButton(
                onPressed: pickImage,
                child: Text("갤러리에서 이미지 선택"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
