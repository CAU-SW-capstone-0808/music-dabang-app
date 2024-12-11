import 'package:json_annotation/json_annotation.dart';
import 'package:music_dabang/models/user/user_model.dart';

part 'post_comment_model.g.dart';

@JsonSerializable()
class PostCommentModel {
  final int id;
  final String content;
  final UserModel user;
  final int fandomPostId;
  final int? parentId;
  final List<PostCommentModel> replies;
  final DateTime createdAt;
  final DateTime editedAt;

  const PostCommentModel({
    required this.id,
    required this.content,
    required this.user,
    required this.fandomPostId,
    required this.createdAt,
    required this.editedAt,
    this.parentId,
    required this.replies,
  });

  factory PostCommentModel.fromJson(Map<String, dynamic> json) =>
      _$PostCommentModelFromJson(json);
}

@JsonSerializable()
class PostCommentRequestModel {
  final String content;

  const PostCommentRequestModel({
    required this.content,
  });

  Map<String, dynamic> toJson() => _$PostCommentRequestModelToJson(this);
}
