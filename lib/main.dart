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
                child: Text("1번 버튼 (이미지 선택)"),
              ),
              SizedBox(height: 20), // ✅ 버튼 간 간격 조정
              ElevatedButton(
                onPressed: () {
                  // ✅ 2번 버튼 (현재 기능 없음)
                },
                child: Text("2번 버튼"),
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

// ✅ 이미지 선택 화면
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
        _image = File(pickedFile.path); // ✅ 선택한 이미지 파일을 `_image` 변수에 저장
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이미지 선택 화면'), // ✅ 화면 제목
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // ✅ 뒤로 가기 아이콘
          onPressed: () {
            Navigator.pop(context); // ✅ 현재 화면을 닫고 메인 화면으로 이동
          },
        ),
      ),
      body: Stack(
        children: [
          // ✅ 선택한 이미지 또는 기본 텍스트 표시
          Center(
            child: _image != null
                ? Image.file(_image!, width: 250, height: 250, fit: BoxFit.cover) // ✅ 선택한 이미지 표시
                : Text("이미지를 선택하세요!", style: TextStyle(fontSize: 18)), // ✅ 이미지가 없을 경우 안내 문구
          ),

          // ✅ 버튼을 화면 하단 중앙에 배치
          Align(
            alignment: Alignment.bottomCenter, // ✅ 버튼을 화면 아래쪽 중앙에 정렬
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30), // ✅ 버튼과 화면 하단 간격 추가
              child: ElevatedButton(
                onPressed: pickImage, // ✅ 버튼을 누르면 `pickImage()` 실행
                child: Text("갤러리에서 이미지 선택"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
