import 'package:json_annotation/json_annotation.dart';
import 'package:music_dabang/models/radio/radio_channel_model.dart';

part 'broadcast_model.g.dart';

enum BroadcastStatus {
  ready,
  live,
  ended;
}

@JsonSerializable()
class BroadcastModel {
  final int id;
  final RadioChannelModel channel;
  final BroadcastStatus status;

  const BroadcastModel({
    required this.id,
    required this.channel,
    required this.status,
  });

  factory BroadcastModel.fromJson(Map<String, dynamic> json) =>
      _$BroadcastModelFromJson(json);
}

@JsonSerializable()
class BroadcastLiveModel {
  final int id;
  final String title;
  @JsonKey(name: "channel_id")
  final int channelId;
  @JsonKey(name: "listener_count")
  final int listenerCount;
  final BroadcastStatus status;
  @JsonKey(name: "started_at")
  final DateTime startedAt;

  const BroadcastLiveModel({
    required this.id,
    required this.title,
    required this.channelId,
    required this.listenerCount,
    required this.status,
    required this.startedAt,
  });

  factory BroadcastLiveModel.fromJson(Map<String, dynamic> json) =>
      _$BroadcastLiveModelFromJson(json);

  Map<String, dynamic> toJson() => _$BroadcastLiveModelToJson(this);
}
