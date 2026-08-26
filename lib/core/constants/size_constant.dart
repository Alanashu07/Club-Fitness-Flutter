import 'package:flutter/material.dart';
import 'package:club_fitness/config/navigation/routes_class.dart';

enum DeviceType { mobile, tablet, desktop }

abstract class SizeConstant {
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static double getScreenWidth(BuildContext context) {
    return getScreenSize(context).width;
  }

  static double getScreenHeight(BuildContext context) {
    return getScreenSize(context).height;
  }

  static double percentToHeight(BuildContext context, double percent) {
    return (percent / 100) * getScreenHeight(context);
  }

  static double percentToWidth(BuildContext context, double percent) {
    return (percent / 100) * getScreenWidth(context);
  }

  static double get getDeviceAspectRatio {
    final context = RoutesClass.context!;
    return context.width / context.height;
  }
}

extension SizeExtension on num {
  Size get screenSize => RoutesClass.context!.screenSize;

  double get screenWidthRatio => screenSize.width / 375;

  double get screenHeightRatio => screenSize.height / 812;

  double get textScaleFactor => screenWidthRatio;

  double get w => this * screenWidthRatio;

  double get h => this * screenHeightRatio;

  double get sp => this * textScaleFactor;

  double get r => this * screenWidthRatio;

  double get percentToWidth =>
      SizeConstant.percentToWidth(RoutesClass.context!, toDouble());

  double get percentToHeight =>
      SizeConstant.percentToHeight(RoutesClass.context!, toDouble());

  Widget get height => SizedBox(height: toDouble());

  Widget get width => SizedBox(width: toDouble());

  Widget get square => SizedBox(width: toDouble(), height: toDouble());

  Widget squareChild(Widget child) =>
      SizedBox(width: toDouble(), height: toDouble(), child: child);

  EdgeInsets get all => EdgeInsets.all(toDouble());

  EdgeInsets get horizontal => EdgeInsets.symmetric(horizontal: toDouble());

  EdgeInsets get vertical => EdgeInsets.symmetric(vertical: toDouble());

  EdgeInsets get left => EdgeInsets.only(left: toDouble());

  EdgeInsets get right => EdgeInsets.only(right: toDouble());

  EdgeInsets get top => EdgeInsets.only(top: toDouble());

  EdgeInsets get bottom => EdgeInsets.only(bottom: toDouble());

  BorderRadius get borderRadius => BorderRadius.circular(toDouble());
}

extension WidgetExtension on Widget {
  Widget sizedBox({double? height, double? width}) =>
      SizedBox(height: height, width: width, child: this);

  Widget padding({
    double top = 0,
    double right = 0,
    double bottom = 0,
    double left = 0,
  }) => Padding(
    padding: EdgeInsets.only(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
    ),
    child: this,
  );
}

extension ContextSizeExtension on BuildContext {
  double get height => MediaQuery.of(this).size.height;

  double get width => MediaQuery.of(this).size.width;

  double get halfHeight => height / 2;

  double get halfWidth => width / 2;

  double get quarterHeight => height / 4;

  double get quarterWidth => width / 4;

  Size get screenSize => MediaQuery.of(this).size;

  MediaQueryData get mq => MediaQuery.of(this);

  DeviceType get deviceType {
    if (width >= 900) return DeviceType.desktop;
    if (width >= 600) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  double percentToHeight(double percent) =>
      SizeConstant.percentToHeight(this, percent);

  double percentToWidth(double percent) =>
      SizeConstant.percentToWidth(this, percent);
}
