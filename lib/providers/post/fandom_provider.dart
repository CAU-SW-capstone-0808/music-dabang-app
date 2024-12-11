import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedArtistIdProvider =
    StateNotifierProvider<SelectedArtistIdStateNotifier, int?>((ref) {
  return SelectedArtistIdStateNotifier();
});

class SelectedArtistIdStateNotifier extends StateNotifier<int?> {
  SelectedArtistIdStateNotifier() : super(null);

  void select(int artistId) {
    state = artistId;
  }

  void clear() {
    state = null;
  }
}
