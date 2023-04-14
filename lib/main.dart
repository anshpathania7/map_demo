import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_demo/bloc/map_bloc/map_bloc.dart';

import 'screens/map_sample.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => MapBloc()..add(Initial()),
        child: const MapSample(),
      ),
    );
  }
}
