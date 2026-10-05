import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../themes/app_theme.dart';

class CustomRefreshIndicatorBuilder extends StatelessWidget {
  static const indicatorSize = 100.0;

  final Widget? child;
  final IndicatorController? controller;

  const CustomRefreshIndicatorBuilder({super.key, this.child, this.controller});

  @override
  Widget build(BuildContext context) => Stack(
    children: <Widget>[
      AnimatedBuilder(
        animation: controller!,
        builder: (BuildContext context, Widget? _) => controller!.isDragging || controller!.isArmed
            ? Container(
                height: controller!.value * indicatorSize,
                alignment: Alignment.center,
                child: OverflowBox(
                  maxHeight: 60,
                  minHeight: 60,
                  maxWidth: 60,
                  minWidth: 60,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.getBgDefaultColor(),
                      shape: BoxShape.circle,
                    ),
                    child: SpinKitRing(
                      color: AppTheme.pickColor(
                        light: AppTheme.primaryColor,
                        dark: Colors.white,
                      ),
                      lineWidth: 3.5,
                      size: 30.0,
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
      AnimatedBuilder(
        builder: (context, _) => Transform.translate(
          offset: Offset(0.0, controller!.value * indicatorSize),
          child: child,
        ),
        animation: controller!,
      ),
    ],
  );
}
