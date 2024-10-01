import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/common/firebase_logger.dart';

class ToTopButton extends ConsumerWidget {
  final ScrollController scrollController;

  const ToTopButton({
    required this.scrollController,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 80,
      height: 80,
      child: FloatingActionButton(
        onPressed: () async {
          if (scrollController.offset > 3000) {
            scrollController.jumpTo(0);
          } else {
            scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 1500),
              curve: Curves.fastOutSlowIn,
            );
          }
          FirebaseLogger.touchToTopButton();
        },
        backgroundColor: Colors.white,
        elevation: 0,
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: const BorderSide(color: Color(0xFFBEBEBE)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            RotatedBox(
              quarterTurns: 1,
              child: Icon(
                CupertinoIcons.back,
                size: 48.0,
                color: Colors.black,
              ),
            ),
            Text(
              '맨 위로',
              style: TextStyle(
                fontSize: 18.0,
                height: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
