import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text.dart';
import 'app_icon.dart';

enum BtnVariant { primary, secondary, outline, soft, disabled }

enum BtnSize { giant, large, medium, small, tiny }

class _Sz {
  const _Sz(this.h, this.px, this.fs, this.lh, this.icon, this.gap);
  final double h, px, fs, lh, icon, gap;
}

const _sizes = {
  BtnSize.giant: _Sz(52, 24, 18, 24, 24, 8),
  BtnSize.large: _Sz(44, 20, 16, 20, 20, 8),
  BtnSize.medium: _Sz(38, 16, 14, 16, 18, 6),
  BtnSize.small: _Sz(32, 12, 12, 16, 20, 4),
  BtnSize.tiny: _Sz(24, 8, 10, 12, 16, 2),
};

/// Tombol pil (padanan `<x-button>`). onPressed null = nonaktif (abu-abu).
class AppButton extends StatelessWidget {
  const AppButton(
    this.label, {
    super.key,
    this.onPressed,
    this.variant = BtnVariant.primary,
    this.size = BtnSize.large,
    this.iconLeft,
    this.iconRight,
    this.expand = false,
    this.bg,
    this.fg,
    this.loading = false,
  });

  /// Tombol bulat berisi satu ikon.
  const AppButton.icon(
    String icon, {
    super.key,
    this.onPressed,
    this.variant = BtnVariant.primary,
    this.size = BtnSize.large,
  })  : label = '',
        iconLeft = icon,
        iconRight = null,
        expand = false,
        bg = null,
        fg = null,
        loading = false;

  final String label;
  final VoidCallback? onPressed;
  final BtnVariant variant;
  final BtnSize size;
  final String? iconLeft;
  final String? iconRight;
  final bool expand;
  final Color? bg;
  final Color? fg;
  final bool loading;

  bool get _iconOnly => label.isEmpty && iconLeft != null;

  @override
  Widget build(BuildContext context) {
    final s = _sizes[size]!;
    final disabled = onPressed == null || variant == BtnVariant.disabled || loading;
    Color bgc;
    Color fgc;
    BorderSide side = BorderSide.none;
    switch (disabled && !loading ? BtnVariant.disabled : variant) {
      case BtnVariant.primary:
        bgc = C.primary800;
        fgc = Colors.white;
        break;
      case BtnVariant.secondary:
        bgc = C.secondary500;
        fgc = Colors.white;
        break;
      case BtnVariant.outline:
        bgc = Colors.white;
        fgc = C.primary500;
        side = const BorderSide(color: C.primary500);
        break;
      case BtnVariant.soft:
        bgc = C.grey100;
        fgc = C.primary500;
        break;
      case BtnVariant.disabled:
        bgc = C.grey300;
        fgc = C.grey500;
        break;
    }
    bgc = bg != null && !disabled ? bg! : bgc;
    fgc = fg != null && !disabled ? fg! : fgc;

    final style = T.x(s.fs, s.lh, FontWeight.w600, fgc);
    final Widget content;
    if (loading) {
      content = SizedBox(
        width: s.icon,
        height: s.icon,
        child: CircularProgressIndicator(strokeWidth: 2, color: fgc),
      );
    } else if (_iconOnly) {
      content = AppIcon(iconLeft!, size: s.icon, color: fgc);
    } else {
      content = Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconLeft != null) ...[AppIcon(iconLeft!, size: s.icon, color: fgc), SizedBox(width: s.gap)],
          Flexible(child: Text(label, style: style, maxLines: 1, overflow: TextOverflow.ellipsis)),
          if (iconRight != null) ...[SizedBox(width: s.gap), AppIcon(iconRight!, size: s.icon, color: fgc)],
        ],
      );
    }

    final w = _iconOnly ? s.h : null;
    return SizedBox(
      height: s.h,
      width: expand ? double.infinity : w,
      child: Material(
        color: bgc,
        shape: StadiumBorder(side: side),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: _iconOnly ? 0 : s.px),
            child: Center(widthFactor: expand ? null : 1, child: content),
          ),
        ),
      ),
    );
  }
}
