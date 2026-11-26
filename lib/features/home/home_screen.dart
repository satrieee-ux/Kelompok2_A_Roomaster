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
import '../../data/auth_providers.dart';
import '../../data/booking_providers.dart';
import '../../data/refresh_all.dart';
import '../../data/room_providers.dart';
import '../rooms/room_card_helpers.dart';
import 'common.dart';

const _quickBook = [
  ('Academic', 'globe', 'academic'),
  ('Meetings', 'user-round', 'meetings'),
  ('Events', 'users-round', 'events'),
  ('Group Study', 'lightbulb', 'group_study'),
  ('Creativity', 'palette', 'creativity'),
];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(profileP).valueOrNull;
    final rooms = ref.watch(roomsP);
    final up = ref.watch(upcomingP);
    return PageShell(
      header: RoleHomeHeader(heading: '${greeting()}, ${p?.firstName ?? ''}!'),
      padding: const EdgeInsets.only(top: 24, bottom: 20),
      onRefresh: () async => refreshAll(ref),
      bottom: RoomasterNavBar(active: 'home', onSelect: (k) => goStudentNav(context, k)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Upcoming Bookings
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SectionHeader('Upcoming Bookings', onSeeAll: () => context.go('/bookings')),
            const SizedBox(height: 12),
            up.when(
              loading: () => const LoadingBox(height: 156),
              error: (e, _) => ErrorBox(e, onRetry: () => ref.invalidate(upcomingP)),
              data: (b) => b == null ? const EmptyText('No upcoming bookings yet.') : _upcomingCard(context, ref, b),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        // Quick Book
        const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: SectionHeader('Quick Book')),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(children: [
            for (final q in _quickBook)
              GestureDetector(
                onTap: () => context.go('/rooms?category=${q.$3}'),
                child: SizedBox(
                  width: 88,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(color: C.grey200, borderRadius: BorderRadius.circular(24)),
                        child: Center(child: AppIcon(q.$2, size: 36, stroke: 1.5, color: C.primary500)),
                      ),
                      const SizedBox(height: 10),
                      Text(q.$1, style: T.b4(C.grey800).copyWith(fontWeight: FontWeight.w500), maxLines: 1),
                    ]),
                  ),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 16),
        rooms.when(
          loading: () => const LoadingBox(),
          error: (e, _) => ErrorBox(e, onRetry: () => ref.invalidate(roomsP)),
          data: (all) {
            final recent = [...all]..sort((a, b) => b.jumlahPeminjaman.compareTo(a.jumlahPeminjaman));
            final rec = [...all]..sort((a, b) => b.ratingRata.compareTo(a.ratingRata));
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: SectionHeader('Recently Booked', onSeeAll: () => context.go('/rooms'), style: T.s1(C.primary800))),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: IntrinsicHeight(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    for (final r in recent.take(6)) Padding(padding: const EdgeInsets.only(right: 12), child: roomCardFor(context, ref, r)),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SectionHeader('Recommended', onSeeAll: () => context.go('/rooms')),
                  const SizedBox(height: 12),
                  for (final r in rec.take(4)) Padding(padding: const EdgeInsets.only(bottom: 12), child: roomCardFor(context, ref, r, large: true)),
                ]),
              ),
            ]);
          },
        ),
      ]),
    );
  }

  Widget _upcomingCard(BuildContext context, WidgetRef ref, Booking b) {
    final today = DateTime.now();
    final isToday = b.tanggal.year == today.year && b.tanggal.month == today.month && b.tanggal.day == today.day;
    final dateLabel = isToday ? 'Today, ${Fmt.dateShort(b.tanggal)}' : Fmt.dateShort(b.tanggal);
    final canCheckIn = b.status == 'disetujui' && isToday;
    final inUse = b.status == 'berlangsung';
    return BookingCard(
      title: b.namaRuangan,
      date: dateLabel,
      time: Fmt.rangeWib(b.mulai, b.selesai),
      department: b.departemenRuangan ?? '-',
      imagePath: b.fotoRuangan,
      status: 'upcoming',
      statusLabel: inUse ? 'In Use' : null,
      primaryLabel: inUse ? 'Check-Out' : (canCheckIn ? 'Check-In' : null),
      onPrimary: inUse ? () => context.push('/checkout/${b.id}') : () => context.push('/checkin/${b.id}'),
      onDetails: () => context.push('/bookings/${b.id}'),
    );
  }
}
