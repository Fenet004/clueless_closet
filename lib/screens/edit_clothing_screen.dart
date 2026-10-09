import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/clothing_item.dart';

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

  XFile? selectedImage;
  late String selectedCategory;
  late String selectedColor;

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

  void saveChanges() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedItem = widget.item.copyWith(
      name: _nameController.text.trim(),
      category: selectedCategory,
      color: selectedColor,
      imagePath: selectedImage?.path ?? widget.item.imagePath,
      isAssetImage: selectedImage == null ? widget.item.isAssetImage : false,
    );

    Navigator.pop(context, updatedItem);
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
            children: [
              GestureDetector(
                onTap: showImageSourceOptions,
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
                onChanged: (value) {
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
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    selectedColor = value;
                  });
                },
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveChanges,
                  child: const Text(
                    'SAVE CHANGES',
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