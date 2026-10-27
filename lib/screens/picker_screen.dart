import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/closet_bloc.dart';
import '../bloc/closet_event.dart';
import '../bloc/closet_state.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../models/outfit_history.dart';
import '../models/saved_outfit.dart';
import '../models/weather_info.dart';
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
  final OutfitService _outfitService =
      OutfitService();

  final WeatherService _weatherService =
      WeatherService();

  WeatherInfo? weather;

  bool isWeatherLoading = false;
  bool isPickingOutfit = false;
  bool showMatchResult = false;
  bool outfitMarkedAsWorn = false;

  Outfit? selectedOutfit;

  int currentTopIndex = 0;
  int currentBottomIndex = 0;
  int currentShoeIndex = 0;

  String selectedOccasion =
      'Everyday';

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

  @override
  void initState() {
    super.initState();

    loadWeather();
  }

  List<ClothingItem> _tops(
    List<ClothingItem> wardrobe,
  ) {
    return wardrobe.where(
      (item) {
        return item.category == 'Top';
      },
    ).toList();
  }

  List<ClothingItem> _bottoms(
    List<ClothingItem> wardrobe,
  ) {
    return wardrobe.where(
      (item) {
        return item.category == 'Bottom';
      },
    ).toList();
  }

  List<ClothingItem> _shoes(
    List<ClothingItem> wardrobe,
  ) {
    return wardrobe.where(
      (item) {
        return item.category == 'Shoes';
      },
    ).toList();
  }

  // ignore: unused_element
  void _fixSelectedIndexes({
    required List<ClothingItem> tops,
    required List<ClothingItem> bottoms,
    required List<ClothingItem> shoes,
  }) {
    if (tops.isEmpty) {
      currentTopIndex = 0;
    } else if (currentTopIndex >=
        tops.length) {
      currentTopIndex =
          tops.length - 1;
    }

    if (bottoms.isEmpty) {
      currentBottomIndex = 0;
    } else if (currentBottomIndex >=
        bottoms.length) {
      currentBottomIndex =
          bottoms.length - 1;
    }

    if (shoes.isEmpty) {
      currentShoeIndex = 0;
    } else if (currentShoeIndex >=
        shoes.length) {
      currentShoeIndex =
          shoes.length - 1;
    }
  }

  Future<void> loadWeather() async {
    setState(() {
      isWeatherLoading = true;
    });

    try {
      final result =
          await _weatherService
              .getCurrentWeather(
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Could not load weather.',
          ),
        ),
      );
    }
  }

  void nextTop(
    List<ClothingItem> tops,
  ) {
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

  void previousTop(
    List<ClothingItem> tops,
  ) {
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

  void nextBottom(
    List<ClothingItem> bottoms,
  ) {
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

  void previousBottom(
    List<ClothingItem> bottoms,
  ) {
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

  void nextShoe(
    List<ClothingItem> shoes,
  ) {
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

  void previousShoe(
    List<ClothingItem> shoes,
  ) {
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

  Future<void> pickOutfit({
    required List<ClothingItem> tops,
    required List<ClothingItem> bottoms,
    required List<ClothingItem> shoes,
    required List<OutfitHistory> history,
  }) async {
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
      history: history,
      weather: weather,
    );

    if (outfit == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
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
          tops.indexOf(
        outfit.top,
      );

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

  void saveFavoriteOutfit() {
    final outfit = selectedOutfit;

    if (outfit == null) {
      return;
    }

    if (outfit.top.id == null ||
        outfit.bottom.id == null ||
        outfit.shoes.id == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'This outfit cannot be saved yet.',
          ),
        ),
      );

      return;
    }

    context.read<ClosetBloc>().add(
          FavoriteAdded(
            SavedOutfit(
              topId: outfit.top.id!,
              bottomId:
                  outfit.bottom.id!,
              shoeId:
                  outfit.shoes.id!,
              score: outfit.score,
            ),
          ),
        );
  }

  void wearSelectedOutfit() {
    final outfit = selectedOutfit;

    if (outfit == null) {
      return;
    }

    if (outfit.top.id == null ||
        outfit.bottom.id == null ||
        outfit.shoes.id == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'This outfit cannot be added to history.',
          ),
        ),
      );

      return;
    }

    context.read<ClosetBloc>().add(
          HistoryAdded(
            OutfitHistory(
              topId: outfit.top.id!,
              bottomId:
                  outfit.bottom.id!,
              shoeId:
                  outfit.shoes.id!,
              score: outfit.score,
              wornAt: DateTime.now(),
            ),
          ),
        );

    setState(() {
      outfitMarkedAsWorn = true;
    });
  }

  String getMatchMessage(
    int score,
  ) {
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
          padding:
              EdgeInsets.all(16),
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
          onPressed:
              isWeatherLoading
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
    final outfit =
        selectedOutfit;

    if (outfit == null) {
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
                '${outfit.score}% MATCH',
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
              outfit.score,
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

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding:
            EdgeInsets.all(32),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
        ClosetBloc,
        ClosetState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(
              child:
                  CircularProgressIndicator(),
            ),
          );
        }

        final wardrobe =
            state.wardrobe;

        final tops =
            _tops(wardrobe);

        final bottoms =
            _bottoms(wardrobe);

        final shoes =
            _shoes(wardrobe);

        final canGenerateOutfit =
            tops.isNotEmpty &&
                bottoms.isNotEmpty &&
                shoes.isNotEmpty;

        /*
         * We cannot safely call setState()
         * while build() is running.
         *
         * Instead we simply derive safe indexes
         * for rendering below.
         */
        final safeTopIndex =
            tops.isEmpty
                ? 0
                : currentTopIndex
                        .clamp(
                          0,
                          tops.length - 1,
                        );

        final safeBottomIndex =
            bottoms.isEmpty
                ? 0
                : currentBottomIndex
                        .clamp(
                          0,
                          bottoms.length -
                              1,
                        );

        final safeShoeIndex =
            shoes.isEmpty
                ? 0
                : currentShoeIndex
                        .clamp(
                          0,
                          shoes.length - 1,
                        );

        if (!canGenerateOutfit) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Outfit Picker',
              ),
              actions: [
                IconButton(
                  onPressed:
                      loadWeather,
                  icon: const Icon(
                    Icons.refresh,
                  ),
                ),
              ],
            ),
            body:
                _buildEmptyState(),
          );
        }

        final currentTop =
            tops[safeTopIndex];

        final currentBottom =
            bottoms[safeBottomIndex];

        final currentShoe =
            shoes[safeShoeIndex];

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Outfit Picker',
            ),
            actions: [
              IconButton(
                onPressed:
                    loadWeather,
                icon: const Icon(
                  Icons.refresh,
                ),
              ),
            ],
          ),
          body: SafeArea(
            child:
                SingleChildScrollView(
              padding:
                  const EdgeInsets
                      .all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                children: [
                  _buildWeatherCard(),

                  const SizedBox(
                    height: 20,
                  ),

                  SelectionChips(
                    title:
                        'Where are you going?',
                    options:
                        occasions,
                    selectedValue:
                        selectedOccasion,
                    onSelected:
                        (occasion) {
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

                  const SizedBox(
                    height: 20,
                  ),

                  SelectionChips(
                    title:
                        'Season',
                    options:
                        seasons,
                    selectedValue:
                        selectedSeason,
                    onSelected:
                        (season) {
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

                  const SizedBox(
                    height: 28,
                  ),

                  const Text(
                    'TOP',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  ClothingPicker(
                    item: currentTop,
                    onPrevious: () {
                      currentTopIndex =
                          safeTopIndex;

                      previousTop(
                        tops,
                      );
                    },
                    onNext: () {
                      currentTopIndex =
                          safeTopIndex;

                      nextTop(
                        tops,
                      );
                    },
                    enabled:
                        !isPickingOutfit,
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  const Text(
                    'BOTTOM',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  ClothingPicker(
                    item:
                        currentBottom,
                    onPrevious: () {
                      currentBottomIndex =
                          safeBottomIndex;

                      previousBottom(
                        bottoms,
                      );
                    },
                    onNext: () {
                      currentBottomIndex =
                          safeBottomIndex;

                      nextBottom(
                        bottoms,
                      );
                    },
                    enabled:
                        !isPickingOutfit,
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  const Text(
                    'SHOES',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  ClothingPicker(
                    item: currentShoe,
                    onPrevious: () {
                      currentShoeIndex =
                          safeShoeIndex;

                      previousShoe(
                        shoes,
                      );
                    },
                    onNext: () {
                      currentShoeIndex =
                          safeShoeIndex;

                      nextShoe(
                        shoes,
                      );
                    },
                    enabled:
                        !isPickingOutfit,
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  _buildResult(),

                  const SizedBox(
                    height: 20,
                  ),

                  SizedBox(
                    width:
                        double.infinity,
                    child:
                        ElevatedButton(
                      onPressed:
                          isPickingOutfit
                              ? null
                              : () {
                                  pickOutfit(
                                    tops:
                                        tops,
                                    bottoms:
                                        bottoms,
                                    shoes:
                                        shoes,
                                    history:
                                        state.history,
                                  );
                                },
                      style:
                          ElevatedButton
                              .styleFrom(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 18,
                        ),
                      ),
                      child:
                          isPickingOutfit
                              ? const SizedBox(
                                  width:
                                      22,
                                  height:
                                      22,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                  ),
                                )
                              : const Text(
                                  'PICK MY OUTFIT',
                                  style:
                                      TextStyle(
                                    fontSize:
                                        16,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}