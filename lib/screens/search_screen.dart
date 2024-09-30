import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/common/firebase_logger.dart';
import 'package:music_dabang/components/custom_search_bar.dart';
import 'package:music_dabang/components/music_list_card.dart';
import 'package:music_dabang/components/to_top_button.dart';
import 'package:music_dabang/models/music/music_model.dart';
import 'package:music_dabang/providers/common/page_scroll_controller.dart';
import 'package:music_dabang/providers/music/music_autocomplete_provider.dart';
import 'package:music_dabang/providers/music/music_player_provider.dart';
import 'package:music_dabang/providers/music/music_search_provider.dart';
import 'package:music_dabang/providers/music/recent_search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  static const routeName = 'search';

  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  /// 검색 결과를 불러오는 데 쓰이는 키워드.
  /// null: 입력 전
  /// 공백: 입력 중
  String? searchKeyword;
  final searchController = TextEditingController();

  // 결과에 대한 스크롤 컨트롤러
  final resultPageController = PageScrollController();

  bool get showRecent => searchKeyword == null;

  bool get showAutoComplete => searchKeyword == '';

  bool get showResult => searchKeyword != null && searchKeyword!.isNotEmpty;
  bool showToTop = false; // 위로 가기 버튼

  Widget searchItem({
    required String content,
    void Function(String)? onTap,
    void Function(String)? onRemove,
  }) {
    return InkWell(
      onTap: () {
        onTap?.call(content);
      },
      child: Ink(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 7.5 + 8),
                child: Text(
                  content,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            if (onRemove != null)
              InkWell(
                onTap: () => onRemove(content),
                borderRadius: BorderRadius.circular(100),
                child: Ink(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 5.0,
                  ),
                  decoration: BoxDecoration(
                    color: ColorTable.chipGrey,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        '지우기',
                        style: TextStyle(
                          fontSize: 18.0,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(width: 4.0),
                      Icon(
                        CupertinoIcons.xmark,
                        size: 18.0,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget recentScrollView(List<String> recentItems) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '최근 검색',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ...recentItems.map(
            (q) => searchItem(
              content: q,
              onTap: (q) async {
                search(q);
                FirebaseLogger.useRecentSearchKeyword(
                  keyword: q,
                  index: recentItems.indexOf(q),
                );
              },
              onRemove: (q) {
                ref.read(recentSearchProvider.notifier).remove(q);
                FirebaseLogger.deleteRecentSearchKeyword(
                  keyword: q,
                  index: recentItems.indexOf(q),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget autoCompleteScrollView(List<String> autoCompletes) {
    return SingleChildScrollView(
      child: Column(
        children: autoCompletes
            .map((q) => searchItem(
                  content: q,
                  onTap: (q) {
                    FirebaseLogger.useAutoCompleteSearchMusic(
                      currentKeyword: searchController.value.text,
                      selectedKeyword: q,
                      index: autoCompletes.indexOf(q),
                    );
                    search(q);
                  },
                ))
            .toList(),
      ),
    );
  }

  Widget resultScrollView(List<MusicModel> results) {
    final loading =
        ref.read(musicSearchProvider(searchKeyword!).notifier).loading;
    if (results.isEmpty) {
      return loading
          ? const Center(child: CircularProgressIndicator())
          : const Center(
              child: Text(
                '검색 결과가 없습니다.',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
    }
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(musicSearchProvider(searchKeyword!).notifier).refresh();
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: resultPageController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: results.length,
        itemBuilder: (build, index) {
          final m = results[index];
          return MusicListCard(
            title: m.title,
            artist: m.artist.name,
            imageUrl: m.thumbnailUrl,
            onTap: () async {
              await ref
                  .read(currentPlayingMusicProvider.notifier)
                  .setPlayingMusic(m)
                  .then((_) {
                ref.read(musicPlayerStatusProvider.notifier).expand();
                context.go('/');
              });
              FirebaseLogger.playMusicInSearchScreen(
                musicId: m.id,
                keyword: searchController.value.text,
                title: m.title,
                artist: m.artist.name,
                index: index,
              );
            },
          );
        },
      ),
    );
  }

  void search(String q) {
    if (q.isEmpty) return;
    setState(() => searchKeyword = q);
    searchController.text = q;
    ref.read(recentSearchProvider.notifier).add(q);
    FirebaseLogger.searchMusic(keyword: q);
  }

  @override
  void initState() {
    super.initState();
    resultPageController.onEnd = () {
      ref.read(musicSearchProvider(searchKeyword!).notifier).fetch();
    };
    resultPageController.onOffset = (ofs) {
      bool showToTopByOffset = ofs > 800;
      if (showToTopByOffset != showToTop) {
        setState(() => showToTop = showToTopByOffset);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    List<String> recentKeywords = ref.watch(recentSearchProvider);
    List<String> autoCompletes = ref.watch(musicAutoCompleteProvider);
    List<MusicModel> searchResult =
        ref.watch(musicSearchProvider(searchKeyword ?? ''));
    return PopScope(
      canPop: !showResult,
      onPopInvokedWithResult: (_, __) {
        if (showResult) {
          setState(() => searchKeyword = null);
          searchController.clear();
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          floatingActionButton: showToTop && showResult
              ? ToTopButton(scrollController: resultPageController)
              : null,
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: IconButton(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            }
                          },
                          icon: const Icon(Icons.arrow_back),
                          iconSize: 32,
                        ),
                      ),
                      Expanded(
                        child: Hero(
                          tag: 'search-bar',
                          child: CustomSearchBar(
                            controller: searchController,
                            autofocus: true,
                            showClearButton: showResult,
                            onClear: () {
                              setState(() => searchKeyword = null);
                              searchController.clear();
                              FirebaseLogger.clearMusicSearchField();
                            },
                            onChanged: (value) {
                              ref
                                  .read(musicAutoCompleteProvider.notifier)
                                  .keyword = value;
                              if (value.isEmpty) {
                                setState(() => searchKeyword = null);
                              } else {
                                setState(() => searchKeyword = '');
                              }
                            },
                            onSubmitted: search,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                    ],
                  ),
                ),
                Expanded(
                  child: showRecent
                      ? recentScrollView(recentKeywords)
                      : (showAutoComplete
                          ? autoCompleteScrollView(autoCompletes)
                          : resultScrollView(searchResult)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    resultPageController.dispose();
  }
}
