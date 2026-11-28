// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../controller/localization_controller.dart';
import '../../../controller/prayer_time_controller.dart';
import '../../../controller/internet_check_controller.dart';
import '../../../util/app_constants.dart';
import '../../../util/images.dart';

class LanguageOnboarding extends StatefulWidget {
  const LanguageOnboarding({super.key, required this.child});
  final Widget child;
  @override
  State<LanguageOnboarding> createState() => _LanguageOnboardingState();
}

class _LanguageOnboardingState extends State<LanguageOnboarding> {
  static const _key = 'language_onboarding_seen_v1';
  static const delay = Duration(seconds: 10);
  static bool _showing = false;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  final _prefs = Get.find<SharedPreferences>();
  @override
  void initState() {
    super.initState();
    if (!_prefs.containsKey(AppConstants.LANGUAGE_CODE) &&
        !(_prefs.getBool(_key) ?? false)) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  Future<void> _tick() async {
    if (!mounted || _showing) return;
    if ((_prefs.getBool(_key) ?? false) ||
        _prefs.containsKey(AppConstants.LANGUAGE_CODE)) {
      _timer?.cancel();
      return;
    }
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed ||
        ModalRoute.of(context)?.isCurrent != true ||
        Get.isDialogOpen == true ||
        Get.isBottomSheetOpen == true ||
        Get.find<PrayerTimeController>().isprayerTimeLoading.value ||
        !Get.find<InternetController>().hasInternet.value ||
        Get.find<LocalizationController>().allLanguages.isEmpty)
      return;
    _elapsed += const Duration(seconds: 1);
    if (_elapsed < delay) return;
    _showing = true;
    _timer?.cancel();
    try {
      final selected = await showModalBottomSheet<int>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const _LanguageSheet(),
      );
      await _prefs.setBool(_key, true);
      if (selected != null) {
        final language = AppConstants.languages[selected];
        Get.find<LocalizationController>().setLanguage(
          Locale(language.languageCode!, language.countryCode),
          selected,
        );
      }
    } finally {
      _showing = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _LanguageSheet extends StatefulWidget {
  const _LanguageSheet();
  @override
  State<_LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends State<_LanguageSheet> {
  late int _selected = Get.find<LocalizationController>().selectedIndex;
  static const _native = {
    'en': 'English',
    'hi': 'हिन्दी',
    'guj': 'ગુજરાતી',
    'ar': 'العربية',
    'sw': 'Kiswahili',
    'ur': 'اردو',
  };
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.primaryColor;
    final languages = AppConstants.languages;
    return Material(
      color: theme.scaffoldBackgroundColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(.12),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: SvgPicture.asset(
                    Images.Icon_select_language,
                    width: 52,
                    height: 52,
                    color: accent,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Choose your language',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Make Nazar E Aalam feel like home.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<int>(
                value: _selected,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'App language',
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                items: List.generate(
                  languages.length,
                  (i) => DropdownMenuItem(
                    value: i,
                    child: Row(
                      children: [
                        Image.asset(
                          languages[i].imageUrl!,
                          width: 30,
                          height: 24,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${_native[languages[i].languageCode] ?? languages[i].languageName} · ${languages[i].languageName}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onChanged: (v) {
                  if (v != null) setState(() => _selected = v);
                },
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Change anytime',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SvgPicture.asset(
                          Images.Icon_app_setting,
                          width: 25,
                          height: 25,
                          color: accent,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text('settings'.tr)),
                        const Icon(Icons.chevron_right),
                        SvgPicture.asset(
                          Images.Icon_select_language,
                          width: 25,
                          height: 25,
                          color: accent,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text('language_settings'.tr)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(_selected),
                child: const Text('Continue'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Not now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
