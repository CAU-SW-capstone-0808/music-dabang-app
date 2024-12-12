import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/models/radio/radio_channel_model.dart';
import 'package:music_dabang/repository/radio_repository.dart';

final radioChannelsProvider =
    StateNotifierProvider<RadioChannelsProvider, List<RadioChannelModel>>(
        (ref) {
  final radioRepository = ref.watch(radioRepositoryProvider);
  return RadioChannelsProvider(radioRepository: radioRepository);
});

class RadioChannelsProvider extends StateNotifier<List<RadioChannelModel>> {
  final RadioRepository radioRepository;

  RadioChannelsProvider({
    required this.radioRepository,
  }) : super([]) {
    fetch();
  }

  Future<List<RadioChannelModel>> fetch() async {
    return state = await radioRepository.getChannels();
  }
}
