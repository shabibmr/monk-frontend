import 'package:flutter/material.dart';

class MonkLogo extends StatelessWidget {
  const MonkLogo({
    super.key,
    this.height = 48.0,
    this.width,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.heroTag,
  });

  final double? height;
  final double? width;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final Widget image = Image.asset(
      'assets/monk_logo.png',
      height: height,
      width: width,
      fit: fit,
      alignment: alignment,
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          height: height,
          width: width,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.record_voice_over_rounded,
                  size: (height ?? 32) * 0.6,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'influencersmonk',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: (height ?? 32) * 0.35,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: image,
      );
    }

    return image;
  }
}
