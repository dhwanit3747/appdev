import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlHelper {
  static Future<void> launchExternalUrl(BuildContext context, String urlString) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (urlString.isEmpty) {
      _showError(scaffoldMessenger, "URL is empty");
      return;
    }

    final uri = Uri.parse(urlString.trim());
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        // Fallback to default launching mode
        final fallbackLaunched = await launchUrl(uri);
        if (!fallbackLaunched) {
          _showError(scaffoldMessenger, "Could not open link");
        }
      }
    } catch (e) {
      try {
        final fallbackLaunched = await launchUrl(uri);
        if (!fallbackLaunched) {
          _showError(scaffoldMessenger, "Could not open link: $e");
        }
      } catch (err) {
        _showError(scaffoldMessenger, "Could not open link: $err");
      }
    }
  }

  static void _showError(ScaffoldMessengerState messenger, String message) {
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent.shade700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
