import 'package:http/http.dart' as http;

import '../model/channel.dart';
import '../services/m3u_parser.dart';

class ChannelsRepository {
  const ChannelsRepository(this._parser);

  final M3uParser _parser;

  Future<List<Channel>> fetchChannels(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return _parser.parse(response.body);
    } else {
      throw Exception('Failed to load M3U file: ${response.statusCode}');
    }
  }
}