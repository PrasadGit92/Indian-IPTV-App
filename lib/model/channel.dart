class Channel {
  const Channel({
    required this.name,
    required this.logoUrl,
    required this.streamUrl,
  });

  final String name;
  final String logoUrl;
  final String streamUrl;

  @override
  String toString() => 'Channel(name: $name, logoUrl: $logoUrl, streamUrl: $streamUrl)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Channel &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          logoUrl == other.logoUrl &&
          streamUrl == other.streamUrl;

  @override
  int get hashCode => name.hashCode ^ logoUrl.hashCode ^ streamUrl.hashCode;
}
