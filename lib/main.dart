import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/closet_bloc.dart';
import 'bloc/closet_event.dart';
import 'screens/main_navigation_screen.dart';
import 'services/database_service.dart';
import 'services/image_storage_service.dart';

void main() {
  runApp(const CluelessClosetApp());
}

class CluelessClosetApp extends StatelessWidget {
  const CluelessClosetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return ClosetBloc(
          databaseService: DatabaseService.instance,
          imageStorageService: ImageStorageService(),
        )..add(const ClosetStarted());
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Clueless Closet',
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const MainNavigationScreen(),
      ),
    );
  }
}

