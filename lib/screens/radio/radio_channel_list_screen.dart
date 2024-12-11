import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/screens/radio/components/radio_channel_card.dart';
import 'package:music_dabang/screens/radio/components/radio_live_card.dart';

class RadioChannelListScreen extends StatefulWidget {
  static const routeName = 'radio-channel-list';

  const RadioChannelListScreen({super.key});

  @override
  State<RadioChannelListScreen> createState() => _RadioChannelListScreenState();
}

class _RadioChannelListScreenState extends State<RadioChannelListScreen> {
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

  @override
  Widget build(BuildContext context) {
    Widget radioChannelCard = Padding(
      padding: const EdgeInsets.all(8.0),
      child: RadioChannelCard(
        channelTitle: "희망 믿음 소망",
        channelImageUrl:
            "https://thumbs.dreamstime.com/b/black-radio-logo-radio-icon-white-black-radio-logo-radio-icon-131472109.jpg",
        description: "채널 희망 믿음 소망은 각박한 현대 사회에서 어쩌구 저쩌구",
        onLive: true,
        subscriberCount: 1200,
      ),
    );
    Widget radioLiveCard = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 6.0,
      ),
      child: RadioLiveCard(
        title: "정오의 희망곡",
        channelTitle: "희망 믿음 소망",
        channelImage:
            "https://thumbs.dreamstime.com/b/black-radio-logo-radio-icon-white-black-radio-logo-radio-icon-131472109.jpg",
        listenerCount: 10,
        status: "status",
        elapsedMinutes: 100,
      ),
    );
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              titleLabel("진행 중인 방송"),
              const SizedBox(height: 4.0),
              radioLiveCard,
              radioLiveCard,
              radioLiveCard,
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
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                  enlargeFactor: 0.2,
                ),
                items: [
                  radioChannelCard,
                  radioChannelCard,
                  radioChannelCard,
                  radioChannelCard,
                  radioChannelCard,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
