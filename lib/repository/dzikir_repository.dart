import 'package:shared_preferences/shared_preferences.dart';
import '../model/dzikir_model.dart';

class DzikirRepository {
  static const String _prefCountKey = 'dzikir_current_count';
  static const String _prefTypeKey = 'dzikir_selected_type_index';

  final List<DzikirModel> _defaultDzikirs = [
    DzikirModel(
      title: 'Istighfar',
      arabic: 'أَسْتَغْفِرُ اللهَ',
      translation: 'Aku memohon ampun kepada Allah',
      targetCount: 33,
    ),
    DzikirModel(
      title: 'Subhanallah',
      arabic: 'سُبْحَانَ اللهِ',
      translation: 'Maha Suci Allah',
      targetCount: 33,
    ),
    DzikirModel(
      title: 'Alhamdulillah',
      arabic: 'الْحَمْدُ لِلَّهِ',
      translation: 'Segala puji bagi Allah',
      targetCount: 33,
    ),
    DzikirModel(
      title: 'Allahu Akbar',
      arabic: 'اللهُ أَكْبَرُ',
      translation: 'Allah Maha Besar',
      targetCount: 33,
    ),
    DzikirModel(
      title: 'Tahlil',
      arabic: 'لَا إِلَهَ إِلَّا اللهُ',
      translation: 'Tiada Tuhan selain Allah',
      targetCount: 33,
    ),
    DzikirModel(
      title: 'Shalawat',
      arabic: 'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ',
      translation: 'Ya Allah, limpahkanlah rahmat kepada junjungan kami Nabi Muhammad',
      targetCount: 100,
    ),
    DzikirModel(
      title: 'Hauqolah',
      arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ',
      translation: 'Tiada daya dan upaya kecuali dengan kekuatan Allah',
      targetCount: 33,
    ),
  ];

  Future<DzikirModel> getCurrentDzikir() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_prefCountKey) ?? 0;
    final typeIndex = prefs.getInt(_prefTypeKey) ?? 0;

    final index = typeIndex.clamp(0, _defaultDzikirs.length - 1);
    final selected = _defaultDzikirs[index];

    return selected.copyWith(currentCount: count);
  }

  Future<void> saveCurrentCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefCountKey, count);
  }

  Future<void> saveSelectedType(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefTypeKey, index);
  }

  Future<void> resetCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefCountKey);
  }

  List<DzikirModel> get defaultDzikirs => List.unmodifiable(_defaultDzikirs);
}