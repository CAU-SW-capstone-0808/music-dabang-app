import 'package:json_annotation/json_annotation.dart';

part 'radio_chat_model.g.dart';

@JsonSerializable()
class RadioChatModel {
  final int id;
  final String message;
  @JsonKey(name: "user_id")
  final String userId;
  final DateTime timestamp;

  const RadioChatModel({
    required this.id,
    required this.message,
    required this.userId,
    required this.timestamp,
  });

  factory RadioChatModel.fromJson(Map<String, dynamic> json) =>
      _$RadioChatModelFromJson(json);
}

@JsonSerializable()
class RadioChatRequestModel {
  final String message;

  const RadioChatRequestModel({
    required this.message,
  });

  Map<String, dynamic> toJson() => _$RadioChatRequestModelToJson(this);
}
