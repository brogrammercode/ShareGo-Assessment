import 'package:flutter/material.dart';
import 'package:shareit/features/share/presentation/pages/send_page.dart';
import 'package:shareit/features/share/presentation/pages/share_main_page.dart';

class AppRoutes {
  static const String core = '/';
  static const String userConfig = '/userConfig';
  static const String shareMain = '/shareMain';
  static const String send = '/send';

  // route
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case core:
        return MaterialPageRoute(builder: (_) => const ShareMainPage());

      // user
      case userConfig:
        return MaterialPageRoute(builder: (_) => const Scaffold());

      // share
      case shareMain:
        return MaterialPageRoute(builder: (_) => const ShareMainPage());
      case send:
        return MaterialPageRoute(builder: (_) => const SendPage());

      // default
      default:
        return MaterialPageRoute(builder: (_) => const Scaffold());
    }
  }

  static Future<void> navigateTo(
    BuildContext context,
    String routeName,
    Object? arguments,
  ) {
    return Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static Future<void> replaceWith(BuildContext context, String routeName) {
    return Navigator.pushReplacementNamed(context, routeName);
  }

  static void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }

  static void navigateAndReplace(BuildContext context, String routeName) {
    Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
  }
}
