import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/components/custom_search_bar.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = 'search';

  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final searchController = TextEditingController();

  Widget searchItem({
    required String content,
    void Function(String)? onRemove,
  }) {
    return InkWell(
      onTap: () {
        searchController.text = content;
      },
      child: Ink(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        child: Row(
          children: [
            Expanded(
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Hero(
                  tag: 'search-bar',
                  child: CustomSearchBar(
                    controller: searchController,
                    autofocus: true,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    '최근 검색',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              searchItem(
                content: 'content',
                onRemove: (content) {},
              ),
              searchItem(
                content: 'content',
                onRemove: (content) {},
              ),
              searchItem(
                content: 'content',
                onRemove: (content) {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
