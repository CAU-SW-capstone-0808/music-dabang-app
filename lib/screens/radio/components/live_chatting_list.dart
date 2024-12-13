import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/common/utils.dart';
import 'package:music_dabang/models/radio/radio_channel_model.dart';
import 'package:music_dabang/models/user/user_model.dart';
import 'package:music_dabang/providers/radio/radio_channels_provider.dart';
import 'package:music_dabang/providers/radio/radio_live_broadcast_chats_provider.dart';
import 'package:music_dabang/providers/user/other_user_provider.dart';
import 'package:music_dabang/providers/user/user_provider.dart';

class LiveChattingList extends ConsumerStatefulWidget {
  final int broadcastId;
  final int channelId;

  const LiveChattingList({
    super.key,
    required this.broadcastId,
    required this.channelId,
  });

  @override
  ConsumerState<LiveChattingList> createState() => _LiveChattingListState();
}

class _LiveChattingListState extends ConsumerState<LiveChattingList> {
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final chats =
        ref.watch(radioLiveBroadcastChatsProvider(widget.broadcastId));
    final me = ref.watch(userProvider);
    final channels = ref.watch(radioChannelsProvider);
    RadioChannelModel? channel;
    for (final c in channels) {
      if (c.id == widget.channelId) {
        channel = c;
        break;
      }
    }

    ref.listen(radioLiveBroadcastChatsProvider(widget.broadcastId),
        (prev, next) async {
      if ((prev?.length ?? 0) < next.length &&
          scrollController.position.pixels < 400) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 16.0,
      ),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        bool isMe = false;
        bool isChannel = chat.userId == "0";
        if (me is UserModel) {
          isMe = chat.userId == me.id.toString();
        }
        UserModel? otherUser;
        if (!isMe && !isChannel) {
          otherUser = ref.watch(otherUserProvider(chat.userId));
        }
        // set userName
        String userName = "";
        if (isChannel) {
          userName = channel?.name ?? '';
        } else {
          userName = isMe ? '나' : (otherUser?.nickname ?? '');
        }
        // set imageUrl
        String imageUrl = "";
        if (isChannel) {
          imageUrl = channel?.channelImageUrl ?? '';
        } else {
          imageUrl = (isMe && me is UserModel)
              ? (me.profileImageUrl ?? '')
              : (otherUser?.profileImageUrl ?? '');
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe)
                imageUrl.isEmpty
                    ? const SizedBox(
                        width: 32.0,
                        height: 32.0,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                        ),
                      ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isMe)
                          Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: Text(
                              userName,
                              style: const TextStyle(fontSize: 14.0),
                            ),
                          ),
                        Text(
                          AidolUtils.timeKorean(chat.timestamp),
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: ColorTable.textGrey,
                          ),
                        ),
                        if (isMe)
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text(
                              userName,
                              style: const TextStyle(fontSize: 14.0),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(isMe ? 12.0 : 0),
                          topRight: const Radius.circular(12.0),
                          bottomRight: Radius.circular(isMe ? 0 : 12.0),
                          bottomLeft: const Radius.circular(12.0),
                        ),
                        color: Colors.white,
                        border: Border.all(
                          color: ColorTable.stroke,
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        chat.message,
                        style: const TextStyle(fontSize: 14.0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class UserProfileImage extends ConsumerWidget {
  const UserProfileImage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Placeholder();
  }
}
