import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../services/database_service.dart';
import '../services/outfit_service.dart';
import '../widgets/clothing_picker.dart';
import 'add_clothing_screen.dart';
import 'wardrobe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  final OutfitService _outfitService = OutfitService();
  List<ClothingItem> wardrobe = [];
  bool isLoading = true;

  Outfit? selectedOutfit;

  @override
  void initState() {
    super.initState();

    loadWardrobe();
  }

  Future<void> loadWardrobe() async {
    final items = await _databaseService.getAllClothing();

    if (!mounted) {
      return;
    }

    setState(() {
      wardrobe = items;
      isLoading = false;
    });
  }
  
  List<ClothingItem> get tops {
    return wardrobe
        .where((item) => item.category == 'Top')
        .toList();
  }

  List<ClothingItem> get bottoms {
    return wardrobe
        .where((item) => item.category == 'Bottom')
        .toList();
  }

  List<ClothingItem> get shoes {
    return wardrobe 
        .where((item) => item.category == 'Shoes')
        .toList();
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

  Future<void> addClothing() async {
    final ClothingItem? newItem = await Navigator.push<ClothingItem>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const AddClothingScreen();
        },
      ),
    );

    if (newItem == null) {
      return;
    }

    final savedItem = await _databaseService.insertClothing(newItem);

    if (!mounted) {
      return;
    }

    setState(() {
      wardrobe.add(savedItem);
    });
  }

  void fixSelectedIndexes() {
    if (tops.isNotEmpty && currentTopIndex >= tops.length) {
      currentTopIndex = tops.length - 1;
    }

    if (bottoms.isNotEmpty && currentBottomIndex >= bottoms.length) {
      currentBottomIndex = bottoms.length - 1;
    }

    if (shoes.isNotEmpty && currentShoeIndex >= shoes.length) {
      currentShoeIndex = shoes.length - 1;
    }
  }

  void pickOutfit() {
    final outfit = _outfitService.generateOutfit(
      tops: tops,
      bottoms: bottoms,
      shoes: shoes,
    );

    if (outfit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add atleast one top, bottom and a pair of shoes first.',
          ),
        ),
      );

      return;
    }

    setState(() {
      selectedOutfit = outfit;

      currentTopIndex = tops.indexOf(outfit.top);
      currentBottomIndex = bottoms.indexOf(outfit.bottom);
      currentShoeIndex = shoes.indexOf(outfit.shoes);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    fixSelectedIndexes();
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

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: addClothing,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Clothing'),
                  ),

                  const SizedBox(width: 8),

                  TextButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return WardrobeScreen(
                              clothingItems: wardrobe,
                            );
                          },
                        ),
                      );

                      setState(() {});
                    },
                    icon: const Icon(Icons.checkroom),
                    label: const Text('Wardrobe'),
                  ),
                ],
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

              if (selectedOutfit != null)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 16
                  ),
                  child: Center(
                    child: Text(
                      '${selectedOutfit!.score}% MATCH',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: pickOutfit,
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