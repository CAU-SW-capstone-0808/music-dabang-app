import 'package:json_annotation/json_annotation.dart';
import 'package:music_dabang/models/post/post_comment_model.dart';
import 'package:music_dabang/models/user/user_model.dart';

part 'post_model.g.dart';

@JsonSerializable()
class PostModel {
  final int id;
  final UserModel user;
  final int artistId;
  final String title;
  final String content;
  final int likes;
  final List<PostCommentModel> comments;
  final DateTime createdAt;
  final DateTime editedAt;

  const PostModel({
    required this.id,
    required this.user,
    required this.artistId,
    required this.title,
    required this.content,
    required this.likes,
    required this.comments,
    required this.createdAt,
    required this.editedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);
}

@JsonSerializable()
class PostRequestModel {
  final String title;
  final String content;

  const PostRequestModel({
    required this.title,
    required this.content,
  });

  Map<String, dynamic> toJson() => _$PostRequestModelToJson(this);
}
