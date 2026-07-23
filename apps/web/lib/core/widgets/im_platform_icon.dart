import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Renders official product brand logos downloaded from online sources.
class ImPlatformIcon extends StatelessWidget {
  const ImPlatformIcon({
    super.key,
    required this.platform,
    this.size = 20.0,
  });

  final String platform;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = platform.toLowerCase();
    final assetName = switch (p) {
      'instagram' => 'instagram.png',
      'youtube' => 'youtube.png',
      'facebook' => 'facebook.png',
      'x' || 'twitter' => 'x.png',
      'linkedin' => 'linkedin.png',
      _ => null,
    };

    if (assetName != null) {
      return Image.asset(
        'assets/logos/$assetName',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.language_rounded,
          color: ImColors.ink600,
          size: size,
        ),
      );
    }

    return Icon(
      Icons.language_rounded,
      color: ImColors.ink600,
      size: size,
    );
  }

  static String formatName(String platform) {
    final p = platform.toLowerCase();
    switch (p) {
      case 'instagram':
        return 'Instagram';
      case 'youtube':
        return 'YouTube';
      case 'facebook':
        return 'Facebook';
      case 'x':
      case 'twitter':
        return 'X (Twitter)';
      case 'linkedin':
        return 'LinkedIn';
      case 'blog':
        return 'Blog / Website';
      default:
        return platform.isEmpty
            ? ''
            : '${platform[0].toUpperCase()}${platform.substring(1)}';
    }
  }
}
