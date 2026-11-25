// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ShijraImageViewer extends StatefulWidget {
  final String imagePath;

  const ShijraImageViewer({super.key, required this.imagePath});

  @override
  State<ShijraImageViewer> createState() => _ShijraImageViewerState();
}

class _ShijraImageViewerState extends State<ShijraImageViewer> {
  final TransformationController _controller = TransformationController();

  final GlobalKey _viewerKey = GlobalKey();

  TapDownDetails? _doubleTapDetails;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    final currentScale = _controller.value.getMaxScaleOnAxis();

    if (currentScale > 1.0) {
      _controller.value = Matrix4.identity();
      return;
    }

    final position = _doubleTapDetails?.localPosition;

    if (position == null) return;

    const scale = 2.5;

    _controller.value = Matrix4.identity()
      ..translate(-position.dx * (scale - 1), -position.dy * (scale - 1))
      ..scale(scale);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onDoubleTapDown: (details) {
            _doubleTapDetails = details;
          },
          onDoubleTap: _handleDoubleTap,
          child: InteractiveViewer(
            key: _viewerKey,
            transformationController: _controller,
            minScale: 1.0,
            maxScale: 5.0,
            panEnabled: true,
            scaleEnabled: true,
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Image.asset(
                widget.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image_outlined, size: 60),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
