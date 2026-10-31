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
  final int warmthLevel;
  final bool rainSuitable;
  final bool waterResistant;

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
    required this.warmthLevel,
    required this.rainSuitable,
    required this.waterResistant,
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
    int? warmthLevel,
    bool? rainSuitable,
    bool? waterResistant,
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
      warmthLevel: warmthLevel ?? this.warmthLevel,
      rainSuitable: rainSuitable ?? this.rainSuitable,
      waterResistant: waterResistant ?? this.waterResistant,
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
      'warmthLevel': warmthLevel,
      'rainSuitable': rainSuitable ? 1 : 0,
      'waterResistant': waterResistant ? 1 : 0,
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
      warmthLevel: map['warmthLevel'] as int,
      rainSuitable: map['rainSuitable'] == 1,
      waterResistant: map['waterResistant'] == 1,
    );
  }
}