// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/nav.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/bars.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/misc.dart';
import '../../core/widgets/page.dart';
import '../../data/models.dart';
import '../../data/room_providers.dart';

/// Hasil kartu ruangan dipakai ulang di beberapa layar.
Widget roomCardFor(BuildContext context, WidgetRef ref, Room r, {bool large = false}) => RoomCardVertical(
      title: r.nama,
      department: r.departemen ?? '-',
      capacity: Fmt.capacityShort(r.kapasitas),
      imagePath: r.foto,
      favorite: r.favorite,
      large: large,
      onOpen: () => context.push('/rooms/${r.id}'),
      onBook: () => context.push('/rooms/${r.id}/book'),
      onFavorite: () => toggleFavorite(ref, r),
    );

Future<void> toggleFavorite(WidgetRef ref, Room r) async {
  await ref.read(roomRepoP).setFavorite(r.id, !r.favorite);
  ref.invalidate(roomsP);
}
