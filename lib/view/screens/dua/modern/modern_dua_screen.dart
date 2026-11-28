// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:nazar_e_alam/view/screens/collections/collection_screen.dart';

class ModernDuaScreen extends StatelessWidget {
  final bool appBackButton;
  const ModernDuaScreen({super.key, required this.appBackButton});
  @override
  Widget build(BuildContext context) => CollectionScreen(
    dhikr: false,
    modern: true,
    appBackButton: appBackButton,
  );
}
