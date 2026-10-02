import 'package:flutter/material.dart';

void main() {
  runApp(const CluelessClosetApp());
}

class CluelessClosetApp extends StatelessWidget {
  const CluelessClosetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clueless Closet',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Closet',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'What are we wearing today?',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 32),

              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildClothingSection(
                        icon: Icons.checkroom,
                        label: 'TOP',
                      ),

                      const SizedBox(height: 24),

                      _buildClothingSection(
                        icon: Icons.style,
                        label: 'BOTTOM',
                      ),

                      const SizedBox(height:24),

                      _buildClothingSection(
                        icon: Icons.directions_walk,
                        label: 'SHOES',
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    print('Pick outfit pressed');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                    ),
                  ),
                  child: const Text(
                    'PICK MY OUTFIT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClothingSection({
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            print('Previous $label');
          },
          icon: const Icon(
            Icons.arrow_left,
            size: 36,
          ),
        ),

        Container(
          width: 180,
          height:130,
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 60,
              ),

              const SizedBox(height: 8),

              Text(
                label, 
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: () {
            print('Next $label');
          },
          icon: const Icon(
            Icons.arrow_right,
            size: 36,
          ),
        ),
      ],
    );
  }
}