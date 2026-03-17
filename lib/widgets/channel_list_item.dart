import 'package:flutter/material.dart';

import '../constants.dart';
import '../model/channel.dart';

class ChannelListItem extends StatelessWidget {
  const ChannelListItem({
    super.key,
    required this.channel,
    required this.onTap,
    required this.focusNode,
    this.selected = false,
    this.onFocus,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  final Channel channel;
  final VoidCallback onTap;
  final FocusNode focusNode;
  final bool selected;
  final VoidCallback? onFocus;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, child) {
        final hasFocus = focusNode.hasFocus;
        final borderColor = hasFocus
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent;

        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: AppConstants.cardMargin,
            vertical: AppConstants.cardMargin / 2,
          ),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            focusNode: focusNode,
            onTap: onTap,
            onFocusChange: (focused) {
              if (focused && onFocus != null) {
                onFocus!();
              }
            },
            canRequestFocus: true,
            borderRadius: BorderRadius.circular(12),
            focusColor:
                Theme.of(context).colorScheme.primary.withAlpha((0.12 * 255).round()),
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
              selected: selected,
              selectedTileColor:
                  Theme.of(context).colorScheme.primary.withAlpha((0.12 * 255).round()),
              onTap: onTap,
              trailing: IconButton(
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite
                      ? Theme.of(context).colorScheme.secondary
                      : null,
                ),
                onPressed: onFavoriteToggle,
                tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
              ),
            ),
          ),
        );
      },
    );
  }
}