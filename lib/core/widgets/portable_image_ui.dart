import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PortableImageUi extends StatelessWidget {
  final String? pathOrUrl;
  final BoxFit fit;
  final IconData fallbackIcon;
  final double fallbackIconSize;
  final Color fallbackColor;

  const PortableImageUi({
    super.key,
    required this.pathOrUrl,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.image_outlined,
    this.fallbackIconSize = 32,
    this.fallbackColor = AppColors.primaryEmerald,
  });

  Widget _fallback() {
    return Center(
      child: Icon(
        fallbackIcon,
        size: fallbackIconSize,
        color: fallbackColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clean = pathOrUrl?.trim() ?? '';
    if (clean.isEmpty || clean == 'null') return _fallback();

    if (clean.startsWith('data:image')) {
      try {
        final commaIdx = clean.indexOf(',');
        if (commaIdx == -1) return _fallback();
        final bytes = base64Decode(clean.substring(commaIdx + 1));
        return Image.memory(
          bytes,
          fit: fit,
          errorBuilder: (_, _, _) => _fallback(),
        );
      } catch (_) {
        return _fallback();
      }
    }

    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return Image.network(
        clean,
        fit: fit,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }

    if (!kIsWeb) {
      final file = File(clean);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: fit,
          errorBuilder: (_, _, _) => _fallback(),
        );
      }
    }

    return _fallback();
  }
}