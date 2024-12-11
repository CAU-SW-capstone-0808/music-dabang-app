import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/components/custom_search_bar.dart';
import 'package:music_dabang/components/logo_title.dart';
import 'package:music_dabang/models/post/post_model.dart';
import 'package:music_dabang/providers/music/artists_provider.dart';
import 'package:music_dabang/providers/post/fandom_provider.dart';
import 'package:music_dabang/providers/post/post_list_provider.dart';

import 'components/artist_selector.dart';
import 'data.dart';

class FandomHomeScreen extends ConsumerStatefulWidget {
  static const routeName = 'fandom-home';

  const FandomHomeScreen({super.key});

  @override
  ConsumerState<FandomHomeScreen> createState() => _FandomHomeScreenState();
}

class _FandomHomeScreenState extends ConsumerState<FandomHomeScreen> {
  String artistSearchQuery = '';

  /// 상단 인사말
  Widget greeting({required String artistName}) {
    return Row(
      children: [
        Text(
          artistName,
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        const Expanded(
          child: Text(
            " 팬클럽에 오신 것을 환영합니다.",
            style: TextStyle(fontSize: 16.0),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              artistSearchQuery = '';
            });
            ref.read(selectedArtistIdProvider.notifier).clear();
          },
          child: const Text(
            "변경",
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        )
      ],
    );
  }

  Widget buildBlock({
    //공지, 일정, 뉴스를 한번에 구성하기 위한 block
    required String title, //어느 탭인지 보여주는 역할
    required List<Map<String, dynamic>> items, //제목 - 이하 정보
    required Widget Function(Map<String, dynamic>)
        itemBuilder, //정보를 list 변환하여 출력하기 위한 builder
  }) {
    //공지, 뉴스, 일정 표시를 위함.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          //어떤 페이지인지 입력
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          //거리 띄기
          height: 10,
        ),
        Container(
          //회색 둥근 화면에 item을 나열하기
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            children: items.map(itemBuilder).toList(),
          ),
        )
      ],
    );
  }

  ///[title] : 어떤 탭인지 표시
  ///[items] : 최신 인기글 5개를 가지고 있는 아이템(몇개인지는 바뀔 수 있습니다.)
  ///[onItemTap] : 최신 인기글 각각을 누르면 해당 페이지로 이동하도록 만드는 함수
  ///[onViewAllPressed] : 모든 게시물 보기 텍스트 버튼을 눌렀을 시 게시판 페이지로 이동하도록 만드는 함수
  Widget buildPopularPosts({
    required String title,
    required List<PostModel> items,
    required void Function(Map<String, dynamic> item) onItemTap,
    required void Function()? onViewAllPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// 제목
            Text(
              title,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),

            /// 모든 게시글 보기 버튼(onViewAllPressed 함수를 넣었을 때 작동하도록)
            TextButton(
              onPressed: onViewAllPressed,
              child: const Text(
                '모든 게시글 보기',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const Center(
            child: Text(
              '게시글이 없습니다.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.0),
            ),

            /// 인기글 목록
            child: Column(
              children: items.map((p) {
                return InkWell(
                  onTap: () {},
                  child: Container(
                    child: ListTile(
                      title: Text(
                        p.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text('좋아요: ${p.likes}'),
                      trailing: Text(
                        p.createdAt.toString().split('T')[0],
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ),
                  ),
                );
              }).toList(),
              // children: List.generate(
              //   items.length * 2 - 1,
              //   (index) {
              //     if (index.isEven) {
              //       //인기글(좋아요 정보 포함)과 회색 선을 번갈아 가며 넣기
              //       final item = items[index ~/ 2];
              //       return GestureDetector(
              //         onTap: () {
              //           // onItemTap(item);
              //         },
              //         //특정 아이템을 선택 시 post_detail_screen에 post 정보를 전달하고 화면을 전환할 함수 onItemTap.
              //         child: ListTile(
              //           title: Text(
              //             item['title'] ?? '',
              //             style: const TextStyle(
              //               fontWeight: FontWeight.bold,
              //               fontSize: 16,
              //             ),
              //           ),
              //           subtitle: Text('좋아요: ${item['likes']}'),
              //           trailing: Text(
              //             item['createdTime']?.split('T')[0] ?? '',
              //             style:
              //                 const TextStyle(fontSize: 14, color: Colors.black),
              //           ),
              //         ),
              //       );
              //     } else {
              //       return const Padding(
              //         padding: EdgeInsets.symmetric(vertical: 4.0),
              //         child: Divider(
              //           color: Colors.grey,
              //           thickness: 1,
              //           indent: 10,
              //           endIndent: 10,
              //         ),
              //       );
              //     }
              //   },
              // ),
            ),
          ),
      ],
    );
  }

  Widget buildAppBar({
    required void Function()? onFandomSwitchPressed,
  }) {
    return SafeArea(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const LogoTitle(),
                  TextButton(
                    onPressed: onFandomSwitchPressed,
                    child: const Text(
                      '팬덤 전환',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          const Divider(
            color: Colors.grey,
            thickness: 1,
            height: 1,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final artists = ref.watch(artistsProvider);
    final selectedArtistId = ref.watch(selectedArtistIdProvider);
    final posts = ref.watch(postListProvider);

    // 미선택 시 화면
    if (selectedArtistId == null) {
      return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ArtistSelector(searchQuery: artistSearchQuery),
                const SizedBox(height: 16),
                const Text(
                  "좋아하는 가수를 선택해주세요!",
                  style: TextStyle(
                    fontSize: 22.0,
                    color: ColorTable.textGrey,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 300,
                  child: CustomSearchBar(
                    hintText: "가수 이름 검색",
                    onChanged: (value) {
                      setState(() {
                        artistSearchQuery = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final selectedArtist =
        artists.firstWhere((artist) => artist.id == selectedArtistId);

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: LogoTitle(),
              ),
              const SizedBox(height: 12),
              const ArtistSelector(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    greeting(artistName: selectedArtist.name),
                    const SizedBox(height: 8),
                    // 공지사항 섹션
                    buildBlock(
                      title: '공지사항',
                      items: announcements,
                      itemBuilder: (item) => ListTile(
                        title: Text(item['title'] ?? ''),
                        subtitle: Text(item['content'] ?? ''),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 일정 섹션
                    buildBlock(
                      title: '일정',
                      items: schedules,
                      itemBuilder: (item) => ListTile(
                        title: Text(item['event'] ?? ''),
                        trailing: Text(item['date'] ?? ''),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 뉴스 섹션
                    buildBlock(
                      title: '뉴스',
                      items: news,
                      itemBuilder: (item) => ListTile(
                        title: Text(
                          item['headline'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(item['details'] ?? ''),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 인기 게시글 섹션
                    buildPopularPosts(
                      title: '인기 게시글',
                      items: posts,
                      onItemTap: (item) {
                        context.goNamed('post-detail', extra: item);
                      }, // 게시글 데이터 전달
                      onViewAllPressed: () {
                        context.goNamed('fandom-board');
                      }, // 모든 게시물 보기 눌렀을 때 그 페이지로 이동
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
