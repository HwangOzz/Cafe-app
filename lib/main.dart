import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';

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
class DrawScreen extends StatefulWidget {
  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  List<DrawPath> paths = []; // Path 기반 최적화
  Path currentPath = Path();
  Paint currentPaint =
      Paint()
        ..color = Colors.black
        ..strokeWidth = 5.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

  bool isMenuOpen = false;
  bool isEraserMode = false;
  ui.Image? backgroundImage; // ✅ 배경 이미지 추가
  final ImagePicker _picker = ImagePicker(); // ✅ 이미지 선택기 추가
  final GlobalKey _globalKey = GlobalKey(); // 🔹 저장을 위한 GlobalKey 추가

  @override
  void initState() {
    super.initState();
    _requestPermission(); // 앱 실행 시 저장소 권한 요청
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.brown[300],
        title: Text("그리기 화면"),
        actions: [
          // ✅ 이미지 가져오기 버튼
          IconButton(
            icon: Icon(Icons.image),
            onPressed: () async {
              await _pickImage();
            },
          ),
          // ✅ 저장 버튼 추가 (기존 코드 유지)
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              await _saveDrawing();
            },
          ),
          // ✅ 전체 삭제 버튼 (배경 이미지도 지울 수 있도록 변경)
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              setState(() {
                paths.clear();
                currentPath = Path();
                backgroundImage = null; // 배경 이미지 삭제
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // ✅ RepaintBoundary 추가하여 성능 최적화
          RepaintBoundary(
            key: _globalKey, // 🔹 저장 기능을 위한 Key 설정
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (details) {
                setState(() {
                  currentPath = Path();
                  currentPath.moveTo(
                    details.localPosition.dx,
                    details.localPosition.dy,
                  );
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  currentPath.lineTo(
                    details.localPosition.dx,
                    details.localPosition.dy,
                  );
                });
              },
              onPanEnd: (details) {
                setState(() {
                  paths.add(
                    DrawPath(
                      path: Path.from(currentPath),
                      paint:
                          Paint()
                            ..color = currentPaint.color
                            ..strokeWidth = currentPaint.strokeWidth
                            ..style = PaintingStyle.stroke
                            ..strokeCap = StrokeCap.round,
                    ),
                  );
                  currentPath = Path();
                });
              },
              child: CustomPaint(
                painter: DrawPainter(
                  paths,
                  currentPath,
                  currentPaint,
                  backgroundImage,
                ),
                size: Size.infinite,
              ),
            ),
          ),

          // ✅ 설정 메뉴 UI
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
                  width: 200,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "설정",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),

                      // ✅ 지우개 버튼 추가
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isEraserMode ? Colors.orange : Colors.brown[300],
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            isEraserMode = !isEraserMode;
                            currentPaint.color =
                                isEraserMode ? Colors.white : Colors.black;
                          });
                        },
                        icon: Icon(Icons.cleaning_services),
                        label: Text(isEraserMode ? "지우개 ON" : "지우개 OFF"),
                      ),

                      Divider(),
                      Text(
                        "색상 선택",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

      // ✅ 설정 버튼 (FAB) - 메뉴 열기/닫기
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

  Future<void> _saveDrawing() async {
    try {
      // ✅ 저장소 권한 확인 후, 권한이 없으면 저장하지 않음
      if (!await _requestPermission()) {
        print("🚨 저장 중단: 권한이 없습니다.");
        return;
      }

      RenderRepaintBoundary boundary =
          _globalKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary;
      if (boundary == null) {
        throw Exception("🚨 RenderRepaintBoundary를 찾을 수 없습니다!");
      }

      ui.Image originalImage = await boundary.toImage();
      ByteData? byteData = await originalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // ✅ 🔹 핸드폰 내부 저장소 경로 직접 지정
      String cafeFolderPath = "/storage/emulated/0/CAFE"; // 🔥 변경된 저장 경로
      Directory cafeDir = Directory(cafeFolderPath);

      // ✅ 🔹 CAFE 폴더가 없으면 생성
      if (!await cafeDir.exists()) {
        await cafeDir.create(recursive: true);
      }

      // ✅ 🔹 CAFE 폴더 안에 새로운 이미지 파일 생성
      String filePath =
          "$cafeFolderPath/drawing_${DateTime.now().millisecondsSinceEpoch}.png";
      File file = File(filePath);
      await file.writeAsBytes(pngBytes);

      print("✅ 저장 성공! 파일 경로: $filePath");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("저장 완료! 경로: $filePath")));
    } catch (e) {
      print("저장 실패: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("저장 중 오류가 발생했습니다. 권한을 확인하세요.")));
    }
  }

  //저장소 권한 가져오기
  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      // ✅ Android 10 이하: storage 권한 확인
      if (await Permission.storage.isGranted) {
        print("✅ 저장소 권한이 이미 허용됨");
        return true;
      }

      // ✅ Android 11 이상: MANAGE_EXTERNAL_STORAGE 확인
      if (await Permission.manageExternalStorage.isGranted) {
        print("✅ 관리 저장소 권한이 이미 허용됨");
        return true;
      }

      // ❗ 권한이 없을 경우, 요청하기
      PermissionStatus storageStatus = await Permission.storage.request();
      PermissionStatus manageStorageStatus =
          await Permission.manageExternalStorage.request();

      if (storageStatus.isGranted || manageStorageStatus.isGranted) {
        print("✅ 새로 저장소 권한이 허용됨!");
        return true;
      } else {
        print("🚨 저장소 권한이 거부됨!");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("파일 저장을 위해 저장소 권한을 허용해야 합니다.")));
        return false;
      }
    }
    return true; // iOS는 권한 필요 없음
  }

  // ✅ 갤러리에서 이미지 선택하는 함수
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();

    setState(() {
      backgroundImage = frameInfo.image;
    });
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
                  if (!isEraserMode) {
                    currentPaint.color = color;
                  }
                });
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border:
                      currentPaint.color == color
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
      value: currentPaint.strokeWidth,
      min: 1.0,
      max: 20.0,
      divisions: 19,
      label: "${currentPaint.strokeWidth.toStringAsFixed(1)} px",
      onChanged: (value) {
        setState(() {
          currentPaint.strokeWidth = value;
        });
      },
    );
  }
}

// ✅ Path 기반으로 최적화된 Painter 클래스
class DrawPainter extends CustomPainter {
  final List<DrawPath> paths;
  final Path currentPath;
  final Paint currentPaint;
  final ui.Image? backgroundImage; // ✅ 배경 이미지 추가

  DrawPainter(
    this.paths,
    this.currentPath,
    this.currentPaint,
    this.backgroundImage,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // ✅ 배경 이미지를 화면에 맞게 조정해서 그리기
    if (backgroundImage != null) {
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.width, size.height),
        image: backgroundImage!,
        fit: BoxFit.cover,
      );
    }

    for (var drawPath in paths) {
      canvas.drawPath(drawPath.path, drawPath.paint);
    }
    canvas.drawPath(currentPath, currentPaint); // 현재 그리는 선도 즉시 반영
  }

  @override
  bool shouldRepaint(DrawPainter oldDelegate) => true;
}

// ✅ Path + Paint 정보를 저장하는 클래스
class DrawPath {
  final Path path;
  final Paint paint;
  DrawPath({required this.path, required this.paint});
}
