import 'package:flutter/material.dart';
import 'package:music_dabang/common/colors.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final String userName;
  final String? userProfileImageUrl;
  final void Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.userName,
    this.userProfileImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      items: <BottomNavigationBarItem>[
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: '홈',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.folder_open),
          label: '내음악',
        ),
        BottomNavigationBarItem(
          icon: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: userProfileImageUrl != null
                ? SizedBox(
                    width: 32,
                    height: 32,
                    child: Image.network(userProfileImageUrl!),
                  )
                : const Icon(Icons.person),
          ),
          label: userName,
        ),
      ],
      selectedItemColor: ColorTable.purple,
      unselectedItemColor: ColorTable.bottomNavBlack,
      onTap: onTap,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      iconSize: 32.0,
      selectedLabelStyle: const TextStyle(
        fontSize: 18.0,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 18.0,
      ),
    );
  }
}
