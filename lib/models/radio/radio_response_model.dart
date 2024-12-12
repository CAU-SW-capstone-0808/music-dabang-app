import 'package:json_annotation/json_annotation.dart';
import 'package:music_dabang/models/radio/radio_music_model.dart';
import 'package:music_dabang/models/radio/radio_tts_model.dart';

part 'radio_response_model.g.dart';

@JsonSerializable()
class RadioInitResponseModel {
  final String status;
  final String message;
  @JsonKey(name: "listeners_count")
  final int listenersCount;
  @JsonKey(name: "playing_music")
  final RadioMusicModel? playingMusic;
  @JsonKey(name: "playing_tts")
  final RadioTTSModel? playingTTS;
  @JsonKey(name: "will_play_music")
  final RadioWillPlayMusicModel? willPlayMusic;

  const RadioInitResponseModel({
    required this.status,
    required this.message,
    required this.listenersCount,
    required this.playingMusic,
    required this.playingTTS,
    required this.willPlayMusic,
  });

  factory RadioInitResponseModel.fromJson(Map<String, dynamic> json) =>
      _$RadioInitResponseModelFromJson(json);
}
