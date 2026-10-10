import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/clothing_item.dart';
import '../services/image_storage_service.dart';

class AddClothingScreen extends StatefulWidget {
  const AddClothingScreen({super.key});

  @override
  State<AddClothingScreen> createState() => _AddClothingScreenState();
}

class _AddClothingScreenState extends State<AddClothingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final ImageStorageService _imageStorageService = ImageStorageService();
  
  XFile? selectedImage;
  String? selectedCategory;
  String? selectedColor;
  String? selectedStyle;
  String? selectedOccasion;
  String? selectedSeason;

  final List<String> categories = [
    'Top',
    'Bottom',
    'Shoes',
  ];

  final List<String> colors = [
    'Black',
    'White',
    'Blue',
    'Red',
    'Green',
    'Gray',
    'Brown',
    'Khaki',
  ];

  final List<String> styles = [
    'Casual',
    'Formal',
    'Sport',
    'Streetwear',
  ];

  final List<String> occasions = [
    'Everyday',
    'Work',
    'Party',
    'Date',
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
  void dispose() {
    _nameController.dispose();
    super.dispose;
  }

  Future<void> saveClothingItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a clothing image',
          ),
        ),
      );

      return;
    }

    final permanentImagePath = await _imageStorageService.saveImage(
      selectedImage!.path,
    );
    
    final newItem = ClothingItem(
      name: _nameController.text.trim(),
      category: selectedCategory!,
      color: selectedColor!,
      imagePath: permanentImagePath,
      isAssetImage: false,
      style: selectedStyle!,
      occasion: selectedOccasion!,
      season: selectedSeason!,
    );

    if (!mounted) {
      return;
    }

    Navigator.pop(context, newItem);
  }

  Future<void> pickImage(ImageSource source) async {
    try{
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) {
        return;
      }

      setState(() {
        selectedImage = image;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not access the image. Please try again.',
          ),
        ),
      );
    }
    
  }

  void showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);

                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose From Gallery'),
                onTap: () {
                  Navigator.pop(context);

                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Clothing'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: showImageSourceOptions,
                child: Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: selectedImage == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 52
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Add clothing photo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Take a photo or choose from gallery',
                            ),
                          ],
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                File(selectedImage!.path),
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                child: Icon(
                                  Icons.edit,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Clothing name',
                  hintText: 'Example: Black Hoodie',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a clothing name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: selectedColor,
                decoration: const InputDecoration(
                  labelText: 'Color',
                  border: OutlineInputBorder(),
                ),
                items: colors.map((color) {
                  return DropdownMenuItem(
                    value: color,
                    child: Text(color),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedColor = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a color';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: selectedStyle,
                decoration: const InputDecoration(
                  labelText: 'Style',
                  border: OutlineInputBorder(),
                ),
                items: styles.map((style) {
                  return DropdownMenuItem(
                    value: style,
                    child: Text(style),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStyle = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a style';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: selectedOccasion,
                decoration: const InputDecoration(
                  labelText: 'Occasion',
                  border: OutlineInputBorder(),
                ),
                items: occasions.map((occasion) {
                  return DropdownMenuItem(
                    value: occasion,
                    child: Text(occasion),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedOccasion = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select an occasion';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: selectedSeason,
                decoration: const InputDecoration(
                  labelText: 'Season',
                  border: OutlineInputBorder(),
                ),
                items: seasons.map((season) {
                  return DropdownMenuItem(
                    value: season,
                    child: Text(season),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSeason = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a season';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveClothingItem,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('ADD TO WARDROBE'),
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