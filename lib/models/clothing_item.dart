class ClothingItem {
  final int? id;
  final String name;
  final String category;
  final String color;
  final String imagePath;
  final bool isAssetImage;
  final String style;
  final String occasion;
  final String season;

  ClothingItem({
    this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.imagePath,
    required this.style,
    required this.occasion,
    required this.season,
    this.isAssetImage = true,
  });

  ClothingItem copyWith({
    int? id,
    String? name,
    String? category,
    String? color,
    String? imagePath,
    bool? isAssetImage,
    String? style,
    String? occasion,
    String? season,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
      imagePath: imagePath ?? this.imagePath,
      isAssetImage: isAssetImage ?? this.isAssetImage,
      style: style ?? this.style,
      occasion: occasion ?? this.occasion,
      season: season ?? this.season,
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
      'style': style,
      'occasion': occasion,
      'season': season,
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
      style: map['style'] as String,
      occasion: map['occasion'] as String,
      season: map['season'] as String,
    );
  }
}