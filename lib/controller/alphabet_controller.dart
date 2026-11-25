import 'package:flutter/rendering.dart';
import 'package:stts/stts.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlphabetController extends GetxController implements GetxService {
  final Tts _tts = Tts();

  final List<String> letters = const [
    'ا',
    'ب',
    'ت',
    'ث',
    'ج',
    'ح',
    'خ',
    'د',
    'ذ',
    'ر',
    'ز',
    'س',
    'ش',
    'ص',
    'ض',
    'ط',
    'ظ',
    'ع',
    'غ',
    'ف',
    'ق',
    'ك',
    'ل',
    'م',
    'ن',
    'ه',
    'و',
    'ي',
  ];

  final availableVoices = <TtsVoice>[].obs;
  final selectedVoice = Rxn<TtsVoice>();

  final pitch = 1.0.obs;
  final rate = 0.4.obs;

  final voiceDisplayNames = <String, String>{}.obs;

  bool _initialized = false;

  @override
  void onInit() {
    super.onInit();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      pitch.value = prefs.getDouble('tts_pitch') ?? 1.0;
      rate.value = prefs.getDouble('tts_rate') ?? 0.4;

      final savedVoiceId = prefs.getString('tts_voice');

      final supported = await _tts.isSupported();
      if (!supported) return;

      await _tts.setLanguage('ar');
      await _tts.setPitch(pitch.value);
      await _tts.setRate(rate.value);

      final voices = await _tts.getVoicesByLanguage('ar');

      availableVoices.assignAll(voices);

      voiceDisplayNames.clear();

      for (var i = 0; i < voices.length; i++) {
        voiceDisplayNames[voices[i].id] = 'Voice ${i + 1}';
      }

      if (voices.isNotEmpty) {
        final savedVoice = voices.firstWhereOrNull(
          (voice) => voice.id == savedVoiceId,
        );

        await setVoice(savedVoice ?? voices.first, save: false);
      }

      _initialized = true;
    } catch (e) {
      debugPrint('TTS initialization error: $e');
    }
  }

  Future<void> setVoice(TtsVoice voice, {bool save = true}) async {
    selectedVoice.value = voice;

    await _tts.setVoice(voice.id);

    if (save) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tts_voice', voice.id);
    }
  }

  Future<void> setPitch(double value) async {
    pitch.value = value;
    await _tts.setPitch(value);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_pitch', value);
  }

  Future<void> setRate(double value) async {
    rate.value = value;
    await _tts.setRate(value);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_rate', value);
  }

  Future<void> speak(String text) async {
    if (!_initialized || text.trim().isEmpty) return;

    try {
      await _tts.stop();
      await _tts.start(text);
    } catch (e) {
      debugPrint('TTS speaking error: $e');
    }
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('tts_pitch');
    await prefs.remove('tts_rate');
    await prefs.remove('tts_voice');

    pitch.value = 1.0;
    rate.value = 0.4;

    await _tts.setPitch(1.0);
    await _tts.setRate(0.4);

    if (availableVoices.isNotEmpty) {
      await setVoice(availableVoices.first, save: false);
    }
  }

  @override
  void onClose() {
    _tts.dispose();
    super.onClose();
  }
}
