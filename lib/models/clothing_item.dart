class ClothingItem {
  final int? id;
  final String name;
  final String category;
  final String color;
  final String imagePath;
  final bool isAssetImage;

  ClothingItem({
    this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.imagePath,
    this.isAssetImage = true,
  });

  ClothingItem copyWith({
    int? id,
    String? name,
    String? category,
    String? color,
    String? imagePath,
    bool? isAssetImage,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
      imagePath: imagePath ?? this.imagePath,
      isAssetImage: isAssetImage ?? this.isAssetImage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'color': color,
      'imagePath': imagePath,
      'isAssetImage': isAssetImage ? 1: 0,
    };
  }

  factory ClothingItem.fromMap(Map<String, dynamic> map) {
    return ClothingItem(
      id: map['id'] as int,
      name: map['name'] as String,
      category: map['category'] as String,
      color: map['color'] as String,
      imagePath: map['imagePath'] as String,
      isAssetImage: map['isAssetImage'] == 1,
    );
  }
}