import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Screen size breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Check if current screen is mobile size
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if current screen is tablet size
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Check if current screen is desktop size
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  /// Get responsive margin based on screen size
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
    }
  }

  /// Get responsive grid cross axis count
  static int getGridCrossAxisCount(BuildContext context, {double itemWidth = 120}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = getResponsivePadding(context);
    final availableWidth = screenWidth - padding.horizontal;
    final crossAxisCount = (availableWidth / itemWidth).floor();
    return crossAxisCount.clamp(2, 6); // Minimum 2, maximum 6 columns
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) {
      return baseFontSize * 0.9;
    } else if (isTablet(context)) {
      return baseFontSize;
    } else {
      return baseFontSize * 1.1;
    }
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, double baseIconSize) {
    if (isMobile(context)) {
      return baseIconSize * 0.9;
    } else if (isTablet(context)) {
      return baseIconSize;
    } else {
      return baseIconSize * 1.2;
    }
  }

  /// Get responsive card height
  static double getResponsiveCardHeight(BuildContext context, double baseHeight) {
    if (isMobile(context)) {
      return baseHeight * 0.9;
    } else if (isTablet(context)) {
      return baseHeight;
    } else {
      return baseHeight * 1.1;
    }
  }

  /// Get responsive border radius
  static BorderRadius getResponsiveBorderRadius(BuildContext context) {
    if (isMobile(context)) {
      return BorderRadius.circular(12);
    } else if (isTablet(context)) {
      return BorderRadius.circular(16);
    } else {
      return BorderRadius.circular(20);
    }
  }

  /// Get responsive button height
  static double getResponsiveButtonHeight(BuildContext context) {
    if (isMobile(context)) {
      return 48.0;
    } else if (isTablet(context)) {
      return 56.0;
    } else {
      return 64.0;
    }
  }

  /// Get responsive app bar height
  static double getResponsiveAppBarHeight(BuildContext context) {
    if (isMobile(context)) {
      return kToolbarHeight;
    } else if (isTablet(context)) {
      return kToolbarHeight + 8;
    } else {
      return kToolbarHeight + 16;
    }
  }

  /// Get responsive container constraints
  static BoxConstraints getResponsiveConstraints(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (isMobile(context)) {
      return BoxConstraints(
        maxWidth: screenWidth,
        minHeight: 0,
      );
    } else if (isTablet(context)) {
      return BoxConstraints(
        maxWidth: screenWidth * 0.8,
        minHeight: 0,
      );
    } else {
      return BoxConstraints(
        maxWidth: 1200,
        minHeight: 0,
      );
    }
  }

  /// Safe area wrapper that handles different screen sizes
  static Widget safeAreaWrapper(BuildContext context, Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: getResponsiveConstraints(context),
            child: Padding(
              padding: getResponsivePadding(context),
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// Get responsive grid delegate
  static SliverGridDelegate getResponsiveGridDelegate(
    BuildContext context, {
    double childAspectRatio = 1.0,
    double itemWidth = 120,
  }) {
    final crossAxisCount = getGridCrossAxisCount(context, itemWidth: itemWidth);
    
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: isMobile(context) ? 8.0 : 12.0,
      mainAxisSpacing: isMobile(context) ? 8.0 : 12.0,
    );
  }

  /// Get screen size type as string for debugging
  static String getScreenSizeType(BuildContext context) {
    if (isMobile(context)) return 'Mobile';
    if (isTablet(context)) return 'Tablet';
    return 'Desktop';
  }
}