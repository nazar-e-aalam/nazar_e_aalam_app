// ignore_for_file: deprecated_member_use
// ignore_for_file: library_private_types_in_public_api

// import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_qiblah_advanced/flutter_qiblah_advanced.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';

class QiblahCompassWidget extends StatefulWidget {
  const QiblahCompassWidget({super.key});

  @override
  State<QiblahCompassWidget> createState() => _QiblahCompassWidgetState();
}

class _QiblahCompassWidgetState extends State<QiblahCompassWidget> {
  double _deviceTurns = 0;
  double _qiblahTurns = 0;

  double? _previousDevice;
  double? _previousQiblah;

  late final Stream<QiblahDirection> _qiblahStream = FlutterQiblah.qiblahStream;

  double _signedAngle(double angle) {
    return ((angle + 180) % 360) - 180;
  }

  double _shortestTurn(double current, double previous) {
    return _signedAngle(current - previous) / 360;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QiblahDirection>(
      stream: _qiblahStream,
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const QuiblaeShimmerScreen();
        }

        final data = snapshot.data!;

        final deviceAngle = data.direction % 360;
        final qiblahBearing = data.offset % 360;

        final relativeAngle = ((qiblahBearing - deviceAngle + 180) % 360) - 180;

        final angleToQibla = relativeAngle.abs();

        if (_previousDevice == null || _previousQiblah == null) {
          _deviceTurns = deviceAngle / 360;
          _qiblahTurns = relativeAngle / 360;

          _previousDevice = deviceAngle;
          _previousQiblah = relativeAngle;
        } else {
          final deviceDelta = _shortestTurn(deviceAngle, _previousDevice!);

          final qiblahDelta = _shortestTurn(relativeAngle, _previousQiblah!);

          // Ignore tiny sensor fluctuations below 0.15°.
          if (deviceDelta.abs() * 360 >= 0.15) {
            _deviceTurns += deviceDelta;
            _previousDevice = deviceAngle;
          }

          if (qiblahDelta.abs() * 360 >= 0.15) {
            _qiblahTurns += qiblahDelta;
            _previousQiblah = relativeAngle;
          }
        }

        _previousDevice = deviceAngle;
        _previousQiblah = relativeAngle;

        // debugPrint(
        //   'QIBLA DEBUG | '
        //   'Heading: ${deviceAngle.toStringAsFixed(2)}° | '
        //   'Bearing: ${qiblahBearing.toStringAsFixed(2)}° | '
        //   'Relative: ${relativeAngle.toStringAsFixed(2)}° | '
        //   'Distance: ${angleToQibla.toStringAsFixed(2)}°',
        // );

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Smooth compass background.
                    AnimatedRotation(
                      turns: -_deviceTurns,
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOutCubic,
                      child: RepaintBoundary(
                        child: Image.asset(
                          Images.Compass,
                          height: 330,
                          fit: BoxFit.contain,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),

                    // Natural needle movement.
                    AnimatedRotation(
                      turns: _qiblahTurns,
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      child: RepaintBoundary(
                        child: Image.asset(
                          Images.Compass_Needle,
                          height: 400,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 10.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${angleToQibla.round()}°',
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'device_angle_to_qibla'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_DEFAULT,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40.0),
            ],
          ),
        );
      },
    );
  }
}
