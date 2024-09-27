import 'package:json_annotation/json_annotation.dart';
import 'package:music_dabang/models/user/gender.dart';

part 'user_join_model.g.dart';

@JsonSerializable()
class UserJoinModel {
  final String phone; // 01012345678
  final String nickname; // 홍길동
  final String password; // 1234
  final Gender gender; // m, f
  final String birth; // 010312

  UserJoinModel({
    required this.phone,
    required this.nickname,
    required this.password,
    required this.gender,
    required this.birth,
  });

  factory UserJoinModel.fromJson(Map<String, dynamic> json) =>
      _$UserJoinModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserJoinModelToJson(this);
}
