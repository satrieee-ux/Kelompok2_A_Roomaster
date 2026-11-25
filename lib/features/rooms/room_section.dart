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
import 'room_card_helpers.dart';

const kCategoryLabels = {'skpb': 'SKPB', 'departemen': 'Departemen'};

const kUsageLabels = {'academic': 'Academic', 'meetings': 'Meetings', 'events': 'Events', 'group_study': 'Group Study', 'creativity': 'Creativity'};

/// Seksi: judul + (row | stack | list).
class RoomSection extends ConsumerWidget {
  const RoomSection({super.key, required this.title, required this.rooms, this.layout = 'row', this.seeAll});
  final String title;
  final List<Room> rooms;
  final String layout;
  final VoidCallback? seeAll;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (rooms.isEmpty) return const SizedBox.shrink();
    Widget body;
    if (layout == 'stack') {
      body = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(children: [for (final r in rooms) Padding(padding: const EdgeInsets.only(bottom: 12), child: roomCardFor(context, ref, r, large: true))]),
      );
    } else if (layout == 'list') {
      body = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(children: [
          for (final r in rooms)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RoomCardHorizontal(
                title: r.nama,
                department: r.departemen ?? '-',
                capacity: Fmt.capacityLong(r.kapasitas),
                imagePath: r.foto,
                favorite: r.favorite,
                onOpen: () => openRoomFromSearch(context, r),
                onFavorite: () => toggleFavorite(ref, r),
              ),
            ),
        ]),
      );
    } else {
      body = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (final r in rooms) Padding(padding: const EdgeInsets.only(right: 12), child: roomCardFor(context, ref, r)),
          ]),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: SectionHeader(title, onSeeAll: seeAll, height: 28)),
        const SizedBox(height: 12),
        body,
      ]),
    );
  }
}

Future<void> openRoomFromSearch(BuildContext context, Room r) async {
  final sp = await SharedPreferences.getInstance();
  final list = sp.getStringList('recent_rooms') ?? [];
  list.remove('${r.id}');
  list.insert(0, '${r.id}');
  await sp.setStringList('recent_rooms', list.take(10).toList());
  if (context.mounted) context.push('/rooms/${r.id}');
}
