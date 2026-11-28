import 'package:flutter/material.dart';
import 'package:nazar_e_alam/view/screens/collections/collection_screen.dart';

class DuaScreen extends StatelessWidget {
  final bool appBackButton;
  const DuaScreen({super.key, required this.appBackButton});
  @override
  Widget build(BuildContext context) => CollectionScreen(
    dhikr: false,
    modern: false,
    appBackButton: appBackButton,
  );
}
