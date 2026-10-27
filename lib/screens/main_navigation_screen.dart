import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/closet_bloc.dart';
import '../bloc/closet_state.dart';
import 'favorites_screen.dart';
import 'history_screen.dart';
import 'picker_screen.dart';
import 'wardrobe_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({
    super.key,
  });

  @override
  State<MainNavigationScreen> createState() {
    return _MainNavigationScreenState();
  }
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {
  int currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    const screens = [
      WardrobeScreen(),
      PickerScreen(),
      FavoritesScreen(),
      HistoryScreen(),
    ];

    return BlocListener<ClosetBloc, ClosetState>(
      listenWhen: (previous, current) {
        return previous.errorMessage !=
            current.errorMessage;
      },
      listener: (context, state) {
        final message = state.errorMessage;

        if (message == null) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
      },
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(
                Icons.checkroom_outlined,
              ),
              selectedIcon: Icon(
                Icons.checkroom,
              ),
              label: 'Closet',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.auto_awesome_outlined,
              ),
              selectedIcon: Icon(
                Icons.auto_awesome,
              ),
              label: 'Picker',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.favorite_border,
              ),
              selectedIcon: Icon(
                Icons.favorite,
              ),
              label: 'Favorites',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.history_outlined,
              ),
              selectedIcon: Icon(
                Icons.history,
              ),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}