import 'package:json_annotation/json_annotation.dart';

part 'radio_music_model.g.dart';

@JsonSerializable()
class RadioMusicModel {
  final int id;
  final String title;
  final String artist;
  @JsonKey(name: "album_image_url")
  final String albumImageUrl;
  @JsonKey(name: "content_url")
  final String contentUrl;
  final DateTime timestamp;

  const RadioMusicModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumImageUrl,
    required this.contentUrl,
    required this.timestamp,
  });

  factory RadioMusicModel.fromJson(Map<String, dynamic> json) =>
      _$RadioMusicModelFromJson(json);

  Map<String, dynamic> toJson() => _$RadioMusicModelToJson(this);
}

@JsonSerializable()
class RadioWillPlayMusicModel {
  final String title;
  final String artist;
  @JsonKey(name: "album_image_url")
  final String albumImageUrl;
  @JsonKey(name: "content_url")
  final String contentUrl;
  final DateTime timestamp;

  const RadioWillPlayMusicModel({
    required this.title,
    required this.artist,
    required this.albumImageUrl,
    required this.contentUrl,
    required this.timestamp,
  });

  factory RadioWillPlayMusicModel.fromJson(Map<String, dynamic> json) =>
      _$RadioWillPlayMusicModelFromJson(json);

  RadioMusicModel get toRadioMusicModel => RadioMusicModel(
        id: 0,
        title: title,
        artist: artist,
        albumImageUrl: albumImageUrl,
        contentUrl: contentUrl,
        timestamp: timestamp,
      );
}
