import 'package:flutter/material.dart';
import 'package:nazar_e_alam/view/screens/collections/collection_screen.dart';

class ModernDhikrScreen extends StatelessWidget {
  final bool appBackButton;
  const ModernDhikrScreen({super.key, required this.appBackButton});
  @override
  Widget build(BuildContext context) =>
      CollectionScreen(dhikr: true, modern: true, appBackButton: appBackButton);
}
