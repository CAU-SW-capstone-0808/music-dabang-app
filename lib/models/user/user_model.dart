import 'package:json_annotation/json_annotation.dart';
import 'package:music_dabang/models/user/user_age.dart';

part 'user_model.g.dart';

abstract class UserModelBase {}

/// 로딩 상태
class UserModelLoading extends UserModelBase {}

/// 비로그인 상태
class UserModelNone extends UserModelBase {}

/// 오류
class UserModelError extends UserModelBase {
  final String message;

  UserModelError(this.message);
}

/// 로그인 상태
@JsonSerializable()
class UserModel extends UserModelBase {
  final int id;
  final String nickname;
  final String? profileImageUrl;
  @JsonKey(defaultValue: null)
  final UserAge? userAge;

  UserModel({
    required this.id,
    required this.nickname,
    required this.profileImageUrl,
    this.userAge,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
