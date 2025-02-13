import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // ✅ 디버그 배너 제거
      home: MainScreen(),
    );
  }
}

// ✅ 메인 화면 (감성적인 디자인 적용)
class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50], // ✅ 배경을 부드러운 베이지 색상으로 변경
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Colors.brown[100], // ✅ 내부 배경 색상 (카페 감성)
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(height: 40),
              // ✅ "Cafe" 제목을 감성적인 느낌으로 변경
              Text(
                "Cafe",
                style: GoogleFonts.pacifico(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800], // ✅ 따뜻한 브라운 계열 색상
                ),
              ),
              Spacer(),
              // ✅ 감성적인 버튼 디자인 적용
              _buildButton(context, "이미지 선택", () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ImagePickerScreen()));
              }),
              SizedBox(height: 20),
              _buildButton(context, "그림 그리기", () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DrawScreen()));
              }),
              SizedBox(height: 20),
              _buildButton(context, "3번 버튼", () {
                // ✅ 추가 기능 필요 시 여기에 작성
              }),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ 감성적인 버튼 디자인 함수
  Widget _buildButton(BuildContext context, String text, VoidCallback onPressed) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300), // ✅ 애니메이션 효과 추가
      curve: Curves.easeInOut,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown[300], // ✅ 따뜻한 브라운 계열
          foregroundColor: Colors.white, // ✅ 텍스트 색상
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // ✅ 부드러운 라운드 처리
          ),
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // ✅ 버튼 크기 조정
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ✅ 이미지 선택 화면 (감성적인 스타일 적용)
class ImagePickerScreen extends StatefulWidget {
  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  File? _image;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50], // ✅ 부드러운 배경색 적용
      appBar: AppBar(
        backgroundColor: Colors.brown[300],
        title: Text('이미지 선택', style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          Center(
            child: _image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(_image!, width: 300, height: 300, fit: BoxFit.cover),
                  )
                : Text("이미지를 선택하세요!", style: GoogleFonts.lato(fontSize: 18)),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[400],
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: pickImage,
                child: Text("갤러리에서 이미지 선택", style: GoogleFonts.lato(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// ✅ 그림 그리기 화면 (DrawScreen)
class DrawScreen extends StatefulWidget {
  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  List<Map<String, dynamic>> lines = []; // ✅ 기존 선들의 색상을 유지하도록 Map 구조 사용
  List<Offset?> currentLine = []; // ✅ 현재 그리고 있는 선
  Color selectedColor = Colors.black; // ✅ 기본 색상을 검은색으로 설정

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        backgroundColor: Colors.brown[300],
        title: Text("그리기 화면", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              setState(() {
                lines.clear();
                currentLine.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildColorPalette(),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (details) {
                setState(() {
                  currentLine = [];
                  Offset localPosition = details.localPosition; // ✅ 정확한 위치 사용
                  currentLine.add(localPosition);
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  Offset localPosition = details.localPosition; // ✅ 정확한 위치 사용
                  currentLine.add(localPosition);
                });
              },
              onPanEnd: (details) {
                setState(() {
                  lines.add({
                    "color": selectedColor,
                    "points": List<Offset?>.from(currentLine)
                  });
                  currentLine.clear();
                });
              },
              child: CustomPaint(
                painter: DrawPainter(lines, currentLine, selectedColor),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ 색상 선택 팔레트 UI
  Widget _buildColorPalette() {
    List<Color> colors = [Colors.black, Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: colors.map((color) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedColor = color;
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: selectedColor == color
                    ? Border.all(color: Colors.white, width: 3) // ✅ 선택한 색상 강조 표시
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ✅ 그림을 그리는 Painter 클래스
class DrawPainter extends CustomPainter {
  final List<Map<String, dynamic>> lines; // ✅ 기존 선 목록 (각 선의 색상을 포함)
  final List<Offset?> currentLine; // ✅ 현재 그리고 있는 선
  final Color currentColor; // ✅ 현재 선택된 색상

  DrawPainter(this.lines, this.currentLine, this.currentColor);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    // ✅ 기존 선 그리기 (이전 색상 유지)
    for (var line in lines) {
      paint.color = line["color"]; // ✅ 저장된 선의 색상을 적용
      List<Offset?> points = List<Offset?>.from(line["points"]);
      for (int i = 0; i < points.length - 1; i++) {
        if (points[i] != null && points[i + 1] != null) {
          canvas.drawLine(points[i]!, points[i + 1]!, paint);
        }
      }
    }

    // ✅ 현재 그리고 있는 선 그리기 (현재 선택한 색상 적용)
    paint.color = currentColor;
    for (int i = 0; i < currentLine.length - 1; i++) {
      if (currentLine[i] != null && currentLine[i + 1] != null) {
        canvas.drawLine(currentLine[i]!, currentLine[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawPainter oldDelegate) {
    return true;
  }
}
