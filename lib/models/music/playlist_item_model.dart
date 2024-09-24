import 'package:json_annotation/json_annotation.dart';
import 'package:music_dabang/models/music/music_model.dart';

part 'playlist_item_model.g.dart';

@JsonSerializable()
class PlaylistItemModel {
  final int id;
  final MusicModel musicContent;

  PlaylistItemModel({
    required this.id,
    required this.musicContent,
  });

  factory PlaylistItemModel.fromJson(Map<String, dynamic> json) =>
      _$PlaylistItemModelFromJson(json);
}
