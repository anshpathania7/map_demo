import 'package:flutter/material.dart';
import 'package:map_demo/providers/map_provider.dart';
import 'package:provider/provider.dart';

import 'screens/map_sample.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => MapProvider()..init(),
            ),
          ],
          builder: (context, _) {
            return const MapSample();
          }),
    );
  }
}
