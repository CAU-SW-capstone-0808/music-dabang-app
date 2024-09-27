import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 플레이리스트를 보여주는 화면. 라우터에 정의되지 않음.
class CurrentPlaylistPanel extends ConsumerStatefulWidget {
  const CurrentPlaylistPanel({super.key});

  @override
  ConsumerState<CurrentPlaylistPanel> createState() =>
      _CurrentPlaylistPanelState();
}

class _CurrentPlaylistPanelState extends ConsumerState<CurrentPlaylistPanel> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
