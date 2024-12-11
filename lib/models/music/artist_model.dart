import 'package:json_annotation/json_annotation.dart';

part 'artist_model.g.dart';

@JsonSerializable()
class ArtistModel {
  final int id;
  final String name;
  final String description;
  final String profileImageUrl;

  ArtistModel({
    required this.id,
    required this.name,
    required this.description,
    required this.profileImageUrl,
  });

  factory ArtistModel.fromJson(Map<String, dynamic> json) =>
      _$ArtistModelFromJson(json);
}
