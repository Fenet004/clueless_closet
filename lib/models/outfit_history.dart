class OutfitHistory {
  final int? id;
  final int topId;
  final int bottomId;
  final int shoeId;
  final int score;
  final DateTime wornAt;

  OutfitHistory({
    this.id,
    required this.topId,
    required this.bottomId,
    required this.shoeId,
    required this.score,
    required this.wornAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topId': topId,
      'bottomId': bottomId,
      'shoeId': shoeId,
      'score': score,
      'wornAt': wornAt.toIso8601String(),
    };
  }

  factory OutfitHistory.fromMap(Map<String, dynamic> map) {
    return OutfitHistory(
      id: map['id'] as int,
      topId: map['topId'] as int,
      bottomId: map['bottomId'] as int,
      shoeId: map['shoeId'] as int,
      score: map['score'] as int,
      wornAt: DateTime.parse(map['wornAt'] as String),
    );
  }

  OutfitHistory copyWith({
    int? id,
    int? topId,
    int? bottomId,
    int? shoeId,
    int? score,
    DateTime? wornAt,
  }) {
    return OutfitHistory(
      id: id ?? this.id,
      topId: topId ?? this.topId,
      bottomId: bottomId ?? this.bottomId,
      shoeId: shoeId ?? this.shoeId,
      score: score ?? this.score,
      wornAt: wornAt ?? this.wornAt,
    );
  }
}