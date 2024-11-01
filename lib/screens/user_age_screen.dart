import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/common/firebase_logger.dart';
import 'package:music_dabang/components/wide_button.dart';
import 'package:music_dabang/models/user/user_age.dart';
import 'package:music_dabang/providers/user/user_provider.dart';

class UserAgeScreen extends ConsumerStatefulWidget {
  static const routeName = 'user-age';

  const UserAgeScreen({super.key});

  @override
  ConsumerState<UserAgeScreen> createState() => _UserAgeScreenState();
}

class _UserAgeScreenState extends ConsumerState<UserAgeScreen> {
  UserAge? selectedAge;
  bool inRequest = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 20.0,
          ),
          child: Column(
            children: [
              const Text(
                "연령대를 선택해주세요!",
                style: TextStyle(
                  fontSize: 24.0,
                  height: 1.25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: UserAge.values
                      .map(
                        (e) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setState(() => selectedAge = e);
                              },
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: selectedAge == e
                                      ? ColorTable.kPrimaryColor
                                      : Colors.black12,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    e.displayName,
                                    style: TextStyle(
                                      fontSize: 24.0,
                                      height: 1.25,
                                      color: selectedAge == e
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 12.0),
              WideButton(
                height: 60.0,
                onPressed: (selectedAge != null && !inRequest)
                    ? () async {
                        setState(() => inRequest = true);
                        try {
                          await ref
                              .read(userProvider.notifier)
                              .updateUserAge(selectedAge!);
                          FirebaseLogger.setUserAge(selectedAge);
                        } finally {
                          setState(() => inRequest = false);
                        }
                      }
                    : null,
                child: const Text(
                  "확인",
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
