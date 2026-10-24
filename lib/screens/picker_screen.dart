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
import '../widgets/selection_chips.dart';

class PickerScreen extends StatefulWidget {
  const PickerScreen({
    super.key,
  });

  @override
  State<PickerScreen> createState() {
    return _PickerScreenState();
  }
}

class _PickerScreenState
    extends State<PickerScreen> {
  final DatabaseService _databaseService =
      DatabaseService.instance;

  final OutfitService _outfitService =
      OutfitService();

  final WeatherService _weatherService =
      WeatherService();

  List<ClothingItem> wardrobe = [];
  List<OutfitHistory> outfitHistory = [];

  WeatherInfo? weather;

  bool isLoading = true;
  bool isWeatherLoading = false;

  bool isPickingOutfit = false;
  bool showMatchResult = false;
  bool outfitMarkedAsWorn = false;

  Outfit? selectedOutfit;

  int currentTopIndex = 0;
  int currentBottomIndex = 0;
  int currentShoeIndex = 0;

  String selectedOccasion = 'Everyday';
  String selectedSeason = 'All';

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

  List<ClothingItem> get tops {
    return wardrobe.where(
      (item) {
        return item.category == 'Top';
      },
    ).toList();
  }

  List<ClothingItem> get bottoms {
    return wardrobe.where(
      (item) {
        return item.category == 'Bottom';
      },
    ).toList();
  }

  List<ClothingItem> get shoes {
    return wardrobe.where(
      (item) {
        return item.category == 'Shoes';
      },
    ).toList();
  }

  bool get canGenerateOutfit {
    return tops.isNotEmpty &&
        bottoms.isNotEmpty &&
        shoes.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();

    loadPickerData();
    loadWeather();
  }

  Future<void> loadPickerData() async {
    final clothing =
        await _databaseService.getAllClothing();

    final history =
        await _databaseService.getOutfitHistory();

    if (!mounted) {
      return;
    }

    setState(() {
      wardrobe = clothing;
      outfitHistory = history;
      isLoading = false;

      fixSelectedIndexes();
    });
  }

  Future<void> loadWeather() async {
    setState(() {
      isWeatherLoading = true;
    });

    try {
      final result =
          await _weatherService.getCurrentWeather(
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

  void fixSelectedIndexes() {
    if (tops.isNotEmpty &&
        currentTopIndex >= tops.length) {
      currentTopIndex = tops.length - 1;
    }

    if (bottoms.isNotEmpty &&
        currentBottomIndex >=
            bottoms.length) {
      currentBottomIndex =
          bottoms.length - 1;
    }

    if (shoes.isNotEmpty &&
        currentShoeIndex >= shoes.length) {
      currentShoeIndex =
          shoes.length - 1;
    }

    if (currentTopIndex < 0) {
      currentTopIndex = 0;
    }

    if (currentBottomIndex < 0) {
      currentBottomIndex = 0;
    }

    if (currentShoeIndex < 0) {
      currentShoeIndex = 0;
    }
  }

  void nextTop() {
    if (tops.isEmpty) {
      return;
    }

    setState(() {
      currentTopIndex =
          (currentTopIndex + 1) %
              tops.length;

      selectedOutfit = null;
      showMatchResult = false;
      outfitMarkedAsWorn = false;
    });
  }

  void previousTop() {
    if (tops.isEmpty) {
      return;
    }

    setState(() {
      currentTopIndex =
          (currentTopIndex -
                  1 +
                  tops.length) %
              tops.length;

      selectedOutfit = null;
      showMatchResult = false;
      outfitMarkedAsWorn = false;
    });
  }

  void nextBottom() {
    if (bottoms.isEmpty) {
      return;
    }

    setState(() {
      currentBottomIndex =
          (currentBottomIndex + 1) %
              bottoms.length;

      selectedOutfit = null;
      showMatchResult = false;
      outfitMarkedAsWorn = false;
    });
  }

  void previousBottom() {
    if (bottoms.isEmpty) {
      return;
    }

    setState(() {
      currentBottomIndex =
          (currentBottomIndex -
                  1 +
                  bottoms.length) %
              bottoms.length;

      selectedOutfit = null;
      showMatchResult = false;
      outfitMarkedAsWorn = false;
    });
  }

  void nextShoe() {
    if (shoes.isEmpty) {
      return;
    }

    setState(() {
      currentShoeIndex =
          (currentShoeIndex + 1) %
              shoes.length;

      selectedOutfit = null;
      showMatchResult = false;
      outfitMarkedAsWorn = false;
    });
  }

  void previousShoe() {
    if (shoes.isEmpty) {
      return;
    }

    setState(() {
      currentShoeIndex =
          (currentShoeIndex -
                  1 +
                  shoes.length) %
              shoes.length;

      selectedOutfit = null;
      showMatchResult = false;
      outfitMarkedAsWorn = false;
    });
  }

  Future<void> pickOutfit() async {
    if (isPickingOutfit) {
      return;
    }

    final outfit =
        _outfitService.generateOutfit(
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
            'Add at least one top, bottom, and pair of shoes first.',
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

    for (int i = 0; i < 16; i++) {
      if (!mounted) {
        return;
      }

      setState(() {
        currentTopIndex =
            (currentTopIndex + 1) %
                tops.length;

        if (i % 2 == 0) {
          currentBottomIndex =
              (currentBottomIndex + 1) %
                  bottoms.length;
        }

        if (i % 3 == 0) {
          currentShoeIndex =
              (currentShoeIndex + 1) %
                  shoes.length;
        }
      });

      await Future.delayed(
        Duration(
          milliseconds:
              60 + (i * 14),
        ),
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      currentTopIndex =
          tops.indexOf(outfit.top);

      currentBottomIndex =
          bottoms.indexOf(
        outfit.bottom,
      );

      currentShoeIndex =
          shoes.indexOf(
        outfit.shoes,
      );

      selectedOutfit = outfit;
      isPickingOutfit = false;
      showMatchResult = true;
    });
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

    final alreadySaved =
        await _databaseService
            .isFavoriteOutfit(
      outfit.top.id!,
      outfit.bottom.id!,
      outfit.shoes.id!,
    );

    if (!mounted) {
      return;
    }

    if (alreadySaved) {
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

    await _databaseService
        .insertFavoriteOutfit(
      savedOutfit,
    );

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

    if (outfit.top.id == null ||
        outfit.bottom.id == null ||
        outfit.shoes.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This outfit cannot be added to history.',
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

    final savedHistory =
        await _databaseService
            .insertOutfitHistory(
      history,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      outfitHistory.insert(
        0,
        savedHistory,
      );

      outfitMarkedAsWorn = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Outfit added to history',
        ),
      ),
    );
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

  Widget _buildWeatherCard() {
    if (isWeatherLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    if (weather == null) {
      return Card(
        child: ListTile(
          leading: const Icon(
            Icons.cloud_off_outlined,
          ),
          title: const Text(
            'Weather unavailable',
          ),
          trailing: IconButton(
            onPressed: loadWeather,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ),
      );
    }

    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.cloud_outlined,
        ),
        title: Text(
          '${weather!.temperature.toStringAsFixed(1)}°C'
          ' • ${weather!.temperatureCategory}',
        ),
        subtitle: weather!.isRainy
            ? const Text(
                'Rain expected',
              )
            : const Text(
                'No rain detected',
              ),
        trailing: IconButton(
          onPressed: isWeatherLoading
              ? null
              : loadWeather,
          icon: const Icon(
            Icons.refresh,
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    if (selectedOutfit == null) {
      return const SizedBox.shrink();
    }

    return AnimatedOpacity(
      duration: const Duration(
        milliseconds: 500,
      ),
      opacity:
          showMatchResult ? 1 : 0,
      child: Column(
        children: [
          Text(
            '$selectedOccasion • $selectedSeason',
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Text(
                '${selectedOutfit!.score}% MATCH',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed:
                    saveFavoriteOutfit,
                icon: const Icon(
                  Icons.favorite_border,
                ),
              ),
            ],
          ),
          Text(
            getMatchMessage(
              selectedOutfit!.score,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed:
                outfitMarkedAsWorn
                    ? null
                    : wearSelectedOutfit,
            icon: const Icon(
              Icons.check,
            ),
            label: Text(
              outfitMarkedAsWorn
                  ? 'WORN TODAY'
                  : 'WEAR THIS OUTFIT',
            ),
          ),
        ],
      ),
    );
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

    if (!canGenerateOutfit) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Outfit Picker',
          ),
          actions: [
            IconButton(
              onPressed: () {
                loadPickerData();
                loadWeather();
              },
              icon: const Icon(
                Icons.refresh,
              ),
            ),
          ],
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 72,
                ),
                SizedBox(height: 20),
                Text(
                  'Not enough clothing yet',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Add at least one top, one bottom, and one pair of shoes to generate an outfit.',
                  textAlign:
                      TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentTop =
        tops[currentTopIndex];

    final currentBottom =
        bottoms[currentBottomIndex];

    final currentShoe =
        shoes[currentShoeIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Outfit Picker',
        ),
        actions: [
          IconButton(
            onPressed: () {
              loadPickerData();
              loadWeather();
            },
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              _buildWeatherCard(),

              const SizedBox(height: 20),

              SelectionChips(
                title:
                    'Where are you going?',
                options: occasions,
                selectedValue:
                    selectedOccasion,
                onSelected: (occasion) {
                  setState(() {
                    selectedOccasion =
                        occasion;

                    selectedOutfit =
                        null;

                    showMatchResult =
                        false;

                    outfitMarkedAsWorn =
                        false;
                  });
                },
              ),

              const SizedBox(height: 20),

              SelectionChips(
                title: 'Season',
                options: seasons,
                selectedValue:
                    selectedSeason,
                onSelected: (season) {
                  setState(() {
                    selectedSeason =
                        season;

                    selectedOutfit =
                        null;

                    showMatchResult =
                        false;

                    outfitMarkedAsWorn =
                        false;
                  });
                },
              ),

              const SizedBox(height: 28),

              const Text(
                'TOP',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              ClothingPicker(
                item: currentTop,
                onPrevious:
                    previousTop,
                onNext: nextTop,
                enabled:
                    !isPickingOutfit,
              ),

              const SizedBox(height: 24),

              const Text(
                'BOTTOM',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              ClothingPicker(
                item: currentBottom,
                onPrevious:
                    previousBottom,
                onNext: nextBottom,
                enabled:
                    !isPickingOutfit,
              ),

              const SizedBox(height: 24),

              const Text(
                'SHOES',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              ClothingPicker(
                item: currentShoe,
                onPrevious:
                    previousShoe,
                onNext: nextShoe,
                enabled:
                    !isPickingOutfit,
              ),

              const SizedBox(height: 28),

              _buildResult(),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      isPickingOutfit
                          ? null
                          : pickOutfit,
                  style:
                      ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 18,
                    ),
                  ),
                  child: isPickingOutfit
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'PICK MY OUTFIT',
                          style:
                              TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight
                                    .bold,
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