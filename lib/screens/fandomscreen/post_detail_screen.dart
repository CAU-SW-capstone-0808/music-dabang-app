import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  static const routeName = 'post-detail';

  final Map<String, dynamic> post;

  const PostDetailScreen({super.key, required this.post});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  late bool isLiked;
  late int likes;

  final TextEditingController _commentController = TextEditingController();
  final Map<int, TextEditingController> _replyControllers = {};
  int? currentReplyTp;

  @override
  void initState() {
    super.initState();
    isLiked = widget.post['isLiked'] ?? false;
    likes = widget.post['likes'] ?? 0;
  }

  ///[post] : 특정 게시물에 대한 제목, 내용, 댓글, 답글 정보를 가진 데이터
  ///[onLikeToggle] : 좋아요 버튼(하트 버튼)을 눌렀을 때 backend 쪽의 좋아요 수에 영향을 주기 위한 함수
  Widget _buildShowMainPost({
    required Map<String, dynamic> post,
    required Function() onLikeToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  post['title'].isNotEmpty ? post['title'] : '제목이 없습니다',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            post['createdTime'].isNotEmpty
                ? '작성 시간: ${post['createdTime']}'
                : '작성 시간이 없습니다',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  post['content'].isNotEmpty ? post['content'] : '내용이 없습니다',
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              Text(
                '$likes',
                style: const TextStyle(fontSize: 16),
              ),
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.grey,
                ),
                onPressed: () => setState(() {
                  onLikeToggle;
                  if (isLiked) {
                    isLiked = false;
                    likes -= 1;
                  } else {
                    isLiked = true;
                    likes += 1;
                  }
                }), // 좋아요 토글 콜백
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildShowComment({
    required List<Map<String, dynamic>>? comments,
    required Function(String) onReplyPressed,
  }) {
    if (comments == null || comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '댓글이 없습니다',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (content, index) {
            final comment = comments[index];
            final replies =
                List<Map<String, dynamic>>.from(comment['replies'] ?? []);
            final isReplying = currentReplyTp == index;

            _replyControllers.putIfAbsent(index, () => TextEditingController());

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        currentReplyTp =
                            isReplying ? null : index; // Toggle reply form
                      });
                    },
                    child: Text(
                      comment['content'] * 10 ?? '내용이 없습니다',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '작성 시간: ${comment['createdTime'] ?? '시간 없음'}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  if (isReplying)
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _replyControllers[index],
                                  decoration: const InputDecoration(
                                    labelText: '답글 내용을 입력하세요',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Material(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(4),
                                child: IconButton(
                                  onPressed: () {
                                    final replyText =
                                        _replyControllers[index]?.text ?? '';
                                    if (replyText.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('답글 내용을 입력하세요!')),
                                      );
                                      return;
                                    }
                                    onReplyPressed(replyText);
                                    setState(() {
                                      _replyControllers[index]?.clear();
                                      currentReplyTp = null;
                                    });
                                  },
                                  icon: const Icon(Icons.input),
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _replyControllers[index]?.clear();
                                    currentReplyTp = null;
                                  });
                                },
                                child: const Text('취소'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (replies.isNotEmpty)
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16.0), // Indent replies
                      child: _buildShowReplies(replies: replies),
                    ),
                ],
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildShowReplies({required List<Map<String, dynamic>> replies}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: replies.length,
      itemBuilder: (context, index) {
        final reply = replies[index];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reply['content'] ?? '답글이 없습니다',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 2),
              Text(
                '작성 시간: ${reply['createdTime'] ?? '시간 없음'}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }

  ///[onCommentPressed] : 댓글이 입력되고 버튼이 눌렸을 때 이를 백엔드에 반영할 함수
  void _showAddCommentOverlay(
      BuildContext context, Function(String) onCommentPressed) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 8,
              ),
              const Text(
                '새 댓글 작성',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: '댓글 내용을 입력하세요',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              //댓글 추가 버튼이 눌리면 onCommentPressed 함수가 작동하고, 텍스트 필드를 비우며, 원래 화면으로 돌아간다.
              ElevatedButton(
                onPressed: () {
                  // Placeholder for adding comment logic
                  onCommentPressed(_commentController.text);
                  print('댓글 내용: ${_commentController.text}');
                  _commentController.clear(); // Clear the input field
                  Navigator.pop(context); // Close the bottom sheet
                },
                child: const Text('댓글 추가'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        isExtended: true,
        onPressed: () {
          _showAddCommentOverlay(context, (value) {});
        },
        label: const Text('댓글 추가'),
        icon: const Icon(Icons.add_comment),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildShowMainPost(
              post: widget.post,
              onLikeToggle: () {},
            ),
            const Divider(),
            _buildShowComment(
              comments:
                  List<Map<String, dynamic>>.from(widget.post['comments']),
              onReplyPressed: (value) {},
            ),
          ],
        ),
      ),
    );
  }
}
