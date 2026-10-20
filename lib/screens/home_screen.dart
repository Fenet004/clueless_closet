import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../models/outfit_history.dart';
import '../models/saved_outfit.dart';
import '../models/weather_info.dart';
import '../services/database_service.dart';
import '../services/outfit_service.dart';
import '../services/weather_service.dart';
import '../widgets/clothing_picker.dart';
import 'add_clothing_screen.dart';
import 'favorites_screen.dart';
import 'history_screen.dart';
import 'wardrobe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  final OutfitService _outfitService = OutfitService();
  final WeatherService _weatherService = WeatherService();
  WeatherInfo? weather;
  bool isWeatherLoading = false;
  List<ClothingItem> wardrobe = [];
  bool isLoading = true;
  bool isPickingOutfit = false;
  bool showMatchResult = false;
  bool outfitMarkedAsWorn = false;
  String selectedOccasion = 'Everyday';
  String selectedSeason = 'All';
  Outfit? selectedOutfit;
  List<OutfitHistory> outfitHistory = [];

  final List<String> occasions = [
    'Everyday',
    'Work',
    'Date',
    'Party',
    'Gym',
    'Formal',
  ];

  final List<String> seasons = [
    'All',
    'Summer',
    'Winter',
    'Spring',
    'Fall',
  ];

  @override
  void initState() {
    super.initState();

    loadWardrobe();
    loadWeather();
  }

  Future<void> loadWardrobe() async {
    final items = await _databaseService.getAllClothing();

    final history = await _databaseService.getOutfitHistory();

    if (!mounted) {
      return;
    }

    setState(() {
      wardrobe = items;
      outfitHistory = history;
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

  void pickOutfit() async {
    if (isPickingOutfit) {
      return;
    }

    final outfit = _outfitService.generateOutfit(
      tops: tops,
      bottoms: bottoms,
      shoes: shoes,
      occasion: selectedOccasion,
      season: selectedSeason,
      history: outfitHistory,
      weather: weather,
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
      isPickingOutfit = true;
      selectedOutfit = null;
      showMatchResult = false;
      outfitMarkedAsWorn = false;
    });

    for (int i=0; i < 16; i++) {
      if (!mounted) {
        return;
      }

      setState(() {
        currentTopIndex = (currentTopIndex + 1) % tops.length;

        if (i % 2 == 0) {
          currentBottomIndex = (currentBottomIndex + 1) % bottoms.length;
        }
        
        if (i % 3 == 0) {
          currentShoeIndex = (currentShoeIndex + 1) % shoes.length;
        }
      });

      await Future.delayed(
        Duration(
          milliseconds: 60 + (i * 14),
        ),
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      currentTopIndex = tops.indexOf(outfit.top);
      currentBottomIndex = bottoms.indexOf(outfit.bottom);
      currentShoeIndex = shoes.indexOf(outfit.shoes);

      selectedOutfit = outfit;
      isPickingOutfit = false;
      showMatchResult = true;
    });
  }

  String getMatchMessage(int score) {
    if (score >= 90) {
      return 'Perfect match!';
    }

    if (score >= 75) {
      return 'Great combination!';
    }

    if (score >= 60) {
      return 'Looking good!';
    }

    return 'Try another combination';
  }

  Future<void> saveFavoriteOutfit() async {
    final outfit = selectedOutfit;

    if (outfit == null) {
      return;
    }

    if (outfit.top.id == null ||
        outfit.bottom.id == null ||
        outfit.shoes.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This outfit cannot be saved yet.',
          ),
        ),
      );

      return;
    }

    final alreadySaved = await _databaseService.isFavoriteOutfit(
      outfit.top.id!,
      outfit.bottom.id!,
      outfit.shoes.id!,
    );

    if (alreadySaved) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This outfit is already in your favorites.',
          ),
        ),
      );

      return;
    }

    final savedOutfit = SavedOutfit(
      topId: outfit.top.id!,
      bottomId: outfit.bottom.id!,
      shoeId: outfit.shoes.id!,
      score: outfit.score,
    );

    await _databaseService.insertFavoriteOutfit(savedOutfit);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Outfit saved to favorites',
        ),
      ),
    );
  }

  Future<void> wearSelectedOutfit() async {
    final outfit = selectedOutfit;

    if (outfit == null) {
      return;
    }

    if (outfit.top.id == null || outfit.bottom.id == null || outfit.shoes.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This outfit cannot be added to history,',
          ),
        ),
      );

      return;
    }

    final history = OutfitHistory(
      topId: outfit.top.id!,
      bottomId: outfit.bottom.id!,
      shoeId: outfit.shoes.id!,
      score: outfit.score,
      wornAt: DateTime.now(),
    );

    final savedHistory = await _databaseService.insertOutfitHistory(history);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Outfit added to history',
        ),
      ),
    );

    setState(() {
      outfitHistory.insert(0, savedHistory);
      outfitMarkedAsWorn = true;
    });
  }

  Future<void> loadWeather() async {
    setState(() {
      isWeatherLoading = true;
    });

    try {
      final result = await _weatherService.getCurrentWeather(
        latitude: 9.03,
        longitude: 38.74,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        weather = result;
        isWeatherLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isWeatherLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not load weather.',
          ),
        ),
      );
    }
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

                  const SizedBox(width: 8),

                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return FavoritesScreen(
                              wardrobe: wardrobe,
                            );
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.favorite),
                    label: const Text('Favorites'),
                  ),

                  const SizedBox(width: 8),

                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return HistoryScreen(
                              wardrobe: wardrobe,
                            );
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('History'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (isWeatherLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      else if (weather != null)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(Icons.cloud_outlined),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${weather!.temperature.toStringAsFixed(1)}°C'
                                    ' • ${weather!.temperatureCategory}'
                                    '${weather!.isRainy ? ' • Rain' : ''}',
                                  ),
                                ),
                                IconButton(
                                  onPressed: isWeatherLoading
                                      ? null
                                      : loadWeather,
                                  icon: const Icon(Icons.refresh),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const Text(
                        'Where are you going?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: occasions.map((occasion) {
                          return ChoiceChip(
                            label: Text(occasion),
                            selected: selectedOccasion == occasion,
                            onSelected: (selected) {
                              if (!selected) {
                                return;
                              }

                              setState(() {
                                selectedOccasion = occasion;
                                selectedOutfit = null;
                                showMatchResult = false;
                                outfitMarkedAsWorn = false;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Season',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: seasons.map((season) {
                          return ChoiceChip(
                            label: Text(season),
                            selected: selectedSeason == season,
                            onSelected: (selected) {
                              if (!selected) {
                                return;
                              }

                              setState(() {
                                selectedSeason = season;
                                selectedOutfit = null;
                                showMatchResult = false;
                                outfitMarkedAsWorn = false;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

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
                        enabled: !isPickingOutfit,
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
                        enabled: !isPickingOutfit,
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
                        enabled: !isPickingOutfit,
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              if (selectedOutfit != null)
                AnimatedOpacity(
                  duration: const Duration(
                    milliseconds: 500,
                  ),
                  opacity: showMatchResult ? 1 : 0,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 16,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$selectedOccasion • $selectedSeason',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${selectedOutfit!.score}% MATCH',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: saveFavoriteOutfit,
                              icon: const Icon(
                                Icons.favorite_border,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          getMatchMessage(
                            selectedOutfit!.score,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: outfitMarkedAsWorn
                              ? null
                              : wearSelectedOutfit,
                          icon: const Icon(Icons.check),
                          label: Text(
                            outfitMarkedAsWorn
                                ? 'WORN TODAY'
                                : 'WEAR THIS OUTFIT',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isPickingOutfit
                      ? null
                      : pickOutfit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                    ),
                  ),
                  child: isPickingOutfit
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
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