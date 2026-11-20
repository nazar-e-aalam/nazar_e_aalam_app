// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'fateha_screen.dart';
import 'modern/modern_fateha_screen.dart';

/// Route to the correct screen from the existing Classic/Modern home layout.
/// Pass modern: true from Modern Home and false from Classic Home.
/// This avoids depending on an unverified HomeLayoutController getter.
class FatehaWrapper extends StatelessWidget {
  final bool appBackButton;
  final bool modern;

  const FatehaWrapper({
    super.key,
    this.appBackButton = true,
    this.modern = false,
  });

  @override
  Widget build(BuildContext context) {
    return modern
        ? ModernFatehaScreen(appBackButton: appBackButton)
        : FatehaScreen(
            appBackButton: appBackButton,
            layout: FatehaLayout.classic,
          );
  }
}
