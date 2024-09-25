import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/components/custom_search_bar.dart';
import 'package:music_dabang/providers/music/music_autocomplete_provider.dart';
import 'package:music_dabang/providers/music/recent_search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  static const routeName = 'search';

  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String searchKeyword = '';
  final searchController = TextEditingController();

  bool get showRecent => searchKeyword.isEmpty;

  Widget searchItem({
    required String content,
    void Function(String)? onTap,
    void Function(String)? onRemove,
  }) {
    return InkWell(
      onTap: () {
        setState(() => searchKeyword = content);
        searchController.text = content;
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

  @override
  Widget build(BuildContext context) {
    List<String> recentKeywords = ref.watch(recentSearchProvider);
    List<String> autoCompletes = ref.watch(musicAutoCompleteProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                    if (!showRecent)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: IconButton(
                          onPressed: () {
                            context.pop();
                          },
                          icon: const Icon(Icons.arrow_back),
                          iconSize: 32,
                        ),
                      ),
                    if (showRecent) const SizedBox(width: 16.0),
                    Expanded(
                      child: Hero(
                        tag: 'search-bar',
                        child: CustomSearchBar(
                          controller: searchController,
                          autofocus: true,
                          onChanged: (value) {
                            ref
                                .read(musicAutoCompleteProvider.notifier)
                                .keyword = value;
                            setState(() => searchKeyword = value);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (showRecent) ...[
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
                        ...recentKeywords.map(
                          (q) => searchItem(
                            content: q,
                            onRemove: (q) {
                              ref.read(recentSearchProvider.notifier).remove(q);
                            },
                          ),
                        ),
                      ],
                      if (!showRecent)
                        ...autoCompletes.map((q) => searchItem(
                            content: q,
                            onTap: (x) {
                              ref.read(recentSearchProvider.notifier).add(x);
                            })),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
