import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../widgets/clothing_picker.dart';
import 'wardrobe_screen.dart';

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
      imagePath: 'assets/images/white_tshirt.png',
    ),
    ClothingItem(
      name: 'Black Hoodie',
      category: 'Top',
      color: 'Black',
      imagePath: 'assets/images/black_hoodie.png',
    ),
    ClothingItem(
      name: 'Blue Shirt',
      category: 'Top',
      color: 'Blue',
      imagePath: 'assets/images/blue_shirt.png',
    ),
  ];

  final List<ClothingItem> bottoms = [
    ClothingItem(
      name: 'Blue Jeans',
      category: 'Bottom',
      color: 'Blue',
      imagePath: 'assets/images/blue_jeans.png',
    ),
    ClothingItem(
      name: 'Black Pants',
      category: 'Bottom',
      color: 'Black',
      imagePath: 'assets/images/black_pants.png',
    ),
    ClothingItem(
      name: 'Khaki Pants',
      category: 'Bottom',
      color: 'Khaki',
      imagePath: 'assets/images/khaki_pants.png',
    ),
  ];

  final List<ClothingItem> shoes = [
    ClothingItem(
      name: 'White Sneakers',
      category: 'Shoes',
      color: 'White',
      imagePath: 'assets/images/white_sneakers.png',
    ),
    ClothingItem(
      name: 'Black Boots',
      category: 'Shoes',
      color: 'Black',
      imagePath: 'assets/images/black_boots.png',
    ),
    ClothingItem(
      name: 'Running Shoes',
      category: 'Shoes',
      color: 'Gray',
      imagePath: 'assets/images/running_shoes.png',
    ),
  ];

  List<ClothingItem> get allClothingItems {
    return [
      ...tops,
      ...bottoms,
      ...shoes,
    ];
  }

  int currentTopIndex = 0;
  int currentBottomIndex = 0;
  int currentShoeIndex = 0;

  void nextTop() {
    setState(() {
      currentTopIndex = (currentTopIndex + 1) % tops.length;
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
      currentBottomIndex = (currentBottomIndex + 1) % bottoms.length;
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
      currentShoeIndex = (currentShoeIndex + 1) % shoes.length;
    });
  }

  void previousShoe() {
    setState(() {
      currentShoeIndex--;

      if (currentShoeIndex < 0) {
        currentShoeIndex = shoes.length - 1;
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

              const SizedBox(height: 6),

              const Text(
                'What are we wearing today?',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return WardrobeScreen(
                            clothingItems: allClothingItems,
                          );
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.checkroom),
                  label: const Text('View Wardrobe'),
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        'TOP',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      ClothingPicker(
                        item: currentTop,
                        onPrevious: previousTop,
                        onNext: nextTop,
                      ),

                      const SizedBox(height:24),

                      const Text(
                        'BOTTOM',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      ClothingPicker(
                        item: currentBottom,
                        onPrevious: previousBottom,
                        onNext: nextBottom,
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'SHOES',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      ClothingPicker(
                        item: currentShoe,
                        onPrevious: previousShoe,
                        onNext: nextShoe,
                      ),

                      const SizedBox(height: 24),
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
}