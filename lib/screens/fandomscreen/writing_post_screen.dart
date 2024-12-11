import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/providers/post/post_list_provider.dart';

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
  Widget _buildWritingForm({
    required Future<void> Function(String, String) dataTransmitter,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
            TextFormField(
              controller: _detailController,
              minLines: 6,
              maxLines: null,
              // expands: true,
              textAlign: TextAlign.start,
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
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () async {
                  if (_formkey.currentState?.validate() ?? false) {
                    await dataTransmitter(
                      _titleController.text,
                      _detailController.text,
                    );
                    Navigator.pop(context);
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("새 글 작성"),
        ),
        body: _buildWritingForm(
          dataTransmitter: (title, content) async {
            ref.read(postListProvider.notifier).addPost(
                  title: title,
                  content: content,
                );
          },
        ),
      ),
    );
  }
}
