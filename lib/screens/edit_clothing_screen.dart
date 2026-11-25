import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/clothing_item.dart';
import '../services/image_storage_service.dart';

class EditClothingScreen extends StatefulWidget {
  final ClothingItem item;

  const EditClothingScreen({
    super.key,
    required this.item,
  });

  @override
  State<EditClothingScreen> createState() => _EditClothingScreenState();
}

class _EditClothingScreenState extends State<EditClothingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final ImagePicker _imagePicker = ImagePicker();
  final ImageStorageService _imageStorageService = ImageStorageService();

  XFile? selectedImage;
  late String selectedCategory;
  late String selectedColor;

  late int warmthLevel;
  late bool rainSuitable;
  late bool waterResistant;

  bool isSaving = false;

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
    'khaki',
  ];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.item.name,
    );

    selectedCategory = widget.item.category;
    selectedColor = widget.item.color;

    warmthLevel = widget.item.warmthLevel;
    rainSuitable = widget.item.rainSuitable;
    waterResistant = widget.item.waterResistant;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 85,
    );

    if (image == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      selectedImage = image;
    });
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
          )
        );
      },
    );
  }

  Future<void> saveChanges() async {
    if (isSaving) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      String imagePath = widget.item.imagePath;
      bool isAssetImage = widget.item.isAssetImage;
      
      if (selectedImage != null) {
        imagePath = await _imageStorageService.saveImage(selectedImage!.path);
        isAssetImage = false;
      }

      final updatedItem = widget.item.copyWith(
        name: _nameController.text.trim(),
        category: selectedCategory,
        color: selectedColor,
        imagePath: imagePath,
        isAssetImage: isAssetImage,
        warmthLevel: warmthLevel,
        rainSuitable: rainSuitable,
        waterResistant: waterResistant,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, updatedItem);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not save the new image.',
          ),
        ),
      );
    }
  }

  String _warmthLabel(int level) {
    switch (level) {
      case 1:
        return 'Very light';
      case 2:
        return 'Light';
      case 3:
        return 'Medium';
      case 4:
        return 'Warm';
      case 5:
        return 'Very warm';
      default:
        return 'Medium';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (selectedImage != null) {
      imageWidget = Image.file(
        File(selectedImage!.path),
        fit: BoxFit.cover,
      );
    } else if (widget.item.isAssetImage) {
      imageWidget = Image.asset(
        widget.item.imagePath,
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = Image.file(
        File(widget.item.imagePath),
        fit: BoxFit.cover,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Clothing'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: isSaving
                    ? null
                    : showImageSourceOptions,
                child: SizedBox(
                  width: double.infinity,
                  height: 220,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: imageWidget,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                enabled: !isSaving,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
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
                onChanged: isSaving
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          selectedCategory = value;
                        });
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
                onChanged: isSaving
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          selectedColor = value;
                        });
                      },
              ),

              const SizedBox(height: 24),

              const Text(
                'Warmth Level',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Slider(
                value: warmthLevel.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: warmthLevel.toString(),
                onChanged: isSaving
                    ? null
                    : (value) {
                        setState(() {
                          warmthLevel = value.round();
                        });
                      },
              ),

              Text(
                _warmthLabel(warmthLevel),
              ),

              const SizedBox(height: 12),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Suitable for rain'),
                subtitle: const Text(
                  'Comfortable to wear in rainy conditions',
                ),
                value: rainSuitable,
                onChanged: isSaving
                    ? null
                    : (value) {
                        setState(() {
                          rainSuitable = value;
                        });
                      },
              ),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Water resistant'),
                subtitle: const Text(
                  'The item can resist light water exposure',
                ),
                value: waterResistant,
                onChanged: isSaving
                    ? null
                    : (value) {
                        setState(() {
                          waterResistant = value;
                        });
                      },
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : saveChanges,
                child: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('SAVE CHANGES'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}