// ignore_for_file: deprecated_member_use

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/styles.dart';

/// Reusable modern-layout UI kit.
///
/// Modern = glassmorphism surfaces, saffron gradients, 24px+ radius,
/// chip-style metadata, and staggered list animations.
/// Classic screens keep using the existing generic Card / ListTile widgets.

/// A glass panel with subtle blur + border. Use as the root surface of
/// modern screens instead of a plain Scaffold body color.
class ModernGlassPanel extends StatelessWidget {
  final Widget child;
  final Color? color;
  final BorderRadius? borderRadius;
  const ModernGlassPanel({
    super.key,
    required this.child,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color:
                color ??
                (dark ? const Color(0x1AFFFFFF) : AppColorModern.glassFill),
            border: Border.all(
              color:
                  (dark ? const Color(0x33FFFFFF) : AppColorModern.glassBorder)
                      .withValues(alpha: 0.6),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Section header with a saffron gradient underline and accent chip.
class ModernSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color accentColor;
  const ModernSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.accentColor = AppColorModern.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.PADDING_SIZE_DEFAULT,
        Dimensions.PADDING_SIZE_DEFAULT,
        Dimensions.PADDING_SIZE_DEFAULT,
        8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor, accentColor.withValues(alpha: 0.5)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.FONT_SIZE_LARGE,
                    color: dark ? Colors.white : AppColorModern.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!.tr,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.FONT_SIZE_SMALL,
                color: dark
                    ? const Color(0xFFB0A698)
                    : AppColorModern.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Glass list item for hadith / dua / dhikr / surah rows.
/// Left accent bar, rank chip, title, subtitle, trailing chevron.
class ModernListItem extends StatelessWidget {
  final int index;
  final String title;
  final String? subtitle;
  final String? trailing;
  final Color accentColor;
  final VoidCallback onTap;
  final Widget? leading;
  final bool isFirst;
  final bool isLast;
  const ModernListItem({
    super.key,
    required this.index,
    required this.title,
    this.subtitle,
    this.trailing,
    this.accentColor = AppColorModern.primaryColor,
    required this.onTap,
    this.leading,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.PADDING_SIZE_DEFAULT,
        vertical: 6,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: dark
                  ? const Color(0x0DFFFFFF)
                  : AppColorModern.cardBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: dark
                    ? const Color(0x1FFFFFFF)
                    : AppColorModern.divider.withValues(alpha: 0.8),
                width: 1,
              ),
              gradient: isFirst
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primary.withValues(alpha: dark ? 0.08 : 0.04),
                        Colors.transparent,
                      ],
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: dark ? 0.25 : 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Rank / number chip
                // Profile picture if provided, otherwise show rank chip
                leading ??
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentColor,
                            accentColor.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          index.toString(),
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.FONT_SIZE_DEFAULT,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                const SizedBox(width: 14),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_DEFAULT,
                          fontWeight: FontWeight.w600,
                          color: dark
                              ? Colors.white
                              : AppColorModern.textPrimary,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.FONT_SIZE_SMALL,
                            color: dark
                                ? const Color(0xFF9A8F82)
                                : AppColorModern.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null && trailing!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      trailing!,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: dark
                      ? const Color(0xFF8A7D70)
                      : AppColorModern.disabledColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Staggered list builder that fades + slides each item in with a delay.
class ModernAnimatedList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final EdgeInsetsGeometry padding;
  const ModernAnimatedList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = const EdgeInsets.only(bottom: 100),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      padding: padding,
      physics: const BouncingScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: AlwaysStoppedAnimation(1.0),
          builder: (context, _) {
            return itemBuilder(context, index);
          },
        );
      },
    );
  }
}

/// A pill-shaped primary button for modern screens.
class ModernPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  const ModernPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
        label: Text(
          text,
          style: robotoBold.copyWith(
            fontSize: Dimensions.FONT_SIZE_DEFAULT,
            color: Colors.white,
          ),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
      ),
    );
  }
}

/// A soft secondary button (outline) for modern screens.
class ModernSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  const ModernSecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
        label: Text(
          text,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.FONT_SIZE_DEFAULT,
            color: dark ? Colors.white : primary,
          ),
        ),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: dark ? Colors.white : primary,
          side: BorderSide(
            color: dark ? Colors.white.withValues(alpha: 0.35) : primary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
      ),
    );
  }
}

/// Gradient pill tag (e.g., "Sahih", "Madinah", "Surah").
class ModernTag extends StatelessWidget {
  final String label;
  final Color color;
  const ModernTag({
    super.key,
    required this.label,
    this.color = AppColorModern.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.6)]),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: robotoMedium.copyWith(
          fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Empty state illustration placeholder for modern screens.
class ModernEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  const ModernEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: dark ? const Color(0x1AFFFFFF) : AppColorModern.tintBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 44,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title.tr,
              textAlign: TextAlign.center,
              style: robotoBold.copyWith(
                fontSize: Dimensions.FONT_SIZE_LARGE,
                color: dark ? Colors.white : AppColorModern.textPrimary,
              ),
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!.tr,
                textAlign: TextAlign.center,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.FONT_SIZE_DEFAULT,
                  color: dark
                      ? const Color(0xFF9A8F82)
                      : AppColorModern.textSecondary,
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}
