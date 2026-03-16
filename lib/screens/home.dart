import 'dart:async';

import 'package:flutter/material.dart';
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
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ChannelsProvider>();
    _urlController.text = provider.sourceUrl;
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    final provider = context.read<ChannelsProvider>();
    try {
      await provider.loadChannels(_urlController.text);
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
        }
      },
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        Expanded(
          child: Consumer<ChannelsProvider>(
            builder: (context, provider, child) {
              if (provider.channels.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView.builder(
                itemCount: provider.filteredChannels.length,
                itemBuilder: (context, index) {
                  final channel = provider.filteredChannels[index];
                  return ChannelListItem(
                    channel: channel,
                    onTap: () => _navigateToPlayer(channel),
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
              ).animate().fadeIn(duration: AppConstants.animationDuration);
            },
          ),
        ),
      ],
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
