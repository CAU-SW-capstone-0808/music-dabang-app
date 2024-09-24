import 'package:json_annotation/json_annotation.dart';
import 'package:music_dabang/models/music/artist_model.dart';

part 'music_model.g.dart';

@JsonSerializable()
class MusicModel {
  final int id;
  final ArtistModel artist;
  final String title;
  final String thumbnailUrl;
  final String musicContentUrl;
  final String videoContentUrl;

  MusicModel({
    required this.id,
    required this.artist,
    required this.title,
    required this.thumbnailUrl,
    required this.musicContentUrl,
    required this.videoContentUrl,
  });

  factory MusicModel.fromJson(Map<String, dynamic> json) =>
      _$MusicModelFromJson(json);
}
