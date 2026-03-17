import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../model/channel.dart';
import '../provider/channels_provider.dart';
import '../widgets/channel_list_item.dart';
import 'player.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _keyboardFocusNode = FocusNode(debugLabel: 'home_keyboard');
  final ScrollController _scrollController = ScrollController();
  final List<FocusNode> _channelFocusNodes = [];

  VideoPlayerController? _previewVideoController;
  ChewieController? _previewChewieController;
  Channel? _previewChannel;
  bool _isPreviewLoading = false;
  String? _previewError;

  bool _showFavorites = false;
  Timer? _debounceTimer;
  Timer? _digitTimer;
  String _digitBuffer = '';
  int _selectedIndex = 0;
  DateTime? _lastBackPressed;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ChannelsProvider>();
    _urlController.text = provider.sourceUrl;
    provider.loadFavorites();
    _loadChannels();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _digitTimer?.cancel();
    _searchController.dispose();
    _urlController.dispose();
    _keyboardFocusNode.dispose();
    _scrollController.dispose();
    for (final node in _channelFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _loadChannels() async {
    final provider = context.read<ChannelsProvider>();
    try {
      await provider.loadChannels(_urlController.text);
      _selectedIndex = 0;
      _digitBuffer = '';
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppConstants.errorMessage)),
        );
      }
    }
  }

  void _filterChannels(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      () {
        if (mounted) {
          context.read<ChannelsProvider>().filterChannels(query);
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
    );
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.goBack || key == LogicalKeyboardKey.escape) {
      _handleBack();
      return;
    }

    if (_isDigitKey(key)) {
      _appendDigitKey(key);
    }
  }

  bool _isDigitKey(LogicalKeyboardKey key) {
    return (key.keyId >= LogicalKeyboardKey.digit0.keyId &&
            key.keyId <= LogicalKeyboardKey.digit9.keyId) ||
        (key.keyId >= LogicalKeyboardKey.numpad0.keyId &&
            key.keyId <= LogicalKeyboardKey.numpad9.keyId);
  }

  int _digitValue(LogicalKeyboardKey key) {
    if (key.keyId >= LogicalKeyboardKey.digit0.keyId &&
        key.keyId <= LogicalKeyboardKey.digit9.keyId) {
      return key.keyId - LogicalKeyboardKey.digit0.keyId;
    }
    return key.keyId - LogicalKeyboardKey.numpad0.keyId;
  }

  void _appendDigitKey(LogicalKeyboardKey key) {
    _digitTimer?.cancel();
    _digitBuffer += _digitValue(key).toString();
    _digitTimer = Timer(const Duration(seconds: 2), () {
      final number = int.tryParse(_digitBuffer);
      _digitBuffer = '';
      if (number == null) return;
      final provider = context.read<ChannelsProvider>();
      _jumpToChannelNumber(number, provider.filteredChannels.length);
    });
  }

  void _jumpToChannelNumber(int number, int maxChannels) {
    if (number < 1 || number > maxChannels) return;
    final index = number - 1;
    setState(() {
      _selectedIndex = index;
    });

    if (index < _channelFocusNodes.length) {
      _channelFocusNodes[index].requestFocus();
    }

    _scrollController.animateTo(
      index * 120.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text('Jumped to channel $number'),
      ),
    );
  }

  void _handleBack() {
    final now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Press back again to exit')),
      );
      return;
    }
    SystemNavigator.pop();
  }

  FocusNode _getChannelFocusNode(int index) {
    while (_channelFocusNodes.length <= index) {
      _channelFocusNodes.add(FocusNode(debugLabel: 'channel_$index'));
    }
    return _channelFocusNodes[index];
  }

  Widget _buildChannelPreview(Channel? channel) {
    if (channel == null) {
      return const Center(
        child: Text(
          'Select a channel to preview',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppConstants.cardMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    channel.logoUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(AppConstants.defaultLogoUrl);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  channel.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    channel.streamUrl,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () => _navigateToPlayer(channel),
            icon: const Icon(Icons.play_arrow),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Text('Play'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: FocusTraversalGroup(
        policy: ReadingOrderTraversalPolicy(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppConstants.cardMargin),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _urlController,
                          decoration: const InputDecoration(
                            labelText: AppConstants.sourceUrlLabel,
                            hintText: AppConstants.sourceUrlHint,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.cardMargin),
                      FilledButton(
                        onPressed: _loadChannels,
                        child: const Text(AppConstants.loadButtonText),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppConstants.cardMargin),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterChannels,
                    decoration: const InputDecoration(
                      labelText: AppConstants.searchLabel,
                      hintText: AppConstants.searchHint,
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.cardMargin,
                  ),
                  child: Row(
                    children: [
                      const Text('Favorites'),
                      const Spacer(),
                      Switch(
                        value: _showFavorites,
                        onChanged: (value) {
                          setState(() {
                            _showFavorites = value;
                            _selectedIndex = 0;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Consumer<ChannelsProvider>(
                    builder: (context, provider, child) {
                      if (provider.channels.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final filtered = _showFavorites
                          ? provider.filteredChannels
                              .where(provider.isFavorite)
                              .toList()
                          : provider.filteredChannels;

                      if (_selectedIndex >= filtered.length) {
                        _selectedIndex = filtered.isNotEmpty ? 0 : 0;
                      }

                      final selectedChannel = filtered.isNotEmpty
                          ? filtered[_selectedIndex]
                          : null;

                      final list = ListView.builder(
                        controller: _scrollController,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final channel = filtered[index];
                          return ChannelListItem(
                            channel: channel,
                            focusNode: _getChannelFocusNode(index),
                            selected: index == _selectedIndex,
                            isFavorite: provider.isFavorite(channel),
                            onFavoriteToggle: () {
                              provider.toggleFavorite(channel);
                            },
                            onFocus: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                              _navigateToPlayer(channel);
                            },
                          ).animate(
                            delay: Duration(milliseconds: index * 50),
                          ).fadeIn(
                            duration: AppConstants.animationDuration,
                            curve: AppConstants.animationCurve,
                          ).slideY(
                            begin: 0.2,
                            end: 0,
                            duration: AppConstants.animationDuration,
                            curve: AppConstants.animationCurve,
                          );
                        },
                      ).animate().fadeIn(
                            duration: AppConstants.animationDuration,
                          );

                      if (isWide) {
                        return Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: list,
                            ),
                            const VerticalDivider(width: 1),
                            Expanded(
                              flex: 3,
                              child: _buildChannelPreview(selectedChannel),
                            ),
                          ],
                        );
                      }

                      return list;
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _navigateToPlayer(Channel channel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Player(channel: channel),
      ),
    );
  }
}
