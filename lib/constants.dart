import 'package:flutter/material.dart';

class AppConstants {
  static const String appTitle = 'Live Tv';
  static const String channelListTitle = 'Channel List';
  static const String sourceUrlLabel = 'Source URL';
  static const String sourceUrlHint = 'Enter M3U playlist URL';
  static const String searchLabel = 'Search';
  static const String searchHint = 'Search channels...';
  static const String loadButtonText = 'Load';
  static const String errorMessage = 'There was a problem finding the data';
  static const String channelNotAvailable = 'Channel not available now';
  static const String defaultLogoUrl = 'assets/images/tv-icon.png';
  static const String defaultM3uUrl =
      'https://raw.githubusercontent.com/FunctionError/PiratesTv/main/combined_playlist.m3u';

  static const double channelImageSize = 80.0;
  static const double playerHeightFactor = 0.5;
  static const int searchDebounceMs = 500;
  static const double cardMargin = 8.0;
  static const double cardPadding = 16.0;

  // Material Design 3 constants
  static const int primaryColorValue = 0xFF6750A4; // M3 purple seed
  static const Duration animationDuration = Duration(milliseconds: 400);
  static final Curve animationCurve = Curves.easeOut;
}