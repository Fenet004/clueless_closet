import 'package:flutter/material.dart';
import 'models/clothing_item.dart';

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<ClothingItem> tops = [
    ClothingItem(
      name: 'White T-Shirt',
      category: 'Top',
      color: 'White',
    ),
    ClothingItem(
      name: 'Black Hoodie',
      category: 'Top',
      color: 'Black',
    ),
    ClothingItem(
      name: 'Blue Shirt',
      category: 'Top',
      color: 'Blue',
    ),
  ];

  final List<ClothingItem> bottoms = [
    ClothingItem(
      name: 'Blue Jeans',
      category: 'Bottom',
      color: 'Blue',
    ),
    ClothingItem(
      name: 'Black Pants',
      category: 'Bottom',
      color: 'Black',
    ),
    ClothingItem(
      name: 'Khaki Pants',
      category: 'Bottom',
      color: 'Khaki',
    ),
  ];

  final List<ClothingItem> shoes = [
    ClothingItem(
      name: 'White Sneakers',
      category: 'Shoes',
      color: 'White',
    ),
    ClothingItem(
      name: 'Black Boots',
      category: 'Shoes',
      color: 'Gray',
    ),
  ];

  int currentTopIndex = 0;
  int currentBottomIndex = 0;
  int currentShoeIndex = 0;

  void nextTop() {
    setState(() {
      currentTopIndex++;

      if (currentTopIndex >= tops.length) {
        currentTopIndex = 0;
      }
    });
  }

  void previousTop() {
    setState(() {
      currentTopIndex--;

      if (currentTopIndex < 0) {
        currentTopIndex = tops.length - 1;
      }
    });
  }

  void nextBottom() {
    setState(() {
      currentBottomIndex++;

      if (currentBottomIndex >= bottoms.length) {
        currentBottomIndex = 0;
      }
    });
  }

  void previousBottom() {
    setState(() {
      currentBottomIndex--;

      if (currentBottomIndex < 0) {
        currentBottomIndex = bottoms.length -1;
      }
    });
  }

  void nextShoe() {
    setState(() {
      currentShoeIndex++;

      if (currentShoeIndex >= shoes.length) {
        currentShoeIndex = 0;
      }
    });
  }

  void previousShoe() {
    setState(() {
      currentShoeIndex--;

      if (currentShoeIndex < 0) {
        currentShoeIndex = shoes.length -1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ClothingItem currentTop = tops[currentTopIndex];
    ClothingItem currentBottom = bottoms[currentBottomIndex];
    ClothingItem currentShoe = shoes[currentShoeIndex];

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
                      buildClothingSection(
                        item: currentTop,
                        onPrevious : previousTop,
                        onNext: nextTop,
                      ),

                      const SizedBox(height: 24),

                      buildClothingSection(
                        item: currentBottom,
                        onPrevious: previousBottom,
                        onNext: nextBottom,
                      ),

                      const SizedBox(height:24),

                      buildClothingSection(
                        item: currentShoe,
                        onPrevious: previousShoe,
                        onNext: nextShoe,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    print('Outfit: ${currentTop.name}, ${currentBottom.name}, ${currentShoe.name}');
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

  Widget buildClothingSection({
    required ClothingItem item,
    required VoidCallback onPrevious,
    required VoidCallback onNext,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPrevious,
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
              Text(
                item.category.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(item.color),
            ],
          ),
        ),

        IconButton(
          onPressed: onNext,
          icon: const Icon(
            Icons.arrow_right,
            size: 36,
          ),
        ),
      ],
    );
  }
}