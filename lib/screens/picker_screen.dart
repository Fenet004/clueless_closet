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
import '../services/location_service.dart';
import '../services/outfit_service.dart';
import '../services/weather_service.dart';
import '../widgets/clothing_picker.dart';
import '../widgets/selection_chips.dart';

class PickerScreen
    extends StatefulWidget {
  const PickerScreen({
    super.key,
  });

  @override
  State<PickerScreen>
      createState() {
    return _PickerScreenState();
  }
}

class _PickerScreenState
    extends State<PickerScreen> {
  final OutfitService
      _outfitService =
      OutfitService();

  final WeatherService
      _weatherService =
      WeatherService();

  final LocationService
      _locationService =
      LocationService();

  WeatherInfo? weather;

  bool isWeatherLoading = false;
  bool isPickingOutfit = false;
  bool showMatchResult = false;
  bool outfitMarkedAsWorn = false;

  bool
      locationPermissionPermanentlyDenied =
      false;

  bool locationServiceDisabled =
      false;

  String? locationMessage;

  Outfit? selectedOutfit;

  int currentTopIndex = 0;
  int currentBottomIndex = 0;
  int currentShoeIndex = 0;

  String selectedOccasion =
      'Everyday';

  String selectedSeason =
      'All';

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
        return item.category ==
            'Top';
      },
    ).toList();
  }

  List<ClothingItem> _bottoms(
    List<ClothingItem> wardrobe,
  ) {
    return wardrobe.where(
      (item) {
        return item.category ==
            'Bottom';
      },
    ).toList();
  }

  List<ClothingItem> _shoes(
    List<ClothingItem> wardrobe,
  ) {
    return wardrobe.where(
      (item) {
        return item.category ==
            'Shoes';
      },
    ).toList();
  }

  Future<void>
      loadWeather() async {
    setState(() {
      isWeatherLoading = true;
      locationMessage = null;

      locationPermissionPermanentlyDenied =
          false;

      locationServiceDisabled =
          false;
    });

    try {
      final position =
          await _locationService
              .getCurrentLocation();

      final result =
          await _weatherService
              .getCurrentWeather(
        latitude:
            position.latitude,
        longitude:
            position.longitude,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        weather = result;

        isWeatherLoading =
            false;

        locationMessage =
            null;

        locationPermissionPermanentlyDenied =
            false;

        locationServiceDisabled =
            false;
      });
    } on LocationException catch (e) {
      if (!mounted) {
        return;
      }

      String message;

      bool permanentlyDenied =
          false;

      bool serviceDisabled =
          false;

      switch (e.failure) {
        case LocationFailure
              .serviceDisabled:
          message =
              'Location services are turned off.';

          serviceDisabled =
              true;

          break;

        case LocationFailure
              .permissionDenied:
          message =
              'Location permission was denied.';

          break;

        case LocationFailure
              .permissionDeniedForever:
          message =
              'Location permission is disabled. Enable it in app settings.';

          permanentlyDenied =
              true;

          break;
      }

      setState(() {
        weather = null;

        isWeatherLoading =
            false;

        locationMessage =
            message;

        locationPermissionPermanentlyDenied =
            permanentlyDenied;

        locationServiceDisabled =
            serviceDisabled;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        weather = null;

        isWeatherLoading =
            false;

        locationMessage =
            'Could not load local weather.';
      });
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
      outfitMarkedAsWorn =
          false;
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
      outfitMarkedAsWorn =
          false;
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
      outfitMarkedAsWorn =
          false;
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
      outfitMarkedAsWorn =
          false;
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
      outfitMarkedAsWorn =
          false;
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
      outfitMarkedAsWorn =
          false;
    });
  }

  Future<void> pickOutfit({
    required List<ClothingItem>
        tops,
    required List<ClothingItem>
        bottoms,
    required List<ClothingItem>
        shoes,
    required List<OutfitHistory>
        history,
  }) async {
    if (isPickingOutfit) {
      return;
    }

    final outfit =
        _outfitService
            .generateOutfit(
      tops: tops,
      bottoms: bottoms,
      shoes: shoes,
      occasion:
          selectedOccasion,
      season:
          selectedSeason,
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
      outfitMarkedAsWorn =
          false;
    });

    for (int i = 0;
        i < 16;
        i++) {
      if (!mounted) {
        return;
      }

      setState(() {
        currentTopIndex =
            (currentTopIndex +
                    1) %
                tops.length;

        if (i % 2 == 0) {
          currentBottomIndex =
              (currentBottomIndex +
                      1) %
                  bottoms.length;
        }

        if (i % 3 == 0) {
          currentShoeIndex =
              (currentShoeIndex +
                      1) %
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

      selectedOutfit =
          outfit;

      isPickingOutfit =
          false;

      showMatchResult =
          true;
    });
  }

  void saveFavoriteOutfit() {
    final outfit =
        selectedOutfit;

    if (outfit == null) {
      return;
    }

    if (outfit.top.id == null ||
        outfit.bottom.id ==
            null ||
        outfit.shoes.id ==
            null) {
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

    context
        .read<ClosetBloc>()
        .add(
          FavoriteAdded(
            SavedOutfit(
              topId:
                  outfit.top.id!,
              bottomId:
                  outfit
                      .bottom.id!,
              shoeId:
                  outfit
                      .shoes.id!,
              score:
                  outfit.score,
            ),
          ),
        );
  }

  void wearSelectedOutfit() {
    final outfit =
        selectedOutfit;

    if (outfit == null) {
      return;
    }

    if (outfit.top.id == null ||
        outfit.bottom.id ==
            null ||
        outfit.shoes.id ==
            null) {
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

    context
        .read<ClosetBloc>()
        .add(
          HistoryAdded(
            OutfitHistory(
              topId:
                  outfit.top.id!,
              bottomId:
                  outfit
                      .bottom.id!,
              shoeId:
                  outfit
                      .shoes.id!,
              score:
                  outfit.score,
              wornAt:
                  DateTime.now(),
            ),
          ),
        );

    setState(() {
      outfitMarkedAsWorn =
          true;
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

  Widget _buildSectionTitle(
    String title,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 8,
      ),
      child: Text(
        title,
        style:
            const TextStyle(
          fontSize: 13,
          fontWeight:
              FontWeight.w800,
          letterSpacing: 1.2,
          color:
              Colors.black54,
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    if (isWeatherLoading) {
      return const Card(
        child: Padding(
          padding:
              EdgeInsets.all(
            20,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
              SizedBox(
                width: 12,
              ),
              Text(
                'Getting local weather...',
              ),
            ],
          ),
        ),
      );
    }

    if (weather == null) {
      Widget recoveryButton;

      if (locationPermissionPermanentlyDenied) {
        recoveryButton =
            OutlinedButton.icon(
          onPressed: () {
            _locationService
                .openAppSettings();
          },
          icon: const Icon(
            Icons.settings,
          ),
          label: const Text(
            'OPEN SETTINGS',
          ),
        );
      } else if (locationServiceDisabled) {
        recoveryButton =
            OutlinedButton.icon(
          onPressed: () {
            _locationService
                .openLocationSettings();
          },
          icon: const Icon(
            Icons
                .location_on_outlined,
          ),
          label: const Text(
            'TURN ON LOCATION',
          ),
        );
      } else {
        recoveryButton =
            OutlinedButton.icon(
          onPressed:
              loadWeather,
          icon: const Icon(
            Icons.refresh,
          ),
          label: const Text(
            'TRY AGAIN',
          ),
        );
      }

      return Card(
        child: Padding(
          padding:
              const EdgeInsets.all(
            16,
          ),
          child: Column(
            children: [
              const Icon(
                Icons
                    .location_off_outlined,
                size: 32,
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                locationMessage ??
                    'Weather unavailable',
                textAlign:
                    TextAlign.center,
              ),

              const SizedBox(
                height: 12,
              ),

              recoveryButton,
            ],
          ),
        ),
      );
    }

    return Container(
      padding:
          const EdgeInsets
              .symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color:
              Colors.black12,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
                const BoxDecoration(
              color:
                  Color(
                0xFFFFF0A6,
              ),
              shape:
                  BoxShape.circle,
            ),
            child: Icon(
              weather!.isRainy
                  ? Icons
                      .umbrella_outlined
                  : Icons
                      .wb_sunny_outlined,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  '${weather!.temperature.toStringAsFixed(1)}°C',
                  style:
                      const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  weather!.isRainy
                      ? 'Rainy • ${weather!.temperatureCategory}'
                      : '${weather!.temperatureCategory} • No rain',
                  style:
                      const TextStyle(
                    color:
                        Colors
                            .black54,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed:
                loadWeather,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final outfit =
        selectedOutfit;

    if (outfit == null) {
      return const SizedBox
          .shrink();
    }

    return AnimatedOpacity(
      duration:
          const Duration(
        milliseconds: 500,
      ),
      opacity:
          showMatchResult
              ? 1
              : 0,
      child: Container(
        padding:
            const EdgeInsets.all(
          20,
        ),
        decoration:
            BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
            22,
          ),
          border: Border.all(
            color:
                Colors.black12,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      'MATCH SCORE',
                      style:
                          TextStyle(
                        fontSize: 12,
                        color:
                            Colors
                                .black54,
                        fontWeight:
                            FontWeight
                                .w700,
                        letterSpacing:
                            1,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      '${outfit.score}%',
                      style:
                          const TextStyle(
                        fontSize: 32,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                  ],
                ),

                IconButton
                    .filledTonal(
                  onPressed:
                      saveFavoriteOutfit,
                  icon:
                      const Icon(
                    Icons
                        .favorite_border,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            Align(
              alignment:
                  Alignment
                      .centerLeft,
              child: Text(
                getMatchMessage(
                  outfit.score,
                ),
                style:
                    const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight
                          .w600,
                ),
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            Align(
              alignment:
                  Alignment
                      .centerLeft,
              child: Text(
                '$selectedOccasion • $selectedSeason',
                style:
                    const TextStyle(
                  color:
                      Colors
                          .black54,
                ),
              ),
            ),

            const SizedBox(
              height: 18,
            ),

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
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding:
            EdgeInsets.all(
          32,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,
          children: [
            Icon(
              Icons
                  .auto_awesome_outlined,
              size: 64,
              color:
                  Colors.black38,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Not enough clothing yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight
                        .w700,
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              'Add at least one top, one bottom, and one pair of shoes to generate an outfit.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return BlocBuilder<
        ClosetBloc,
        ClosetState>(
      builder:
          (context, state) {
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
            _tops(
          wardrobe,
        );

        final bottoms =
            _bottoms(
          wardrobe,
        );

        final shoes =
            _shoes(
          wardrobe,
        );

        final canGenerateOutfit =
            tops.isNotEmpty &&
                bottoms.isNotEmpty &&
                shoes.isNotEmpty;

        final safeTopIndex =
            tops.isEmpty
                ? 0
                : currentTopIndex
                    .clamp(
                      0,
                      tops.length -
                          1,
                    )
                    .toInt();

        final safeBottomIndex =
            bottoms.isEmpty
                ? 0
                : currentBottomIndex
                    .clamp(
                      0,
                      bottoms
                              .length -
                          1,
                    )
                    .toInt();

        final safeShoeIndex =
            shoes.isEmpty
                ? 0
                : currentShoeIndex
                    .clamp(
                      0,
                      shoes.length -
                          1,
                    )
                    .toInt();

        if (!canGenerateOutfit) {
          return Scaffold(
            appBar: AppBar(
              title:
                  const Text(
                'Outfit Picker',
              ),
            ),
            body:
                _buildEmptyState(),
          );
        }

        final currentTop =
            tops[
                safeTopIndex];

        final currentBottom =
            bottoms[
                safeBottomIndex];

        final currentShoe =
            shoes[
                safeShoeIndex];

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Outfit Picker',
            ),
          ),
          body: SafeArea(
            child:
                SingleChildScrollView(
              padding:
                  const EdgeInsets
                      .all(
                20,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                children: [
                  const Text(
                    'CLUELESS CLOSET',
                    style:
                        TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight
                              .w800,
                      letterSpacing:
                          2,
                      color:
                          Color(
                        0xFF9B7F00,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  const Text(
                    'Build your look',
                    style:
                        TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  const Text(
                    'Choose your plans and let your closet do the rest.',
                    style:
                        TextStyle(
                      fontSize: 14,
                      color:
                          Colors
                              .black54,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  _buildWeatherCard(),

                  const SizedBox(
                    height: 24,
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
                    height: 24,
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
                    height: 32,
                  ),

                  _buildSectionTitle(
                    'TOP',
                  ),

                  ClothingPicker(
                    item:
                        currentTop,
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
                    height: 28,
                  ),

                  _buildSectionTitle(
                    'BOTTOM',
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
                    height: 28,
                  ),

                  _buildSectionTitle(
                    'SHOES',
                  ),

                  ClothingPicker(
                    item:
                        currentShoe,
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
                    height: 32,
                  ),

                  _buildResult(),

                  const SizedBox(
                    height: 20,
                  ),

                  ElevatedButton.icon(
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
                    icon:
                        isPickingOutfit
                            ? const SizedBox
                                .shrink()
                            : const Icon(
                                Icons
                                    .auto_awesome,
                              ),
                    label:
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
                                'FIND MY OUTFIT',
                              ),
                  ),

                  const SizedBox(
                    height: 24,
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