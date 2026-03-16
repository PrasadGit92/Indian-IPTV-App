import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import '../constants.dart';
import '../model/channel.dart';

class Player extends StatefulWidget {
  const Player({
    super.key,
    required this.channel,
  });

  final Channel channel;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  late final VideoPlayerController _videoPlayerController;
  late final ChewieController _chewieController;
  bool _isLoading = true;
  bool _channelNotFound = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.channel.streamUrl),
    );

    try {
      await _videoPlayerController.initialize();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _channelNotFound = true;
        });
      }
      return;
    }

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoInitialize: true,
      isLive: true,
      autoPlay: true,
      aspectRatio: 16 / 9,
      showOptions: false,
      customControls: const MaterialDesktopControls(
        showPlayButton: false,
      ),
    );

    // Enable wake lock when video starts playing
    _videoPlayerController.addListener(_onVideoStateChanged);
  }

  void _onVideoStateChanged() {
    final isPlaying = _videoPlayerController.value.isPlaying;
    if (isPlaying) {
      Wakelock.enable();
    } else {
      Wakelock.disable();
    }
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(_onVideoStateChanged);
    _videoPlayerController.dispose();
    _chewieController.dispose();
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channel.name),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _channelNotFound
                ? const Text(
                    AppConstants.channelNotAvailable,
                    style: TextStyle(fontSize: 24.0),
                  )
                : SizedBox(
                    height: MediaQuery.of(context).size.height * AppConstants.playerHeightFactor,
                    child: Chewie(
                      controller: _chewieController,
                    ),
                  ),
      ).animate().fadeIn(duration: AppConstants.animationDuration),
    );
  }
}
