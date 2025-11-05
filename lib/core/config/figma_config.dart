/// Figma Design Configuration
///
/// This file contains all Figma design links for the HRM app.
/// Each screen has a corresponding Figma design that can be accessed
/// via the links provided below.
///
/// Design System: Cutframe.in Wireframe Kit (Community)
class FigmaConfig {
  // Figma Project Base URL
  static const String baseProject =
      "https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-";

  // File ID
  static const String fileId = "mO0XvE4zIjUFO7xv6Tioxo";

  // Feature-specific Links with Node IDs (Updated with actual Figma designs)
  static const Map<String, String> featureLinks = {
    // Authentication Screens
    "auth": "https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=439-5989&t=1cpzGuxQnM6DuWTC-4",
    "login": "https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=439-5989&t=1cpzGuxQnM6DuWTC-4",
    "register": "https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=439-6162&t=1cpzGuxQnM6DuWTC-4",
    "forgot_password": "https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=439-6273&t=1cpzGuxQnM6DuWTC-4",

    // Dashboard
    "dashboard": "https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=439-6682&t=1cpzGuxQnM6DuWTC-4",

    // Attendance Screens
    "attendance": "https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=439-7193&t=1cpzGuxQnM6DuWTC-4",
    "check_in": "https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=439-7193&t=1cpzGuxQnM6DuWTC-4",
    "attendance_history": "https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=442-6323&t=1cpzGuxQnM6DuWTC-4",

    // Profile Screens
    "profile": "https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=442-7079&t=1cpzGuxQnM6DuWTC-4",
    "edit_profile": "https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=442-7079&t=1cpzGuxQnM6DuWTC-4",
    "change_password": "https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=439-6273&t=1cpzGuxQnM6DuWTC-4",

    // Requests Screens
    "requests": "https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=442-6323&t=1cpzGuxQnM6DuWTC-4",
    "create_request": "https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=439-7193&t=1cpzGuxQnM6DuWTC-4",
  };

  /// Helper method to construct Figma URL with specific node
  ///
  /// Usage:
  /// ```dart
  /// String loginScreenUrl = FigmaConfig.getScreenUrl("1-9");
  /// ```
  static String getScreenUrl(String nodeId) {
    return "https://www.figma.com/design/$fileId/Cutframe.in---wireframe-kit---Community-?node-id=$nodeId";
  }

  /// Get Figma link for a specific feature
  ///
  /// Usage:
  /// ```dart
  /// String loginUrl = FigmaConfig.getFeatureLink("login");
  /// ```
  static String? getFeatureLink(String feature) {
    return featureLinks[feature];
  }

  /// Opens Figma design in browser (Web/Desktop only)
  ///
  /// For mobile, use url_launcher package
  static void openInBrowser(String feature) {
    final url = getFeatureLink(feature);
    if (url != null) {
      // For web/desktop: window.open(url)
      // For mobile: use url_launcher package
      print('Opening Figma: $url');
    }
  }
}
