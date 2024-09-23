import 'package:json_annotation/json_annotation.dart';
import 'package:music_dabang/models/music/artist_model.dart';

part 'music_model.g.dart';

@JsonSerializable()
class MusicModel {
  final int id;
  final ArtistModel artist;
  final String title;

  MusicModel({
    required this.id,
    required this.artist,
    required this.title,
  });

  factory MusicModel.fromJson(Map<String, dynamic> json) =>
      _$MusicModelFromJson(json);
}
