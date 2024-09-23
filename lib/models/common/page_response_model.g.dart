// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageResponseModel _$PageResponseModelFromJson(Map<String, dynamic> json) =>
    PageResponseModel(
      data: (json['data'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      sortBy: json['sortBy'] as String?,
      sortOrder: json['sortOrder'] as String,
      cursor: json['cursor'] as String?,
    );

Map<String, dynamic> _$PageResponseModelToJson(PageResponseModel instance) =>
    <String, dynamic>{
      'data': instance.data,
      'sortBy': instance.sortBy,
      'sortOrder': instance.sortOrder,
      'cursor': instance.cursor,
    };
