class DzikirModel {
  int currentCount;
  final int targetCount;
  final String title;           // Subhanallah, Alhamdulillah, dll
  final String arabic;          // teks Arab
  final String translation;     // arti dalam bahasa Indonesia

  DzikirModel({
    this.currentCount = 0,
    this.targetCount = 33,
    required this.title,
    required this.arabic,
    required this.translation,
  });

  DzikirModel copyWith({
    int? currentCount,
  }) {
    return DzikirModel(
      currentCount: currentCount ?? this.currentCount,
      targetCount: targetCount,
      title: title,
      arabic: arabic,
      translation: translation,
    );
  }

  bool get isCompleted => currentCount >= targetCount;

  double get progress => currentCount / targetCount;
}