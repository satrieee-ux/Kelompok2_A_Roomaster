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
import '../../data/room_providers.dart';
import '../home/common.dart';
import 'room_section.dart';

class RoomsScreen extends ConsumerStatefulWidget {
  const RoomsScreen({super.key, this.category});
  final String? category; // Quick Book: kategori_penggunaan
  @override
  ConsumerState<RoomsScreen> createState() => _RoomsState();
}

class _RoomsState extends ConsumerState<RoomsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsP);
    final cat = widget.category;
    return PageShell(
      header: Column(mainAxisSize: MainAxisSize.min, children: [
        const RoleHomeHeader(heading: 'Let’s book your room.'),
        Container(
          color: C.grey100,
          padding: const EdgeInsets.only(top: 24, bottom: 16),
          child: PillTabs(
            items: const [TabItem('All'), TabItem('SKPB'), TabItem('Departemen'), TabItem('Favorites', icon: 'heart')],
            active: _tab,
            onTap: (i) => setState(() => _tab = i),
          ),
        ),
      ]),
      padding: const EdgeInsets.only(bottom: 20),
      onRefresh: () async => ref.invalidate(roomsP),
      bottom: RoomasterNavBar(active: 'rooms', onSelect: (k) => goStudentNav(context, k)),
      child: roomsAsync.when(
        loading: () => const LoadingBox(),
        error: (e, _) => ErrorBox(e, onRetry: () => ref.invalidate(roomsP)),
        data: (all) {
          var rooms = all;
          if (cat != null) rooms = rooms.where((r) => r.kategoriPenggunaan.contains(cat)).toList();
          final byBooked = [...rooms]..sort((a, b) => b.jumlahPeminjaman.compareTo(a.jumlahPeminjaman));
          final byRating = [...rooms]..sort((a, b) => b.ratingRata.compareTo(a.ratingRata));
          final children = <Widget>[];
          if (cat != null) {
            children.add(Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Row(children: [
                Text('Quick Book: ${kUsageLabels[cat] ?? cat}', style: T.b4(C.primary500)),
                const Spacer(),
                GestureDetector(onTap: () => context.go('/rooms'), child: Text('Clear', style: T.b4(C.primary500).copyWith(decoration: TextDecoration.underline))),
              ]),
            ));
          }
          switch (_tab) {
            case 0:
              children.addAll([
                RoomSection(title: 'Frequently Booked', rooms: byBooked.take(6).toList()),
                RoomSection(title: 'Recommended', layout: 'stack', rooms: byRating.take(6).toList()),
              ]);
            case 1:
            case 2:
              final k = _tab == 1 ? 'skpb' : 'departemen';
              final sub = rooms.where((r) => r.kategori == k).toList();
              final groups = <String, List<Room>>{};
              for (final r in sub) {
                groups.putIfAbsent(r.kelompok ?? kCategoryLabels[k]!, () => []).add(r);
              }
              for (final e in groups.entries) {
                children.add(RoomSection(title: e.key, rooms: e.value));
              }
              final rec = [...sub]..sort((a, b) => b.ratingRata.compareTo(a.ratingRata));
              children.add(RoomSection(title: 'Recommended', layout: 'stack', rooms: rec.take(4).toList()));
            default:
              final fav = rooms.where((r) => r.favorite).toList();
              children.add(fav.isEmpty ? const EmptyText('No favorite rooms yet. Tap the heart on a room to save it.') : RoomSection(title: 'Your Favorites', layout: 'stack', rooms: fav));
          }
          if (rooms.isEmpty) children.add(const EmptyText('No rooms match this category.'));
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
        },
      ),
    );
  }
}
