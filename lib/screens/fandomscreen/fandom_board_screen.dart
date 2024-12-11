import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data.dart';

class FandomBoardScreen extends ConsumerStatefulWidget {
  static const routeName = 'fandom-board';

  const FandomBoardScreen({super.key});

  @override
  ConsumerState<FandomBoardScreen> createState() => _FandomBoardScreenState();
}

class _FandomBoardScreenState extends ConsumerState<FandomBoardScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController all_posts_scrollController; //모든 게시물 확인 페이지 스크롤 컨트롤러
  late ScrollController popular_post_scrollController; //인기 게시물 확인 페이지 스크롤 컨트롤러
  late TabController tabController; //두 탭을 관리하기 위한 탭 컨트롤러

  /// 검색창을 생성하는 위젯
  /// [hintText]: 검색창에 표시될 힌트 텍스트
  /// [onSearchChanged]: 검색어 입력 시 호출될 콜백 함수
  Widget buildSearchBar({
    required String hintText,
    required Function(String) onSearchChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        onChanged: onSearchChanged, // 검색어 입력 시 호출될 함수
      ),
    );
  }

  /// [posts]: 표시할 게시물 데이터 리스트
  /// [isLoading]: 게시물이 추가로 로딩 중인지 여부
  /// [onItemTap]: 게시물을 클릭했을 때 호출될 함수
  /// [scrollController]: 스크롤을 제어하기 위한 컨트롤러
  Widget buildPostList({
    required List<Map<String, dynamic>> posts, //게시물
    bool isLoading = false,
    required void Function(Map<String, dynamic>) onItemTap,
    required ScrollController scrollController,
  }) {
    if (posts.isEmpty) {
      //게시물이 없을 시
      return const Center(
        child: Text(
          '게시물이 없습니다!',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      );
    } else {
      return ListView.builder(
        controller: scrollController,
        itemCount: posts.length + 1, // 로딩 스피너 포함
        itemBuilder: (context, index) {
          if (index == posts.length) {
            //로딩 중일 경우 마지막은 로딩 스피너
            return isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox.shrink(); //로딩 중이 아니면 빈 공간
          }
          final post = posts[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListTile(
              title: Text(
                post['title'] ?? '', // 게시물 제목
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('좋아요: ${post['likes']}'), // 좋아요 개수
              trailing: Text(
                post['createdTime']?.split('T')[0] ?? '', // 생성 날짜
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              onTap: () => onItemTap(post), // 게시물 클릭 시 해당 포스트로 이동하도록 만든다.
            ),
          );
        },
      );
    }
  }

  /// 글쓰기 버튼을 생성하는 위젯
  /// [onWritingPagePressed]: 글쓰기 버튼 클릭 시 호출될 함수, writing_post_screen으로 이동할 것.
  Widget buildWritingButton({required Function() onWritingPagePressed}) {
    return FloatingActionButton.extended(
      onPressed: onWritingPagePressed, // 클릭 시 호출
      label: const Text('글쓰기'),
      icon: const Icon(Icons.edit),
    );
    // return SizedBox(
    //   width: 140.0,
    //   height: 56.0,
    //   child: FloatingActionButton(
    //     onPressed: onWritingPagePressed, // 클릭 시 호출
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(16.0),
    //     ),
    //     backgroundColor: Colors.deepOrange,
    //     child: const Row(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Icon(
    //           Icons.edit,
    //           size: 20,
    //           color: Colors.white,
    //         ),
    //         SizedBox(width: 8),
    //         Text(
    //           '글쓰기',
    //           style: TextStyle(
    //             fontWeight: FontWeight.bold,
    //             fontSize: 16,
    //             fontFamily: 'Roboto',
    //             color: Colors.white,
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  @override
  void initState() {
    all_posts_scrollController = ScrollController();
    popular_post_scrollController = ScrollController();
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    all_posts_scrollController.dispose();
    popular_post_scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '게시판',
          style: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: '모든 게시물'),
            Tab(text: '인기 게시물'),
          ],
        ),
      ),
      floatingActionButton: buildWritingButton(
        onWritingPagePressed: () {
          context.goNamed('writing-post');
        }, // 글쓰기 버튼
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          Column(
            children: [
              buildSearchBar(
                hintText: '모든 게시물 검색...', // 모든 게시물 검색창
                onSearchChanged: (query) {},
              ),
              Expanded(
                child: buildPostList(
                  //모든 게시물 데이터
                  posts: posts,
                  onItemTap: (post) {
                    context.pushNamed('post-detail', extra: post);
                  },
                  scrollController: all_posts_scrollController,
                ),
              ),
            ],
          ),
          Column(
            children: [
              buildSearchBar(
                hintText: '인기 게시물 검색...', // 인기 게시물 검색창
                onSearchChanged: (query) {},
              ),
              Expanded(
                child: buildPostList(
                  posts: posts, // 인기 게시물 데이터
                  onItemTap: (post) {
                    context.pushNamed('post-detail', extra: post);
                  },
                  scrollController: popular_post_scrollController,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
