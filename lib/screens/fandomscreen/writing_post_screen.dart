import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class WritingPostScreen extends ConsumerStatefulWidget {
  static const routeName = 'writing-post';

  const WritingPostScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _WritingPostScreenState();
}

class _WritingPostScreenState extends ConsumerState<WritingPostScreen> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();

  ///[dataTransmitter] : 제목, 내용 textfield의 String을 백엔드로 전달할 함수
  Widget _buildWritingForm(
      {required Function(String, String) dataTransmitter}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formkey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '제목',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: "제목을 입력하세요",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '제목을 입력해 주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              "내용",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextFormField(
                controller: _detailController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: "내용을 입력하세요",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "내용을 입력해 주세요";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_formkey.currentState?.validate() ?? false) {
                    dataTransmitter(
                      _titleController.text,
                      _detailController.text,
                    );
                    Navigator.pop(context);
                    //원래 화면으로 돌아갈 함수도 필요할 것이다.
                  }
                },
                child: const Text(
                  "게시글 작성",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("새 글 작성"),
        ),
        body: _buildWritingForm(dataTransmitter: (title, content) {
          print('$title');
          print('$content');
        }));
  }
}
