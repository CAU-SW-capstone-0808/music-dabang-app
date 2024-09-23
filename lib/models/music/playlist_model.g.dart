// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaylistModel _$PlaylistModelFromJson(Map<String, dynamic> json) =>
    PlaylistModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      usedForSystem: json['usedForSystem'] as bool,
      userVisible: json['userVisible'] as bool,
    );

Map<String, dynamic> _$PlaylistModelToJson(PlaylistModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'usedForSystem': instance.usedForSystem,
      'userVisible': instance.userVisible,
    };
