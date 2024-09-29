// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MusicModel _$MusicModelFromJson(Map<String, dynamic> json) => MusicModel(
      id: (json['id'] as num).toInt(),
      artist: ArtistModel.fromJson(json['artist'] as Map<String, dynamic>),
      title: json['title'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      musicContentUrl: json['musicContentUrl'] as String,
      videoContentUrl: json['videoContentUrl'] as String?,
      musicContentType:
          $enumDecode(_$MusicContentTypeEnumMap, json['musicContentType']),
    );

Map<String, dynamic> _$MusicModelToJson(MusicModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'artist': instance.artist,
      'title': instance.title,
      'thumbnailUrl': instance.thumbnailUrl,
      'musicContentUrl': instance.musicContentUrl,
      'videoContentUrl': instance.videoContentUrl,
      'musicContentType': _$MusicContentTypeEnumMap[instance.musicContentType]!,
    };

const _$MusicContentTypeEnumMap = {
  MusicContentType.live: 'live',
  MusicContentType.music: 'music',
};
