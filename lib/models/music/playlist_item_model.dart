import 'package:json_annotation/json_annotation.dart';
import 'package:music_dabang/models/music/music_model.dart';

part 'playlist_item_model.g.dart';

@JsonSerializable()
class PlaylistItemModel {
  final int id;
  final MusicModel musicContent;
  final int order;

  PlaylistItemModel({
    required this.id,
    required this.musicContent,
    required this.order,
  });

  factory PlaylistItemModel.fromJson(Map<String, dynamic> json) =>
      _$PlaylistItemModelFromJson(json);

  PlaylistItemModel copyWith({
    int? id,
    MusicModel? musicContent,
    int? order,
  }) {
    return PlaylistItemModel(
      id: id ?? this.id,
      musicContent: musicContent ?? this.musicContent,
      order: order ?? this.order,
    );
  }
}
