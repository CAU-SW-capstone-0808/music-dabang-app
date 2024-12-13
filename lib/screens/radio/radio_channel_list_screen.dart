import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music_dabang/components/logo_title.dart';
import 'package:music_dabang/models/radio/radio_channel_model.dart';
import 'package:music_dabang/providers/music/music_player_provider.dart';
import 'package:music_dabang/providers/radio/radio_channels_provider.dart';
import 'package:music_dabang/providers/radio/radio_live_broadcasts_provider.dart';
import 'package:music_dabang/screens/radio/components/radio_channel_card.dart';
import 'package:music_dabang/screens/radio/components/radio_live_card.dart';
import 'package:music_dabang/screens/radio/radio_broadcast_live_screen.dart';

class RadioChannelListScreen extends ConsumerStatefulWidget {
  static const routeName = 'radio-channel-list';

  const RadioChannelListScreen({super.key});

  @override
  ConsumerState<RadioChannelListScreen> createState() =>
      _RadioChannelListScreenState();
}

class _RadioChannelListScreenState
    extends ConsumerState<RadioChannelListScreen> {
  late Timer _timer; // per 10 seconds timer

  Widget titleLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> init({bool refresh = false}) async {
    ref.read(radioLiveBroadcastsProvider.notifier).fetch(refresh: refresh);
    ref.read(radioChannelsProvider.notifier).fetch(refresh: refresh);
  }

  @override
  void initState() {
    super.initState();
    init();

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      ref.read(radioLiveBroadcastsProvider.notifier).fetch();
      ref.read(radioChannelsProvider.notifier).fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final liveBroadcasts = ref.watch(radioLiveBroadcastsProvider);
    final radioChannels = ref.watch(radioChannelsProvider);
    final currentPlayingMusic = ref.watch(currentPlayingMusicProvider);
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: RefreshIndicator(
        onRefresh: () async {
          await init(refresh: true);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            width: double.infinity,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 12.0, 0, 0),
                    child: LogoTitle(),
                  ),
                  const SizedBox(height: 16.0),
                  titleLabel("라이브"),
                  const SizedBox(height: 4.0),
                  ...liveBroadcasts.map(
                    (e) {
                      RadioChannelModel? channel = radioChannels.firstWhere(
                        (element) => element.id == e.channelId,
                        orElse: () => const RadioChannelModel(
                          id: 0,
                          name: '',
                          channelImageUrl: '',
                          description: '',
                          onLive: false,
                          subscribersNumber: 0,
                        ),
                      );
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 6.0,
                        ),
                        child: RadioLiveCard(
                          title: e.title,
                          channelTitle: channel.name,
                          channelImage: channel.channelImageUrl,
                          listenerCount: e.listenerCount,
                          status: e.status.name,
                          startedAt: e.startedAt,
                          onPressed: () {
                            context.goNamed(
                              RadioBroadcastLiveScreen.routeName,
                              queryParameters: {
                                'broadcastId': e.id.toString(),
                                'channelId': e.channelId.toString(),
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
                  titleLabel("추천 채널"),
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 280,
                      viewportFraction: 0.8,
                      initialPage: 0,
                      enableInfiniteScroll: true,
                      reverse: false,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 8),
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      scrollDirection: Axis.horizontal,
                      enlargeFactor: 0.2,
                    ),
                    items: radioChannels
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RadioChannelCard(
                              channelTitle: e.name,
                              channelImageUrl: e.channelImageUrl,
                              description: e.description,
                              onLive: e.onLive,
                              subscriberCount: e.subscribersNumber,
                              onPressed: () {
                                for (final broadcast in liveBroadcasts) {
                                  if (broadcast.channelId == e.id) {
                                    context.goNamed(
                                      RadioBroadcastLiveScreen.routeName,
                                      queryParameters: {
                                        'broadcastId': broadcast.id.toString(),
                                        'channelId':
                                            broadcast.channelId.toString(),
                                      },
                                    );
                                    return;
                                  }
                                }
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  if (currentPlayingMusic != null) const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
