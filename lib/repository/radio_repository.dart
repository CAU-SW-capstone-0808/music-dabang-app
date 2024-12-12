import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/models/radio/broadcast_model.dart';
import 'package:music_dabang/models/radio/radio_channel_model.dart';
import 'package:music_dabang/providers/dio_provider.dart';
import 'package:retrofit/retrofit.dart';

part 'radio_repository.g.dart';

final radioRepositoryProvider = Provider<RadioRepository>((ref) {
  return RadioRepository(
    ref.watch(dioProvider),
    baseUrl: 'https://mdradio.jdn.kr',
  );
});

@RestApi()
abstract class RadioRepository {
  factory RadioRepository(Dio dio, {String baseUrl}) = _RadioRepository;

  @GET("/channels")
  Future<List<RadioChannelModel>> getChannels();

  @GET("/channels/broadcasts")
  Future<List<BroadcastModel>> getBroadcasts({
    @Query("channel_id") int? channelId,
  });

  @GET("/channels/broadcasts/live")
  Future<List<BroadcastLiveModel>> getLiveBroadcasts({
    @Query("channel_id") int? channelId,
  });

  @GET("/broadcasts/{broadcastId}")
  Future<BroadcastModel> getBroadcastById({
    @Path("broadcastId") required int broadcastId,
  });
}
