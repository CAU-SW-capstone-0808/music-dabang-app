import 'package:json_annotation/json_annotation.dart';

part 'playlist_model.g.dart';

@JsonSerializable()
class PlaylistModel {
  int id;
  String name;
  bool usedForSystem;
  bool userVisible;

  PlaylistModel({
    required this.id,
    required this.name,
    required this.usedForSystem,
    required this.userVisible,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) =>
      _$PlaylistModelFromJson(json);
}
