class ClothingItem {
  final String name;
  final String category;
  final String color;
  final String imagePath;
  final bool isAssetImage;

  ClothingItem({
    required this.name,
    required this.category,
    required this.color,
    required this.imagePath,
    this.isAssetImage = true,
  });

  ClothingItem copyWith({
    String? name,
    String? category,
    String? color,
    String? imagePath,
    bool? isAssetImage,
  }) {
    return ClothingItem(
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
      imagePath: imagePath ?? this.imagePath,
      isAssetImage: isAssetImage ?? this.isAssetImage,
    );
  }
}