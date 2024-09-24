import 'package:json_annotation/json_annotation.dart';

part 'page_response_model.g.dart';

@JsonSerializable()
class PageResponseModel {
  final List<Map<String, dynamic>> data;
  final String? cursor;

  const PageResponseModel({
    required this.data,
    required this.cursor,
  });

  factory PageResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PageResponseModelFromJson(json);

  List<T> getData<T>(T Function(Map<String, dynamic>) fromJsonCbk) {
    return data.map(fromJsonCbk).toList();
  }
}
