import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ButtonScreen(),
    );
  }
}

class ButtonScreen extends StatefulWidget {
  @override
  _ButtonScreenState createState() => _ButtonScreenState();
}

class _ButtonScreenState extends State<ButtonScreen> {
  String displayText = "버튼을 눌러보세요!";

  void updateText(String newText) {
    setState(() {
      displayText = newText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter 버튼 앱 🚀')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(displayText, style: TextStyle(fontSize: 24)), // 변경될 텍스트
          SizedBox(height: 20), // 간격 추가
          ElevatedButton(
            onPressed: () => updateText("첫 번째 버튼 눌렀어요!"),
            child: Text("버튼 1"),
          ),
          SizedBox(height: 10), // 버튼 간격
          ElevatedButton(
            onPressed: () => updateText("두 번째 버튼 눌렀어요!"),
            child: Text("버튼 2"),
          ),
          SizedBox(height: 10), // 버튼 간격
          ElevatedButton(
            onPressed: () => updateText("세 번째 버튼 눌렀어요!"),
            child: Text("버튼 3"),
          ),
        ],
      ),
    );
  }
}
