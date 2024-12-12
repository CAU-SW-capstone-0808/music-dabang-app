import 'package:json_annotation/json_annotation.dart';

part 'radio_channel_model.g.dart';

@JsonSerializable()
class RadioChannelModel {
  final int id;
  final String name;
  final String description;
  @JsonKey(name: "channel_image_url")
  final String channelImageUrl;
  @JsonKey(name: "subscribers_number")
  final int subscribersNumber;
  @JsonKey(name: "on_live", defaultValue: false)
  final bool onLive;

  const RadioChannelModel({
    required this.id,
    required this.name,
    required this.description,
    required this.channelImageUrl,
    required this.subscribersNumber,
    required this.onLive,
  });

  factory RadioChannelModel.fromJson(Map<String, dynamic> json) =>
      _$RadioChannelModelFromJson(json);
}

@JsonSerializable()
class BroadcastScheduleModel {
  final int id;
  @JsonKey(name: "day_of_week")
  final int dayOfWeek; // bitmap (0:Monday - 6:Sunday)
  final String startTime; // HH:MM
  final String endTime; // HH:MM

  const BroadcastScheduleModel({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });
}
