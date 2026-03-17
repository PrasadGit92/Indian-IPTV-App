import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../model/channel.dart';
import '../repositories/channels_repository.dart';
import '../services/m3u_parser.dart';

class ChannelsProvider extends ChangeNotifier {
  static const _favoritesKey = 'favorites';

  ChannelsProvider({
    ChannelsRepository? repository,
    String? initialUrl,
  })  : _repository = repository ?? ChannelsRepository(M3uParser()),
        _sourceUrl = initialUrl ?? AppConstants.defaultM3uUrl;

  final ChannelsRepository _repository;
  String _sourceUrl;
  final List<Channel> _channels = [];
  final List<Channel> _filteredChannels = [];
  final Set<String> _favoriteUrls = {};

  String get sourceUrl => _sourceUrl;
  List<Channel> get channels => _channels;
  List<Channel> get filteredChannels => _filteredChannels;
  List<String> get favoriteUrls => _favoriteUrls.toList();

  bool isFavorite(Channel channel) => _favoriteUrls.contains(channel.streamUrl);

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_favoritesKey);
    if (stored != null) {
      _favoriteUrls
        ..clear()
        ..addAll(stored);
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(Channel channel) async {
    if (_favoriteUrls.contains(channel.streamUrl)) {
      _favoriteUrls.remove(channel.streamUrl);
    } else {
      _favoriteUrls.add(channel.streamUrl);
    }

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, _favoriteUrls.toList());
  }

  Future<void> loadChannels([String? url]) async {
    if (url != null) {
      _sourceUrl = url;
    }
    final data = await _repository.fetchChannels(_sourceUrl);
    _channels
      ..clear()
      ..addAll(data);
    _filteredChannels
      ..clear()
      ..addAll(data);
    notifyListeners();
  }

  void filterChannels(String query) {
    if (query.isEmpty) {
      _filteredChannels
        ..clear()
        ..addAll(_channels);
    } else {
      _filteredChannels
        ..clear()
        ..addAll(
          _channels.where(
            (channel) => channel.name.toLowerCase().contains(query.toLowerCase()),
          ),
        );
    }
    notifyListeners();
  }
}
