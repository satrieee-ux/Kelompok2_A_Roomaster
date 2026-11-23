import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text.dart';
import '../utils/storage_url.dart';
import 'app_button.dart';
import 'app_icon.dart';

// ---------------------------------------------------------------------
// Gambar
// ---------------------------------------------------------------------

/// Gambar ruangan: 'asset:...' = bundel aplikasi, selain itu path bucket publik "ruangan".
class RoomImage extends StatelessWidget {
  const RoomImage(this.path, {super.key, this.width, this.height, this.fit = BoxFit.cover, this.radius});
  final String? path;
  final double? width, height;
  final BoxFit fit;
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    final ph = Container(width: width, height: height, color: C.grey200, child: const Center(child: AppIcon('image', color: C.grey400)));
    Widget img;
    if (path == null || path!.isEmpty) {
      img = ph;
    } else if (StorageUrls.isAsset(path)) {
      img = Image.asset('assets/${StorageUrls.assetPath(path!)}', width: width, height: height, fit: fit);
    } else {
      img = Image.network(
        StorageUrls.publicUrl('ruangan', path!),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => ph,
      );
    }
    return radius == null ? img : ClipRRect(borderRadius: radius!, child: img);
  }
}

/// Gambar dari bucket privat lewat signed URL.
class SignedImage extends StatelessWidget {
  const SignedImage({super.key, required this.bucket, required this.path, this.width, this.height, this.fit = BoxFit.cover, this.radius});
  final String bucket, path;
  final double? width, height;
  final BoxFit fit;
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    final box = Container(width: width, height: height, color: C.grey200);
    final w = FutureBuilder<String>(
      future: StorageUrls.signedUrl(bucket, path),
      builder: (_, snap) {
        if (!snap.hasData) return box;
        return Image.network(snap.data!, width: width, height: height, fit: fit, errorBuilder: (_, __, ___) => box);
      },
    );
    return radius == null ? w : ClipRRect(borderRadius: radius!, child: w);
  }
}

/// Avatar bulat: foto profil (bucket publik "profil") atau inisial.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.name, this.path, this.size = 40, this.online = false, this.ringColor = Colors.white});
  final String name;
  final String? path;
  final double size;
  final bool online;
  final Color ringColor;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).take(2);
    return parts.map((e) => e.substring(0, 1).toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    Widget inner;
    if (path != null && path!.isNotEmpty) {
      inner = Image.network(
        StorageUrls.publicUrl('profil', path!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } else {
      inner = _fallback();
    }
    final dot = size >= 40 ? 10.0 : 10.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(clipBehavior: Clip.none, children: [
        ClipOval(child: SizedBox(width: size, height: size, child: inner)),
        if (online)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: dot,
              height: dot,
              decoration: BoxDecoration(
                color: C.success500,
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 2),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _fallback() => Container(
        color: C.primary50,
        alignment: Alignment.center,
        child: Text(_initials, style: T.x(size >= 40 ? 14 : 12, 16, FontWeight.w600, C.primary700)),
      );
}

// ---------------------------------------------------------------------
// Border putus-putus
// ---------------------------------------------------------------------
class DashedBorder extends StatelessWidget {
  const DashedBorder({super.key, required this.child, this.color = C.grey400, this.radius = 8, this.fill});
  final Widget child;
  final Color color;
  final double radius;
  final Color? fill;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _DashPainter(color, radius, fill),
        child: child,
      );
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color, this.radius, this.fill);
  final Color color;
  final double radius;
  final Color? fill;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    if (fill != null) canvas.drawRRect(rrect, Paint()..color = fill!);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()..addRRect(rrect.deflate(0.5));
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, math.min(d + 5, m.length)), paint);
        d += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter old) => old.color != color || old.radius != radius || old.fill != fill;
}

// ---------------------------------------------------------------------
// Section, stepper, timeline, success
// ---------------------------------------------------------------------

/// Judul section + tombol "See All".
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.onSeeAll, this.style, this.height = 28});
  final String title;
  final VoidCallback? onSeeAll;
  final TextStyle? style;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(child: Text(title, style: style ?? T.s1(C.primary800), maxLines: 1, overflow: TextOverflow.ellipsis)),
        if (onSeeAll != null)
          AppButton('See All', onPressed: onSeeAll, variant: BtnVariant.soft, size: BtnSize.tiny, iconRight: 'chevron-right'),
      ]),
    );
  }
}

