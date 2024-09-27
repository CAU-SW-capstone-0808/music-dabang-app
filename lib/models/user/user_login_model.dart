import 'package:json_annotation/json_annotation.dart';

part 'user_login_model.g.dart';

@JsonSerializable()
class UserLoginModel {
  final String phone;
  final String password;

  UserLoginModel({
    required this.phone,
    required this.password,
  });

  factory UserLoginModel.fromJson(Map<String, dynamic> json) =>
      _$UserLoginModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserLoginModelToJson(this);
}
