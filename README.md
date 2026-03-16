# Indian IPTV App

A Flutter-based IPTV application for streaming live Indian TV channels from M3U playlists.

## Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider (ChangeNotifier)
- **Video Playback**: video_player, chewie
- **Networking**: http
- **Other**: wakelock (screen keep awake)

## Project Structure

```
lib/
├── constants.dart          # App-wide constants and configurations
├── main.dart               # App entry point with Provider setup
├── model/
│   └── channel.dart        # Channel data model
├── provider/
│   └── channels_provider.dart  # State management for channels
├── repositories/
│   └── channels_repository.dart # Data fetching abstraction
├── screens/
│   ├── home.dart           # Main screen with channel list and search
│   └── player.dart         # Video player screen
├── services/
│   └── m3u_parser.dart     # M3U playlist parsing logic
└── widgets/
    └── channel_list_item.dart # Reusable channel list item widget
```

## Dependencies

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  video_player: ^2.8.2
  http: ^1.2.0
  chewie: ^1.5.0
  wakelock: ^0.6.2
  provider: ^6.1.1
```

## How to Run

1. Ensure Flutter SDK is installed and configured.
2. Clone the repository.
3. Run `flutter pub get` to install dependencies.
4. Connect a device or start an emulator.
5. Run `flutter run` to launch the app.

For Android TV:
- Use `flutter run --device-id <tv-device-id>` to target Android TV.

## Usage

### Loading Channels
- Enter an M3U playlist URL in the source URL field on the home screen.
- Tap "Load" to fetch and parse the playlist.

### Searching Channels
- Use the search bar to filter channels by name.

### Playing Channels
- Tap on a channel in the list to open the player screen.
- The player supports full-screen playback with controls via Chewie.

### Technical Details

- **M3U Parsing**: The `M3uParser` class extracts channel information (name, logo, stream URL) from M3U content.
- **State Management**: `ChannelsProvider` uses ChangeNotifier to manage channel data and notify UI updates.
- **Repository Pattern**: `ChannelsRepository` abstracts data fetching, allowing easy testing and dependency injection.
- **UI Modularity**: `ChannelListItem` widget encapsulates channel display logic for reusability.
- **Constants**: Centralized in `AppConstants` for DRY principle compliance.

## Architecture Principles

- **SOLID**: Single responsibility (e.g., separate parsing, fetching, state management).
- **DRY**: Avoid repetition with constants and reusable widgets.
- **KISS**: Simple, straightforward implementation.
- **YAGNI**: Focused on essential features without over-engineering.
