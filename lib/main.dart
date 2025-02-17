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
      backgroundColor: Colors.brown[50],
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Colors.brown[100],
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
            ],
          ),
          child: Column(
            children: [
              SizedBox(height: 40),
              Text(
                "Cafe",
                style: GoogleFonts.pacifico(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
              Spacer(),
              _buildButton(context, "이미지 선택", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ImagePickerScreen()),
                );
              }),
              SizedBox(height: 20),
              _buildButton(context, "그림 그리기", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DrawScreen()),
                );
              }),
              SizedBox(height: 20),
              _buildButton(context, "기타 기능", () {}),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.brown[300],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
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
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

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
        title: Text(
          '이미지 선택',
          style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child:
                _image != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        _image!,
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    )
                    : Text(
                      "이미지를 선택하세요!",
                      style: GoogleFonts.lato(fontSize: 18),
                    ),
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
                child: Text(
                  "갤러리에서 이미지 선택",
                  style: GoogleFonts.lato(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ 그림 그리기 화면 (DrawScreen)

// ✅ 그림 그리기 화면 (DrawScreen)
class DrawScreen extends StatefulWidget {
  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  List<Map<String, dynamic>> lines = [];
  List<Offset?> currentLine = [];
  Color selectedColor = Colors.black;
  double brushSize = 5.0;
  bool isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        backgroundColor: Colors.brown[300],
        title: Text("그리기 화면"),
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
      body: Stack(
        children: [
          RepaintBoundary(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (details) {
                setState(() {
                  currentLine = [details.localPosition];
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  currentLine.add(details.localPosition);
                  lines.add({
                    "color": selectedColor,
                    "brushSize": brushSize,
                    "points": List<Offset?>.from(currentLine),
                  });
                });
              },
              onPanEnd: (details) {
                setState(() {
                  currentLine.clear();
                });
              },
              child: CustomPaint(
                painter: DrawPainter(
                  lines,
                  currentLine,
                  selectedColor,
                  brushSize,
                ),
                size: Size.infinite,
              ),
            ),
          ),

          if (isMenuOpen)
            Positioned(
              right: 20,
              bottom: 80,
              child: Material(
                color: Colors.white,
                elevation: 5,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: EdgeInsets.all(10),
                  width: 180,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "색상 선택",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      _buildColorPalette(),
                      Divider(),
                      Text(
                        "브러쉬 크기",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildBrushSizeSlider(),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown[400],
        child: Icon(
          isMenuOpen ? Icons.close : Icons.settings,
          color: Colors.white,
        ),
        onPressed: () {
          setState(() {
            isMenuOpen = !isMenuOpen;
          });
        },
      ),
    );
  }

  Widget _buildColorPalette() {
    List<Color> colors = [
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
      Colors.pink,
      Colors.cyan,
      Colors.teal,
      Colors.brown,
      Colors.grey,
    ];

    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children:
          colors.map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedColor = color;
                });
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border:
                      selectedColor == color
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildBrushSizeSlider() {
    return Slider(
      value: brushSize,
      min: 1.0,
      max: 20.0,
      divisions: 19,
      label: "${brushSize.toStringAsFixed(1)} px",
      onChanged: (value) {
        setState(() {
          brushSize = value;
        });
      },
    );
  }
}

class DrawPainter extends CustomPainter {
  final List<Map<String, dynamic>> lines;
  final List<Offset?> currentLine;
  final Color currentColor;
  final double brushSize;

  DrawPainter(this.lines, this.currentLine, this.currentColor, this.brushSize);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..strokeCap = StrokeCap.round;
    for (var line in lines) {
      paint.color = line["color"];
      paint.strokeWidth = line["brushSize"];
      List<Offset?> points = List<Offset?>.from(line["points"]);
      for (int i = 0; i < points.length - 1; i++) {
        if (points[i] != null && points[i + 1] != null) {
          canvas.drawLine(points[i]!, points[i + 1]!, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(DrawPainter oldDelegate) => true;
}
