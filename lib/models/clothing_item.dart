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
}