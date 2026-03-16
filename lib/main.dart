import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'provider/channels_provider.dart';
import 'screens/home.dart';

void main() => runApp(M3UPlayer());

class M3UPlayer extends StatelessWidget {
  M3UPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChannelsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appTitle,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(AppConstants.primaryColorValue),
          ),
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text(AppConstants.channelListTitle),
          ),
          body: const Home(),
        ),
      ),
    );
  }
}
