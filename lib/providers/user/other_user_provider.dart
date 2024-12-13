import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/models/user/user_model.dart';
import 'package:music_dabang/repository/user_repository.dart';

final otherUserProvider =
    StateNotifierProviderFamily<OtherUserProvider, UserModel?, String>(
  (ref, userId) {
    return OtherUserProvider(
      userId: userId,
      userRepository: ref.watch(userRepositoryProvider),
    );
  },
);

class OtherUserProvider extends StateNotifier<UserModel?> {
  final String userId;
  final UserRepository userRepository;

  OtherUserProvider({
    required this.userId,
    required this.userRepository,
  }) : super(null) {
    fetch();
  }

  Future<UserModel> fetch() async {
    return state = await userRepository.getOther(userId: userId);
  }
}
