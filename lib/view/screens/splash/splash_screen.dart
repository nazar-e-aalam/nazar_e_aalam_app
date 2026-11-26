// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:get/get.dart';

// import 'package:nazar_e_alam/controller/prayer_time_controller.dart';
// import 'package:nazar_e_alam/controller/splash_controller.dart';
import 'package:nazar_e_alam/util/app_constants.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/theme/light_theme.dart';

// import 'dart:math' as math;
// import 'dart:ui' as ui;

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/scheduler.dart';

// import 'package:nazar_e_alam/util/app_constants.dart';
// import 'package:nazar_e_alam/util/dimensions.dart';
// import 'package:nazar_e_alam/util/images.dart';
// import 'package:nazar_e_alam/util/styles.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback? onCompleted;

  const SplashScreen({super.key, this.onCompleted});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final CurvedAnimation _textAnimation;

  ui.Image? _logoImage;
  PixelLogoPainter? _pixelPainter;
  bool _completed = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _textAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _startAnimation();
    });
  }

  Future<void> _startAnimation() async {
    try {
      final logo = await _loadLogo();

      if (!mounted) {
        logo.dispose();
        return;
      }

      final painter = PixelLogoPainter(
        image: logo,
        animation: _animationController,
        logoSize: 120,
        columns: 24,
      );

      setState(() {
        _logoImage = logo;
        _pixelPainter = painter;
      });
    } catch (e) {
      debugPrint('Splash logo loading error: $e');
    }

    if (!mounted) return;

    try {
      if (MediaQuery.of(context).disableAnimations) {
        _animationController.value = 1.0;
      } else {
        await _animationController.forward().orCancel;
      }

      await Future<void>.delayed(const Duration(milliseconds: 250));

      _finish();
    } on TickerCanceled {
      // Animation disposed.
    } catch (e) {
      debugPrint('Splash animation error: $e');

      _finish();
    }
  }

  void _finish() {
    if (!mounted || _completed) return;

    _completed = true;

    widget.onCompleted?.call();
  }

  Future<ui.Image> _loadLogo() async {
    final data = await rootBundle.load(Images.APP_LOGO);

    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      targetWidth: 256,
    );

    try {
      final frame = await codec.getNextFrame();

      return frame.image;
    } finally {
      codec.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RepaintBoundary(
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: _logoImage != null
                      ? CustomPaint(
                          painter: _pixelPainter!,
                          isComplex: false,
                          willChange: true,
                        )
                      : FadeTransition(
                          opacity: _animationController,
                          child: Center(
                            child: Image.asset(
                              Images.APP_LOGO,
                              width: 120,
                              height: 120,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                ),
              ),

              Transform.translate(
                offset: const Offset(0, -42),
                child: FadeTransition(
                  opacity: _textAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.25),
                      end: Offset.zero,
                    ).animate(_textAnimation),
                    child: Text(
                      AppConstants.APP_NAME,
                      textAlign: TextAlign.center,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_OVER_LARGE,
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textAnimation.dispose();
    _animationController.dispose();
    _logoImage?.dispose();

    super.dispose();
  }
}

// Keep PixelLogoPainter and _LogoPixel below this.// ============================================================
// PIXEL LOGO PAINTER
// ============================================================

// ============================================================
// OPTIMIZED PIXEL LOGO PAINTER
// ============================================================

class PixelLogoPainter extends CustomPainter {
  final ui.Image image;
  final Animation<double> animation;
  final double logoSize;
  final int columns;

  late final List<_LogoPixel> _pixels;

  // Reusable typed buffers.
  late final Float32List _transforms;
  late final Float32List _rects;
  late final Int32List _colors;

  late final double _imageScale;
  late final double _logoWidth;
  late final double _logoHeight;
  late final Rect _sourceRect;

  final Paint _atlasPaint = Paint()
    ..isAntiAlias = false
    ..filterQuality = FilterQuality.low;

  final Paint _finalPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.medium;

  PixelLogoPainter({
    required this.image,
    required this.animation,
    this.logoSize = 120,
    this.columns = 24,
  }) : super(repaint: animation) {
    _initialize();
  }

  // ==================== INITIALIZATION ====================

  void _initialize() {
    final imageWidth = image.width.toDouble();
    final imageHeight = image.height.toDouble();

    _imageScale = logoSize / math.max(imageWidth, imageHeight);

    _logoWidth = imageWidth * _imageScale;
    _logoHeight = imageHeight * _imageScale;

    _sourceRect = Rect.fromLTWH(0, 0, imageWidth, imageHeight);

    _pixels = _generatePixels();

    final count = _pixels.length;

    _transforms = Float32List(count * 4);
    _rects = Float32List(count * 4);
    _colors = Int32List(count);

    // Source rectangles never change.
    for (int i = 0; i < count; i++) {
      final pixel = _pixels[i];
      final index = i * 4;

      _rects[index] = pixel.source.left;
      _rects[index + 1] = pixel.source.top;
      _rects[index + 2] = pixel.source.right;
      _rects[index + 3] = pixel.source.bottom;
    }
  }

  // ==================== GENERATE PIXELS ====================

  List<_LogoPixel> _generatePixels() {
    final random = math.Random(42);
    final pixels = <_LogoPixel>[];

    final width = image.width;
    final height = image.height;

    final cellSize = math.max(1, (width / columns).ceil());

    for (int top = 0; top < height; top += cellSize) {
      for (int left = 0; left < width; left += cellSize) {
        final right = math.min(left + cellSize, width);
        final bottom = math.min(top + cellSize, height);

        final source = Rect.fromLTRB(
          left.toDouble(),
          top.toDouble(),
          right.toDouble(),
          bottom.toDouble(),
        );

        final angle = random.nextDouble() * math.pi * 2;

        // Shorter movement makes the assembly more controlled.
        final distance = 25.0 + random.nextDouble() * 65.0;

        // Slight top-to-bottom stagger.
        final verticalDelay = (top / height) * 0.15;

        pixels.add(
          _LogoPixel(
            source: source,

            centerX: source.center.dx * _imageScale,
            centerY: source.center.dy * _imageScale,

            offsetX: math.cos(angle) * distance,
            offsetY: math.sin(angle) * distance,

            delay: verticalDelay + random.nextDouble() * 0.15,

            // Subtle rotation instead of excessive spinning.
            rotation: (random.nextDouble() - 0.5) * 0.9,
          ),
        );
      }
    }

    return pixels;
  }

  // ==================== RENDER ====================

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;

    final originX = (size.width - _logoWidth) * 0.5;
    final originY = (size.height - _logoHeight) * 0.5;

    // Draw only the sharp original logo once assembled.
    if (progress >= 0.88) {
      canvas.drawImageRect(
        image,
        _sourceRect,
        Rect.fromLTWH(originX, originY, _logoWidth, _logoHeight),
        _finalPaint,
      );

      return;
    }

    for (int i = 0; i < _pixels.length; i++) {
      final pixel = _pixels[i];
      final index = i * 4;

      final t = ((progress - pixel.delay) / 0.58).clamp(0.0, 1.0).toDouble();

      if (t <= 0.0) {
        _transforms[index] = 0;
        _transforms[index + 1] = 0;
        _transforms[index + 2] = 0;
        _transforms[index + 3] = 0;

        _colors[i] = 0x00FFFFFF;
        continue;
      }

      // Fast easeOutQuart calculation.
      // Avoids math.pow() and curve objects per pixel.
      final inverse = 1.0 - t;
      final squared = inverse * inverse;
      final remaining = squared * squared;
      final eased = 1.0 - remaining;

      final scale = _imageScale * (0.65 + 0.35 * eased);

      final rotation = pixel.rotation * remaining;

      final scos = math.cos(rotation) * scale;
      final ssin = math.sin(rotation) * scale;

      final centerX = originX + pixel.centerX + pixel.offsetX * remaining;

      final centerY = originY + pixel.centerY + pixel.offsetY * remaining;

      final halfWidth = pixel.source.width * 0.5;
      final halfHeight = pixel.source.height * 0.5;

      // RSTransform:
      // [scaledCos, scaledSin, translateX, translateY]
      _transforms[index] = scos;
      _transforms[index + 1] = ssin;

      _transforms[index + 2] = centerX - scos * halfWidth + ssin * halfHeight;

      _transforms[index + 3] = centerY - ssin * halfWidth - scos * halfHeight;

      final alpha = (t * 3.0 * 255.0).clamp(0.0, 255.0).round();

      _colors[i] = (alpha << 24) | 0x00FFFFFF;
    }

    // Single batched canvas operation.
    canvas.drawRawAtlas(
      image,
      _transforms,
      _rects,
      _colors,
      BlendMode.modulate,
      null,
      _atlasPaint,
    );
  }

  @override
  bool shouldRepaint(covariant PixelLogoPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.animation != animation ||
        oldDelegate.logoSize != logoSize ||
        oldDelegate.columns != columns;
  }
}

// ============================================================
// PRECOMPUTED PIXEL DATA
// ============================================================

class _LogoPixel {
  final Rect source;

  final double centerX;
  final double centerY;

  final double offsetX;
  final double offsetY;

  final double delay;
  final double rotation;

  const _LogoPixel({
    required this.source,
    required this.centerX,
    required this.centerY,
    required this.offsetX,
    required this.offsetY,
    required this.delay,
    required this.rotation,
  });
}
