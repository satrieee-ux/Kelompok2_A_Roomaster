// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/forms.dart';
import '../../app/nav.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/bars.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/headers.dart';
import '../../core/widgets/misc.dart';
import '../../core/widgets/page.dart';
import '../../core/widgets/popups.dart';
import '../../core/widgets/status.dart';
import '../../core/widgets/tabs.dart';
import '../../data/models.dart';
import '../../data/room_providers.dart';
import '../home/common.dart';
import 'tu_widgets.dart';

// ---------------------------------------------------------------------
// Ratings (Popular Reviews)
// ---------------------------------------------------------------------
class TuRatingsScreen extends ConsumerStatefulWidget {
  const TuRatingsScreen({super.key});
  @override
  ConsumerState<TuRatingsScreen> createState() => _RatingsState();
}

class _RatingsState extends ConsumerState<TuRatingsScreen> {
  final _q = TextEditingController();
  int _sort = 0; // 0 relevan, 1 terbaru, 2 rating tertinggi
  int? _roomId;
  int _shown = 5;

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(allReviewsP);
    final rooms = ref.watch(roomsP).valueOrNull ?? const <Room>[];
    final ranked = rooms.where((r) => r.jumlahUlasan > 0).toList()..sort((a, b) {
        final c = b.ratingRata.compareTo(a.ratingRata);
        return c != 0 ? c : b.jumlahUlasan.compareTo(a.jumlahUlasan);
      });
    return PageShell(
      header: RoleHomeHeader(heading: 'Check the Reviews', controller: _q, onChanged: (_) => setState(() {})),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      onRefresh: () async {
        ref.invalidate(allReviewsP);
        ref.invalidate(roomsP);
      },
      bottom: StaffNavBar(items: StaffNavBar.tu, active: 'ratings', onSelect: (k) => goTuNav(context, k)),
      child: reviewsAsync.when(
        loading: () => const LoadingBox(),
        error: (e, _) => ErrorBox(e, onRetry: () => ref.invalidate(allReviewsP)),
        data: (all) {
          var list = _roomId == null ? all : all.where((r) => r.idRuangan == _roomId).toList();
          final q = _q.text.trim().toLowerCase();
          if (q.isNotEmpty) list = list.where((r) => ('${r.nama} ${r.namaRuangan ?? ''} ${r.komentar ?? ''}').toLowerCase().contains(q)).toList();
          final sorted = [...list];
          switch (_sort) {
            case 1:
              sorted.sort((a, b) => b.tanggal.compareTo(a.tanggal));
            case 2:
              sorted.sort((a, b) => b.rating.compareTo(a.rating));
            default:
              sorted.sort((a, b) {
                final s = (b.rating * 100 + (b.komentar?.length ?? 0)).compareTo(a.rating * 100 + (a.komentar?.length ?? 0));
                return s;
              });
          }
          final total = list.length;
          final avg = total == 0 ? 0.0 : list.fold<int>(0, (s, r) => s + r.rating) / total;
          int cnt(int n) => list.where((r) => r.rating == n).length;
          final roomName = _roomId == null ? 'All Rooms' : (rooms.where((r) => r.id == _roomId).firstOrNull?.nama ?? 'Room');
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Showing for $roomName', style: T.s1(C.primary500)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: tuWhiteCard(),
              child: Row(children: [
                Expanded(
                  child: Column(children: [
                    Text('Overall Rating', style: T.b3()),
                    const SizedBox(height: 4),
                    Text.rich(TextSpan(children: [TextSpan(text: avg.toStringAsFixed(1), style: T.x(32, 40, FontWeight.w800)), TextSpan(text: '/5.0', style: T.s1(C.grey600))])),
                    const SizedBox(height: 4),
                    Row(mainAxisSize: MainAxisSize.min, children: [for (var i = 1; i <= 5; i++) AppIcon('star', size: 18, color: i <= avg.round() ? C.secondary300 : C.grey300, filled: true)]),
                    const SizedBox(height: 4),
                    Text('Based on $total Reviews', textAlign: TextAlign.center, style: T.c1(C.grey600)),
                  ]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(children: [
                    for (var n = 5; n >= 1; n--)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(children: [
                          SizedBox(width: 12, child: Text('$n', style: T.c2s())),
                          const SizedBox(width: 6),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(value: total == 0 ? 0 : cnt(n) / total, minHeight: 6, backgroundColor: C.grey200, valueColor: const AlwaysStoppedAnimation(C.secondary300)),
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(width: 34, child: Text(total == 0 ? '0%' : '${(cnt(n) * 100 / total).round()}%', textAlign: TextAlign.right, style: T.c1())),
                        ]),
                      ),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 24),
            Text('Room Ranking', style: T.h5().copyWith(fontSize: 20)),
            const SizedBox(height: 4),
            Text('Highest rated rooms. Tap a room to filter its reviews.', style: T.b3(C.grey600)),
            const SizedBox(height: 12),
            if (ranked.isEmpty) const EmptyText('No rated rooms yet.'),
            for (var i = 0; i < ranked.length && i < 5; i++)
              GestureDetector(
                onTap: () => setState(() {
                  _roomId = _roomId == ranked[i].id ? null : ranked[i].id;
                  _shown = 5;
                }),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: _roomId == ranked[i].id ? C.primary50 : Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: C.shadowCard, border: _roomId == ranked[i].id ? Border.all(color: C.primary500) : null),
                  child: Row(children: [
                    Container(width: 28, height: 28, decoration: const BoxDecoration(color: C.primary900, shape: BoxShape.circle), child: Center(child: Text('${i + 1}', style: T.c2s(Colors.white)))),
                    const SizedBox(width: 12),
                    Expanded(child: Text(ranked[i].nama, style: T.b4(), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const AppIcon('star', size: 16, color: C.secondary300, filled: true),
                    const SizedBox(width: 4),
                    Text('${ranked[i].ratingRata.toStringAsFixed(1)} (${ranked[i].jumlahUlasan})', style: T.c2()),
                  ]),
                ),
              ),
            const SizedBox(height: 16),
            Text('Popular Reviews', style: T.h5().copyWith(fontSize: 20)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                for (final e in const [(0, 'Most Relevant'), (1, 'Newest'), (2, 'Highest Rating')])
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => setState(() => _sort = e.$1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(color: _sort == e.$1 ? C.primary900 : C.grey200, borderRadius: BorderRadius.circular(999)),
                        child: Text(e.$2, style: T.b4(_sort == e.$1 ? Colors.white : C.primary500)),
                      ),
                    ),
                  ),
              ]),
            ),
            const SizedBox(height: 16),
            if (sorted.isEmpty) const EmptyText('No reviews found.'),
            for (final r in sorted.take(_shown))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: tuWhiteCard(),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      UserAvatar(name: r.nama, path: r.foto, size: 40, online: true),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r.nama, style: T.s2()), Text(Fmt.dateLong(r.tanggal), style: T.c3(C.grey500))])),
                      Row(mainAxisSize: MainAxisSize.min, children: [for (var i = 1; i <= 5; i++) AppIcon('star', size: 16, color: i <= r.rating ? C.secondary300 : C.grey300, filled: true)]),
                    ]),
                    const SizedBox(height: 10),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: C.grey200, borderRadius: BorderRadius.circular(6)), child: Text(r.namaRuangan ?? '-', style: T.c2s(C.grey800))),
                    const SizedBox(height: 8),
                    Text(r.komentar?.isNotEmpty == true ? r.komentar! : 'No comment.', style: T.b3()),
                  ]),
                ),
              ),
            if (_shown < sorted.length)
              Center(child: AppButton('See All Reviews', onPressed: () => setState(() => _shown += 10), size: BtnSize.medium, iconRight: 'chevron-right')),
          ]);
        },
      ),
    );
  }
}
