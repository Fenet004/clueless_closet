import 'package:flutter/material.dart';
import '../models/clothing_item.dart';

class AddClothingScreen extends StatefulWidget {
  const AddClothingScreen({super.key});

  @override
  State<AddClothingScreen> createState() => _AddClothingScreenState();
}

class _AddClothingScreenState extends State<AddClothingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  String? selectedCategory;
  String? selectedColor;

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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose;
  }

  void saveClothingItem() {
    if (_formKey.currentState!.validate()) {
      final newItem = ClothingItem(
        name: _nameController.text.trim(),
        category: selectedCategory!,
        color: selectedColor!,
        imagePath: 'assets/images/placeholder.png',
      );

      Navigator.pop(context, newItem);
    }
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