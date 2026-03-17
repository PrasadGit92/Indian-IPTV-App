import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import '../constants.dart';
import '../model/channel.dart';
import '../services/pip_service.dart';

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
  ChewieController? _chewieController;
  final FocusNode _keyboardFocusNode = FocusNode(debugLabel: 'player_keyboard');

  bool _isLoading = true;
  bool _channelNotFound = false;
  bool _controlsVisible = false;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initializePlayer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
    });
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
      showControls: false,
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

  void _showControls() {
    setState(() {
      _controlsVisible = true;
    });
    _startControlsHideTimer();
  }

  void _hideControls() {
    setState(() {
      _controlsVisible = false;
    });
  }

  void _toggleControls() {
    if (_controlsVisible) {
      _hideControls();
      return;
    }
    _showControls();
  }

  void _startControlsHideTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        _hideControls();
      }
    });
  }

  Future<void> _enterPip() async {
    final entered = await PipService.enterPictureInPictureMode();
    if (!entered && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Picture-in-picture not supported on this device'),
        ),
      );
    }
  }

  void _togglePlayPause() {
    if (_videoPlayerController.value.isPlaying) {
      _videoPlayerController.pause();
    } else {
      _videoPlayerController.play();
    }
    setState(() {});
    _startControlsHideTimer();
  }

  void _seekBy(int seconds) {
    final position = _videoPlayerController.value.position;
    final target = position + Duration(seconds: seconds);
    _videoPlayerController.seekTo(target);
    _startControlsHideTimer();
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.goBack || key == LogicalKeyboardKey.escape) {
      Navigator.of(context).maybePop();
      return;
    }

    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.space) {
      _showControls();
      _togglePlayPause();
      return;
    }

    if (key == LogicalKeyboardKey.arrowRight) {
      _seekBy(10);
      return;
    }

    if (key == LogicalKeyboardKey.arrowLeft) {
      _seekBy(-10);
      return;
    }

    if (key == LogicalKeyboardKey.arrowUp) {
      _toggleControls();
      return;
    }

    if (key == LogicalKeyboardKey.arrowDown) {
      _toggleControls();
      return;
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _videoPlayerController.removeListener(_onVideoStateChanged);
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    _controlsTimer?.cancel();
    _keyboardFocusNode.dispose();
    Wakelock.disable();
    super.dispose();
  }

  Widget _buildControls() {
    if (!_controlsVisible) return const SizedBox.shrink();

    final isPlaying = _videoPlayerController.value.isPlaying;

    return Positioned(
      bottom: 32,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildControlButton(
            icon: Icons.replay_10,
            label: 'Rewind',
            onPressed: () => _seekBy(-10),
          ),
          const SizedBox(width: 16),
          _buildControlButton(
            icon: isPlaying ? Icons.pause : Icons.play_arrow,
            label: isPlaying ? 'Pause' : 'Play',
            onPressed: _togglePlayPause,
          ),
          const SizedBox(width: 16),
          _buildControlButton(
            icon: Icons.forward_10,
            label: 'Forward',
            onPressed: () => _seekBy(10),
          ),
          const SizedBox(width: 16),
          _buildControlButton(
            icon: Icons.picture_in_picture_alt,
            label: 'PiP',
            onPressed: _enterPip,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: const CircleBorder(),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channel.name),
      ),
      body: KeyboardListener(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: _handleKey,
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : _channelNotFound
                  ? const Text(
                      AppConstants.channelNotAvailable,
                      style: TextStyle(fontSize: 24.0),
                    )
                  : GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _toggleControls,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height *
                                AppConstants.playerHeightFactor,
                            child: _chewieController != null
                                ? Chewie(
                                    controller: _chewieController!,
                                  )
                                : const SizedBox.shrink(),
                          ),
                          _buildControls(),
                        ],
                      ),
                    ),
        ).animate().fadeIn(duration: AppConstants.animationDuration),
      ),
    );
  }
}
