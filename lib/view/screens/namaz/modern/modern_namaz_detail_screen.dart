import '../namaz_detail_screen.dart';

class ModernNamazDetailScreen extends NamazDetailScreen {
  const ModernNamazDetailScreen({
    super.key,
    required super.item,
    required super.controller,
  }) : super(modern: true);
}
