import 'package:flutter/material.dart';

import '../constants.dart';
import '../model/channel.dart';

class ChannelListItem extends StatelessWidget {
  const ChannelListItem({
    super.key,
    required this.channel,
    required this.onTap,
  });

  final Channel channel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.cardMargin,
        vertical: AppConstants.cardMargin / 2,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppConstants.cardPadding),
        leading: Image.network(
          channel.logoUrl,
          width: AppConstants.channelImageSize,
          height: AppConstants.channelImageSize,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              AppConstants.defaultLogoUrl,
              width: AppConstants.channelImageSize,
              height: AppConstants.channelImageSize,
              fit: BoxFit.contain,
            );
          },
        ),
        title: Text(
          channel.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Stream URL: ${channel.streamUrl}',
          style: const TextStyle(fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: onTap,
      ),
    );
  }
}