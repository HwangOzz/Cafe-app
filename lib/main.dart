import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert'; // ✅ jsonDecode를 사용하려면 필요함

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ✅ Firebase 초기화
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

              // ✅ 커피 PNG + 애니메이션 추가
              Expanded(child: _CoffeeAnimation()),

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

// ✅ 커피 애니메이션 (김 효과 수정)
class _CoffeeAnimation extends StatefulWidget {
  @override
  __CoffeeAnimationState createState() => __CoffeeAnimationState();
}

class __CoffeeAnimationState extends State<_CoffeeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _steamAnimation;
  final Random _random = Random();

  // ✅ 김의 랜덤 위치값을 고정시키기 위해 리스트로 저장
  late List<double> xOffsets;
  late List<double> sizes;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5), // 🔥 속도를 더 느리게 조정 (3초 → 5초)
    )..repeat(reverse: false);

    // ✅ 김이 천천히 올라가면서 사라지도록 조정
    _steamAnimation = Tween<double>(
      begin: 0,
      end: -120,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // ✅ 랜덤 위치값을 미리 생성해서, 매 프레임마다 바뀌지 않도록 함
    xOffsets = List.generate(5, (index) => _random.nextDouble() * 40 - 20);
    sizes = List.generate(5, (index) => _random.nextDouble() * 25 + 20);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // ✅ 커피 PNG 이미지 크기 조정
        Image.asset('assets/coffee.png', width: 180),

        // ✅ 김(Steam) 효과 (애니메이션 적용)
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: List.generate(
                5,
                (index) => _buildSteam(index),
              ), // 🔥 김 5개 생성
            );
          },
        ),
      ],
    );
  }

  // ✅ 김 효과 (랜덤한 크기, 위치, 투명도 + 부드러운 애니메이션)
  Widget _buildSteam(int index) {
    return Transform.translate(
      offset: Offset(
        xOffsets[index],
        _steamAnimation.value - 50,
      ), // 🔥 김 위치를 위로 올리기
      child: Opacity(
        opacity: (1 - (_steamAnimation.value / -120)).clamp(
          0,
          1,
        ), // 🔥 자연스럽게 사라지게
        child: Container(
          width: sizes[index], // ✅ 크기 랜덤
          height: sizes[index],
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.4), // 🔥 흐린 효과
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.5), // 🔥 부드러운 빛 퍼지는 효과
                blurRadius: 20, // 🔥 Blur 효과 증가
                spreadRadius: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ 이미지 선택 화면 (변환된 이미지 저장 기능 추가)
class ImagePickerScreen extends StatefulWidget {
  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  File? _image; // ✅ 선택한 원본 이미지
  Uint8List? _processedImageBytes; // ✅ 변환된 테두리 이미지 데이터
  final ImagePicker _picker = ImagePicker();
  final String serverUrl =
      "http://192.168.0.126:8000/upload/"; // 🔹 Python 서버 URL

  // ✅ 저장소 권한 확인 함수 (그리기 화면과 동일하게 수정)
  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      // ✅ 먼저 권한이 이미 허용되었는지 확인
      if (await Permission.storage.isGranted ||
          await Permission.manageExternalStorage.isGranted) {
        print("✅ 저장소 권한이 이미 허용됨");
        return true;
      }

      // ❗ 권한 요청 진행
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

  // ✅ OpenCV 서버로 이미지 업로드 → 테두리 검출 요청
  Future<void> extractEdges() async {
    if (_image == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("이미지를 먼저 선택하세요!")));
      return;
    }

    try {
      print("🔹 서버 요청 시작... URL: $serverUrl");

      var request = http.MultipartRequest('POST', Uri.parse(serverUrl));
      request.files.add(
        await http.MultipartFile.fromPath('file', _image!.path),
      );

      print("🔹 HTTP 요청 준비 완료, 전송 시도 중...");

      var response = await request.send();

      print("🔹 HTTP 응답 수신 완료! 상태 코드: ${response.statusCode}");

      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        setState(() {
          _processedImageBytes = responseData;
        });
        print("✅ 테두리 이미지 변환 성공!");
      } else {
        print("🚨 서버 오류 발생! 상태 코드: ${response.statusCode}");
        print("🚨 오류 내용: ${await response.stream.bytesToString()}");
      }
    } catch (e) {
      print("🚨 요청 중 오류 발생: $e");
    }
  }

  // ✅ 갤러리에서 이미지 선택
  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _processedImageBytes = null; // 새 이미지 선택 시 기존 변환된 이미지 삭제
      });
    }
  }

  // ✅ 변환된 이미지 저장 함수 (권한 체크 수정)
  Future<void> _saveProcessedDrawing() async {
    try {
      if (_processedImageBytes == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("변환된 이미지가 없습니다!")));
        return;
      }

      // ✅ 저장소 권한 확인
      bool hasPermission = await _requestPermission();
      if (!hasPermission) {
        print("🚨 저장 중단: 권한이 없습니다.");
        return;
      }

      // ✅ 저장할 경로 설정
      String cafeFolderPath = "/storage/emulated/0/CAFE";
      Directory cafeDir = Directory(cafeFolderPath);
      if (!await cafeDir.exists()) {
        await cafeDir.create(recursive: true);
      }

      // ✅ 파일 저장
      String filePath =
          "$cafeFolderPath/converted_${DateTime.now().millisecondsSinceEpoch}.png";
      File file = File(filePath);
      await file.writeAsBytes(_processedImageBytes!);

      print("✅ 저장 성공! 파일 경로: $filePath");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("이미지 저장 완료!")));
    } catch (e) {
      print("🚨 저장 실패: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("저장 중 오류가 발생했습니다.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        backgroundColor: Colors.brown[300],
        title: Text('이미지 선택'),
        actions: [
          // ✅ 테두리 추출 버튼
          IconButton(icon: Icon(Icons.filter_b_and_w), onPressed: extractEdges),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? Column(
                  children: [
                    Text(
                      "원본 이미지",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Image.file(
                      _image!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ],
                )
                : Text("이미지를 선택하세요!", style: TextStyle(fontSize: 18)),

            SizedBox(height: 20),

            _processedImageBytes != null
                ? Column(
                  children: [
                    Text(
                      "변환된 이미지",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Image.memory(
                      _processedImageBytes!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ],
                )
                : Container(),

            SizedBox(height: 20),

            // ✅ 이미지 선택 버튼
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[400],
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: pickImage,
              child: Text("갤러리에서 이미지 선택", style: TextStyle(fontSize: 16)),
            ),

            SizedBox(height: 10),

            // ✅ 변환된 이미지 저장 버튼 (권한 체크 개선)
            _processedImageBytes != null
                ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[400],
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: _saveProcessedDrawing,
                  child: Text("변환된 이미지 저장", style: TextStyle(fontSize: 16)),
                )
                : Container(),
          ],
        ),
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

      // ✅ 원본 캔버스를 이미지로 변환
      ui.Image originalImage = await boundary.toImage();
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(
          0,
          0,
          originalImage.width.toDouble(),
          originalImage.height.toDouble(),
        ),
      );

      // ✅ 흰색 배경 추가 후 그림 복사
      Paint backgroundPaint = Paint()..color = Colors.white;
      canvas.drawRect(
        Rect.fromLTWH(
          0,
          0,
          originalImage.width.toDouble(),
          originalImage.height.toDouble(),
        ),
        backgroundPaint,
      );
      Paint paint = Paint();
      canvas.drawImage(originalImage, Offset.zero, paint);

      // ✅ 최종 이미지 생성
      ui.Image finalImage = await recorder.endRecording().toImage(
        originalImage.width,
        originalImage.height,
      );
      ByteData? byteData = await finalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // ✅ 저장 경로 지정
      String cafeFolderPath = "/storage/emulated/0/CAFE";
      Directory cafeDir = Directory(cafeFolderPath);
      if (!await cafeDir.exists()) {
        await cafeDir.create(recursive: true);
      }

      String filePath =
          "$cafeFolderPath/drawing_${DateTime.now().millisecondsSinceEpoch}.png";
      File file = File(filePath);
      await file.writeAsBytes(pngBytes);

      print("✅ 저장 성공! 파일 경로: $filePath");

      // ✅ Firebase Storage로 업로드 실행!
      await _uploadToFirebase(file);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("저장 완료!")));
    } catch (e) {
      print("🚨 저장 실패: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("저장 중 오류가 발생했습니다.")));
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

  Future<void> _uploadToFirebase(File file) async {
    try {
      // ✅ Firebase Storage 경로 설정
      String fileName = "drawing_${DateTime.now().millisecondsSinceEpoch}.png";
      Reference storageRef = FirebaseStorage.instance.ref().child(
        "drawings/$fileName",
      );

      // ✅ 파일 업로드
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      // ✅ 업로드 완료 후, 다운로드 URL 가져오기
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("✅ 업로드 완료! 다운로드 URL: $downloadUrl");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("이미지 업로드 완료!")));
    } catch (e) {
      print("🚨 Firebase 업로드 실패: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("업로드 실패! 다시 시도하세요.")));
    }
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
