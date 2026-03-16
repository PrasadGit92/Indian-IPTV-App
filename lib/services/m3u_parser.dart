import '../model/channel.dart';
import '../constants.dart';

class M3uParser {
  List<Channel> parse(String content) {
    final lines = content.split('\n');
    final channels = <Channel>[];
    String? name;
    String logoUrl = AppConstants.defaultLogoUrl;
    String? streamUrl;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      if (trimmed.startsWith('#EXTINF:')) {
        name = _extractChannelName(trimmed);
        logoUrl = _extractLogoUrl(trimmed) ?? AppConstants.defaultLogoUrl;
      } else if (trimmed.startsWith('http')) {
        streamUrl = trimmed;
        if (name != null) {
          channels.add(
            Channel(
              name: name,
              logoUrl: logoUrl,
              streamUrl: streamUrl,
            ),
          );
        }
        // Reset
        name = null;
        logoUrl = AppConstants.defaultLogoUrl;
        streamUrl = null;
      }
    }
    return channels;
  }

  String? _extractChannelName(String line) {
    final parts = line.split(',');
    return parts.isNotEmpty ? parts.last : null;
  }

  String? _extractLogoUrl(String line) {
    final parts = line.split('"');
    if (parts.length > 1 && _isValidUrl(parts[1])) {
      return parts[1];
    } else if (parts.length > 5 && _isValidUrl(parts[5])) {
      return parts[5];
    }
    return null;
  }

  bool _isValidUrl(String url) => url.startsWith('http');
}