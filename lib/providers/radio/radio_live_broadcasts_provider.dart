import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/models/radio/broadcast_model.dart';
import 'package:music_dabang/repository/radio_repository.dart';

final radioLiveBroadcastsProvider = StateNotifierProvider<
    RadioLiveBroadcastsProvider, List<BroadcastLiveModel>>((ref) {
  final radioRepository = ref.watch(radioRepositoryProvider);
  return RadioLiveBroadcastsProvider(radioRepository: radioRepository);
});

class RadioLiveBroadcastsProvider
    extends StateNotifier<List<BroadcastLiveModel>> {
  final RadioRepository radioRepository;

  RadioLiveBroadcastsProvider({
    required this.radioRepository,
  }) : super([]) {
    fetch();
  }

  Future<List<BroadcastLiveModel>> fetch({int? channelId}) async {
    return state =
        await radioRepository.getLiveBroadcasts(channelId: channelId);
  }
}
