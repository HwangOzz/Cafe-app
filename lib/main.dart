import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImagePickerScreen(),
    );
  }
}

class ImagePickerScreen extends StatefulWidget {
  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  File? _image; // 선택한 이미지 파일

  // ✅ 갤러리에서 이미지 선택하는 함수
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // 선택한 이미지를 화면에 표시
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('이미지 선택 앱 🚀')),
      body: Stack(
        children: [
          // ✅ 이미지 중앙 배치
          Center(
            child: _image != null
                ? Image.file(_image!, width: 250, height: 250, fit: BoxFit.cover) // 선택한 이미지 표시
                : Text("이미지를 선택하세요!", style: TextStyle(fontSize: 18)),
          ),

          // ✅ 버튼을 화면 하단 중앙에 배치
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30), // 하단 여백 추가
              child: ElevatedButton(
                onPressed: pickImage, // ✅ 버튼을 누르면 갤러리에서 이미지 선택
                child: Text("갤러리에서 이미지 선택"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
