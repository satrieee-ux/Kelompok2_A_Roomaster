import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'icon_paths.dart';

/// Ikon Lucide (path SVG sama dengan Blade `<x-icon>`).
class AppIcon extends StatelessWidget {
  const AppIcon(this.name, {super.key, this.size = 24, this.color, this.stroke = 2, this.filled = false});

  final String name;
  final double size;
  final Color? color;
  final double stroke;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? const Color(0xFF212936);
    final svg = '<svg xmlns="http://www.w3.org/2000/svg" width="$size" height="$size" viewBox="0 0 24 24" '
        'fill="${filled ? 'currentColor' : 'none'}" stroke="currentColor" stroke-width="$stroke" '
        'stroke-linecap="round" stroke-linejoin="round">${kIconPaths[name] ?? ''}</svg>';
    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      theme: SvgTheme(currentColor: c),
    );
  }
}
