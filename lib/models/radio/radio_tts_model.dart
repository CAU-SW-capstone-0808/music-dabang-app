import 'package:json_annotation/json_annotation.dart';

part 'radio_tts_model.g.dart';

@JsonSerializable()
class RadioTTSModel {
  final int id;
  @JsonKey(name: "broadcast_id")
  final int broadcastId;
  final String content;
  @JsonKey(name: "tts_content_url")
  final String ttsContentUrl;
  @JsonKey(name: "duration_ms")
  final int durationMs;
  final DateTime timestamp;

  const RadioTTSModel({
    required this.id,
    required this.broadcastId,
    required this.content,
    required this.ttsContentUrl,
    required this.durationMs,
    required this.timestamp,
  });

  factory RadioTTSModel.fromJson(Map<String, dynamic> json) =>
      _$RadioTTSModelFromJson(json);
}
