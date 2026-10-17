class SavedOutfit {
  final int? id;
  final int topId;
  final int bottomId;
  final int shoeId;
  final int score;

  SavedOutfit({
    this.id,
    required this.topId,
    required this.bottomId,
    required this.shoeId,
    required this.score,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topId': topId,
      'bottomId': bottomId,
      'shoeId': shoeId,
      'score': score,
    };
  }

  factory SavedOutfit.fromMap(Map<String, dynamic> map) {
    return SavedOutfit(
      id: map['id'] as int,
      topId: map['topId'] as int,
      bottomId: map['bottomId'] as int,
      shoeId: map['shoeId'] as int,
      score: map['score'] as int,
    );
  }

  SavedOutfit copyWith({
    int? id,
    int? topId,
    int? bottomId,
    int? shoeId,
    int? score,
  }) {
    return SavedOutfit(
      id: id ?? this.id,
      topId: topId ?? this.topId,
      bottomId: bottomId ?? this.bottomId,
      shoeId: shoeId ?? this.shoeId,
      score: score ?? this.score,
    );
  }
}