// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/nav.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/bars.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/headers.dart';
import '../../core/widgets/misc.dart';
import '../../core/widgets/page.dart';
import '../../core/widgets/popups.dart';
import '../../core/widgets/tabs.dart';
import '../../data/models.dart';
import '../../data/chat_providers.dart';
import '../../data/room_providers.dart';

// ---------------------------------------------------------------------
// Room detail
// ---------------------------------------------------------------------
class RoomDetailScreen extends ConsumerStatefulWidget {
  const RoomDetailScreen({super.key, required this.id, this.initialTab = 0});
  final int id;
  final int initialTab;
  @override
  ConsumerState<RoomDetailScreen> createState() => _RoomDetailState();
}

class _RoomDetailState extends ConsumerState<RoomDetailScreen> {
  late int _tab = widget.initialTab;
  bool _chatBusy = false;

  Future<void> _directions(Room r) async {
    final q = Uri.encodeComponent('${r.nama} ${r.alamat ?? r.lokasi ?? 'ITS Surabaya'}');
    final ok = await launchUrl(Uri.parse('https://www.google.com/maps/search/?api=1&query=$q'), mode: LaunchMode.externalApplication);
    if (!ok && mounted) showSnack(context, 'Tidak bisa membuka peta.');
  }

  Future<void> _chat(Room r) async {
    setState(() => _chatBusy = true);
    try {
      final id = await ref.read(chatRepoP).start(roomId: r.id);
      ref.invalidate(conversationsP);
      if (mounted) context.push('/chat/$id');
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _chatBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(roomP(widget.id));
    final gallery = ref.watch(roomGalleryP(widget.id)).valueOrNull ?? const <String>[];
    return async.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(appBar: AppBar(), body: Center(child: ErrorBox(e, onRetry: () => ref.invalidate(roomP(widget.id))))),
      data: (r) {
        final top = MediaQuery.paddingOf(context).top;
        final reviews = ref.watch(roomReviewsP(r.id));
        return Scaffold(
          backgroundColor: C.grey100,
          body: Column(children: [
            Expanded(
              child: Stack(children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(
                      height: 359,
                      child: Stack(children: [
                        Positioned.fill(child: RoomImage(r.foto, radius: const BorderRadius.vertical(bottom: Radius.circular(32)))),
                        if (gallery.isNotEmpty)
                          Positioned(
                            left: 20,
                            right: 20,
                            bottom: 20,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                              child: Row(children: [
                                for (var i = 0; i < gallery.length && i < 4; i++) ...[
                                  if (i > 0) const SizedBox(width: 8),
                                  Expanded(
                                    child: SizedBox(
                                      height: 70,
                                      child: Stack(fit: StackFit.expand, children: [
                                        RoomImage(gallery[i], radius: BorderRadius.circular(8)),
                                        if (i == 3 && gallery.length > 4)
                                          Container(
                                            decoration: BoxDecoration(color: Colors.black.withOpacity(.4), borderRadius: BorderRadius.circular(8)),
                                            alignment: Alignment.center,
                                            child: Text('+${gallery.length - 4}', style: T.c2s(Colors.white)),
                                          ),
                                      ]),
                                    ),
                                  ),
                                ],
                              ]),
                            ),
                          ),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Flexible(child: Text(r.departemen ?? '', style: T.c3(C.primary500))),
                          Row(children: [
                            const AppIcon('star', size: 20, color: C.secondary300, filled: true),
                            const SizedBox(width: 8),
                            Text('${r.ratingRata.toStringAsFixed(1)} (${r.jumlahUlasan} Reviews)', style: T.c2()),
                          ]),
                        ]),
                        const SizedBox(height: 16),
                        Text(r.nama, style: T.h5()),
                        const SizedBox(height: 4),
                        Row(children: [
                          Expanded(
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Padding(padding: EdgeInsets.only(top: 3), child: AppIcon('map-pin', size: 12)),
                              const SizedBox(width: 4),
                              Expanded(child: Text(r.alamat ?? r.lokasi ?? '-', style: T.b3().copyWith(fontSize: 12, height: 18 / 12))),
                            ]),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => _directions(r),
                            child: Container(width: 40, height: 40, decoration: const BoxDecoration(color: C.primary900, shape: BoxShape.circle), child: const Center(child: AppIcon('navigation', size: 20, color: Colors.white))),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: r.tersediaSekarang ? C.success50 : C.danger50, borderRadius: BorderRadius.circular(999)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Container(width: 6, height: 6, decoration: BoxDecoration(color: r.tersediaSekarang ? C.success500 : C.danger500, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text(r.tersediaSekarang ? 'Now Available' : 'Not Available Now', style: T.c2(r.tersediaSekarang ? C.success500 : C.danger500)),
                          ]),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 20),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: LineTabs(items: const ['About', 'Reviews'], active: _tab, onTap: (i) => setState(() => _tab = i))),
                    const SizedBox(height: 16),
                    if (_tab == 0) _about(r) else _reviews(reviews, r),
                  ]),
                ),
                // Tombol back & share melayang (sticky)
                Positioned(
                  top: top + 9,
                  left: 24,
                  right: 24,
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    _roundBtn('arrow-left', () => goBack(context, '/rooms')),
                    _roundBtn('share-2', () async {
                      await Clipboard.setData(ClipboardData(text: 'roomaster://rooms/${r.id}  (${r.nama})'));
                      if (context.mounted) showSnack(context, 'Tautan ruangan disalin.');
                    }),
                  ]),
                ),
              ]),
            ),
            BookBar(
              onBook: () => context.push('/rooms/${r.id}/book'),
              favorite: r.favorite,
              enabled: r.status == 'available',
              onFavorite: () async {
                await ref.read(roomRepoP).setFavorite(r.id, !r.favorite);
                ref.invalidate(roomP(r.id));
                ref.invalidate(roomsP);
              },
            ),
          ]),
        );
      },
    );
  }

  Widget _roundBtn(String icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: C.shadowCard), child: Center(child: AppIcon(icon, size: 20))),
      );

  Widget _about(Room r) {
    final facs = [Facility(Fmt.capacityShort(r.kapasitas), 'users'), ...r.fasilitas];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Facilities', style: T.s1(C.primary800)),
        const SizedBox(height: 8),
        Wrap(spacing: 10, runSpacing: 10, children: [
          for (final f in facs)
            Container(
              width: (MediaQuery.sizeOf(context).width - 48 - 20) / 3,
              height: 56,
              decoration: BoxDecoration(color: C.grey50, borderRadius: BorderRadius.circular(12)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                AppIcon(f.ikon, size: 20),
                const SizedBox(height: 4),
                Text(f.nama, style: T.c2s(), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
        ]),
        const SizedBox(height: 16),
        Text('Description', style: T.s1(C.primary800)),
        const SizedBox(height: 8),
        Text(r.deskripsi ?? '-', style: T.b3().copyWith(fontSize: 12, height: 18 / 12)),
        const SizedBox(height: 16),
        Row(children: [
          UserAvatar(name: r.namaPengelola ?? 'Admin', path: r.fotoPengelola, size: 40, online: true, ringColor: C.grey100),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.namaPengelola ?? 'Facility Admin', style: T.s1()),
              Text('Response Time: ${r.responsMenit == null ? '-' : (r.responsMenit! >= 60 ? '${(r.responsMenit! / 60).round()}h' : '${r.responsMenit}m')}', style: T.c3(C.grey500)),
            ]),
          ),
          GestureDetector(
            onTap: _chatBusy ? null : () => _chat(r),
            child: Container(width: 40, height: 40, decoration: const BoxDecoration(color: C.grey100, shape: BoxShape.circle), child: const Center(child: AppIcon('message-square', size: 20, color: C.primary500))),
          ),
        ]),
      ]),
    );
  }

  Widget _reviews(AsyncValue<List<Review>> async, Room r) {
    return async.when(
      loading: () => const LoadingBox(),
      error: (e, _) => ErrorBox(e, onRetry: () => ref.invalidate(roomReviewsP(r.id))),
      data: (list) {
        if (list.isEmpty) return const EmptyText('No reviews yet.');
        final top = [...list]..sort((a, b) => b.rating.compareTo(a.rating));
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Text('Top Reviews', style: T.s1(C.primary800))),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(children: [
              for (final v in top.take(5))
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ReviewCard(width: 240, name: v.nama, date: Fmt.dateLong(v.tanggal), comment: v.komentar ?? '', rating: v.rating, avatarPath: v.foto),
                ),
            ]),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Reviews', style: T.s1(C.primary800)),
              const SizedBox(height: 8),
              for (final v in list) Padding(padding: const EdgeInsets.only(bottom: 8), child: ReviewCard(name: v.nama, date: Fmt.dateLong(v.tanggal), comment: v.komentar ?? '', rating: v.rating, avatarPath: v.foto)),
            ]),
          ),
        ]);
      },
    );
  }
}
