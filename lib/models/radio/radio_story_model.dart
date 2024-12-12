import 'package:json_annotation/json_annotation.dart';

part 'radio_story_model.g.dart';

@JsonSerializable()
class RadioStoryModel {
  final int id;
  @JsonKey(name: "user_id")
  final String userId;
  final String title;
  final String content;
  final DateTime timestamp;

  const RadioStoryModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.timestamp,
  });

  factory RadioStoryModel.fromJson(Map<String, dynamic> json) =>
      _$RadioStoryModelFromJson(json);
}

@JsonSerializable()
class RadioStoryRequestModel {
  final String title;
  final String content;

  const RadioStoryRequestModel({
    required this.title,
    required this.content,
  });

  Map<String, dynamic> toJson() => _$RadioStoryRequestModelToJson(this);
}