/// Stepper 3 langkah booking.
class BookingStepper extends StatelessWidget {
  const BookingStepper({super.key, required this.step});
  final int step;
  static const _labels = ['Details', 'Documents', 'Confirmation'];

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(left: 81, top: 20, child: Container(width: 50, height: 1, color: C.grey200)),
      Positioned(left: 211, top: 20, child: Container(width: 50, height: 1, color: C.grey200)),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        for (var i = 0; i < 3; i++)
          SizedBox(
            width: 82,
            child: Column(children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: i + 1 == step ? C.primary900 : C.grey200, shape: BoxShape.circle),
                child: Text('${i + 1}', style: T.b2(i + 1 == step ? Colors.white : C.grey600)),
              ),
              const SizedBox(height: 8),
              Text(
                _labels[i],
                maxLines: 1,
                style: i + 1 == step
                    ? T.b4(C.grey800)
                    : (i + 1 < step ? T.b3m(C.grey600) : T.b3(C.grey500)),
              ),
            ]),
          ),
      ]),
    ]);
  }
}

enum StepMode { done, current, todo }

class TimelineItem {
  const TimelineItem(this.icon, this.state, this.title, this.desc);
  final String icon;
  final StepMode state;
  final String title, desc;
}

/// Timeline aktivitas vertikal.
class ActivityTimeline extends StatelessWidget {
  const ActivityTimeline({super.key, required this.items});
  final List<TimelineItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for (var i = 0; i < items.length; i++) _row(items[i], i == items.length - 1),
    ]);
  }

  Widget _row(TimelineItem it, bool last) {
    Color bg;
    Color fg;
    Border? border;
    switch (it.state) {
      case StepMode.done:
        bg = C.primary900;
        fg = Colors.white;
        break;
      case StepMode.current:
        bg = Colors.white;
        fg = C.grey800;
        border = Border.all(color: C.grey600);
        break;
      case StepMode.todo:
        bg = C.grey200;
        fg = C.grey400;
        break;
    }
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle, border: border),
            child: AppIcon(it.icon, size: 20, color: fg),
          ),
          if (!last) Expanded(child: Container(width: 2, color: C.grey300)),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 4, bottom: last ? 0 : 32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(it.title, style: T.b4(it.state == StepMode.todo ? C.grey500 : C.grey800)),
              Text(it.desc, style: T.c2(C.grey500)),
            ]),
          ),
        ),
      ]),
    );
  }
}

/// Lingkaran hijau 128 dengan centang (layar sukses).
class SuccessBadge extends StatelessWidget {
  const SuccessBadge({super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: 128,
        height: 128,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: C.success500, shape: BoxShape.circle),
        child: const AppIcon('check', size: 72, color: Colors.white, stroke: 3.2),
      );
}

// ---------------------------------------------------------------------
// Status muat / galat / kosong
// ---------------------------------------------------------------------
class LoadingBox extends StatelessWidget {
  const LoadingBox({super.key, this.height = 160});
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: const Center(child: CircularProgressIndicator(color: C.primary500, strokeWidth: 3)),
      );
}

class ErrorBox extends StatelessWidget {
  const ErrorBox(this.error, {super.key, this.onRetry});
  final Object error;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const AppIcon('alert-circle', size: 32, color: C.danger500),
          const SizedBox(height: 8),
          Text(friendlyError(error), textAlign: TextAlign.center, style: T.b3(C.grey600)),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            AppButton('Try again', onPressed: onRetry, variant: BtnVariant.soft, size: BtnSize.medium),
          ],
        ]),
      );
}

class EmptyText extends StatelessWidget {
  const EmptyText(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(child: Text(text, textAlign: TextAlign.center, style: T.b3(C.grey500))),
      );
}

/// Pesan galat yang ramah (menghilangkan prefiks teknis).
String friendlyError(Object e) {
  var s = e.toString();
  final m = RegExp(r'message[:=]\s*([^,}]+)').firstMatch(s);
  if (m != null) s = m.group(1)!.trim();
  s = s
      .replaceFirst('Exception: ', '')
      .replaceFirst('PostgrestException', '')
      .replaceFirst('AuthException', '')
      .replaceFirst(RegExp(r'^\(?message:\s*'), '');
  if (s.contains('SocketException') || s.contains('ClientException')) {
    return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
  }
  if (s.contains('Invalid login credentials')) return 'Email atau password salah.';
  if (s.contains('Email not confirmed')) return 'Email belum dikonfirmasi. Periksa kotak masuk Anda.';
  if (s.contains('already registered')) return 'Email sudah terdaftar.';
  return s.trim().isEmpty ? 'Terjadi kesalahan. Coba lagi.' : s.trim();
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Pembaca byte file yang dipilih (gambar/berkas).
class PickedUpload {
  PickedUpload({required this.name, required this.bytes, required this.mime});
  final String name;
  final Uint8List bytes;
  final String mime;
  int get size => bytes.length;
  bool get isVideo => mime.startsWith('video/');
}
