import 'package:flutter/widgets.dart';
import '../dua_book_screen.dart';

class ModernDuaBookScreen extends StatelessWidget {
  final bool? appBackButton;
  const ModernDuaBookScreen({super.key, this.appBackButton});
  @override
  Widget build(BuildContext context) =>
      DuaBookScreen(appBackButton: appBackButton, modern: true);
}
