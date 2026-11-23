import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Kerangka layar: header sticky (atas) + isi menggulir + bar sticky (bawah).
/// Sesuai aturan proyek: header & navbar tidak ikut scroll; ujung scroll = tinggi bar bawah + 20px.
class PageShell extends StatelessWidget {
  const PageShell({
    super.key,
    this.header,
    required this.child,
    this.bottom,
    this.bg = C.grey100,
    this.padding = const EdgeInsets.fromLTRB(24, 20, 24, 20),
    this.scroll = true,
    this.onRefresh,
    this.controller,
  });
  final Widget? header;
  final Widget child;
  final Widget? bottom;
  final Color bg;
  final EdgeInsets padding;
  final bool scroll;
  final Future<void> Function()? onRefresh;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    Widget body = scroll ? SingleChildScrollView(controller: controller, physics: const AlwaysScrollableScrollPhysics(), padding: padding, child: child) : child;
    if (onRefresh != null && scroll) body = RefreshIndicator(onRefresh: onRefresh!, child: body);
    return Scaffold(
      backgroundColor: bg,
      resizeToAvoidBottomInset: true,
      body: Column(children: [
        if (header != null) header!,
        Expanded(child: body),
        if (bottom != null) bottom!,
      ]),
    );
  }
}
