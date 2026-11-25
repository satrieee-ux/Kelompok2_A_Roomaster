// ignore_for_file: unused_import
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/nav.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text.dart';
import '../../core/utils/format.dart';
import '../../core/utils/pick.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/bars.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/headers.dart';
import '../../core/widgets/misc.dart';
import '../../core/widgets/page.dart';
import '../../core/widgets/popups.dart';
import '../../core/widgets/tabs.dart';
import '../../data/models.dart';
import '../../data/auth_providers.dart';
import '../../data/booking_providers.dart';
import '../../data/notif_providers.dart';
import '../../data/refresh_all.dart';

// ---------------------------------------------------------------------
// Notifikasi: isi & aksi berbeda per peran
// ---------------------------------------------------------------------
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});
  @override
  ConsumerState<NotificationsScreen> createState() => _NotifState();
}

class _NotifState extends ConsumerState<NotificationsScreen> {
  int _tab = 0;
  bool _showPast = false;

  @override
  void initState() {
    super.initState();
    // tandai terbaca setelah layar terbuka (badge hilang saat kembali)
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;
      try {
        await ref.read(notifRepoP).markAllRead();
        ref.invalidate(unreadNotifP);
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(profileP).valueOrNull?.peran ?? 'mahasiswa';
    final async = ref.watch(notifsP);
    final body = async.when(
      loading: () => const LoadingBox(),
      error: (e, _) => ErrorBox(e, onRetry: () => ref.invalidate(notifsP)),
      data: (all) {
        if (role == 'tu') return _tuList(all);
        if (role == 'sarpras') return _sarprasList(all);
        return _studentList(all);
      },
    );
    switch (role) {
      case 'tu':
        return PageShell(
          header: TopAppBar(title: 'Notifications', onBack: () => goBack(context), onEnd: () => context.go('/menu-utama')),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          onRefresh: () async => ref.invalidate(notifsP),
          child: body,
        );
      case 'sarpras':
        return PageShell(
          header: Column(mainAxisSize: MainAxisSize.min, children: [
            _SubtitleBar(title: 'Notifications', subtitle: 'Manage facility maintenance tasks and system alerts.', onBack: () => goBack(context), onHome: () => context.go('/menu-utama')),
            Container(
              color: C.grey100,
              padding: const EdgeInsets.only(top: 16, bottom: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(children: [
                  for (var i = 0; i < _sarprasTabs.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => setState(() => _tab = i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: i == _tab ? C.primary900 : _sarprasTabs[i].$2,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: i == _tab ? [BoxShadow(color: C.primary500.withOpacity(.35), blurRadius: 8)] : null,
                          ),
                          child: Text(_sarprasTabs[i].$1, style: T.b4(i == _tab ? Colors.white : _sarprasTabs[i].$3)),
                        ),
                      ),
                    ),
                ]),
              ),
            ),
          ]),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          onRefresh: () async => ref.invalidate(notifsP),
          child: body,
        );
      default:
        return PageShell(
          header: Container(
            color: C.grey100,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TopAppBar(title: 'Notifications', onBack: () => goBack(context), onEnd: () => context.go('/menu-utama')),
              const SizedBox(height: 20),
              PillTabs(items: const [TabItem('All'), TabItem('Actions'), TabItem('Updates'), TabItem('System')], active: _tab, onTap: (i) => setState(() => _tab = i)),
              const SizedBox(height: 4),
            ]),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          onRefresh: () async => ref.invalidate(notifsP),
          child: body,
        );
    }
  }

  static const _sarprasTabs = [('All', C.primary900, Colors.white), ('Urgent', C.danger100, C.danger500), ('Maintenance', C.warning100, C.warning500), ('Resolved', C.success100, C.success500)];

  // ---- mahasiswa ----
  Widget _studentList(List<AppNotif> all) {
    final list = all.where((n) {
      switch (_tab) {
        case 1:
          return n.tipe == 'action' || n.tipe == 'unfinished';
        case 2:
          return const {'approved', 'rejected', 'timelimit', 'update'}.contains(n.tipe);
        case 3:
          return n.tipe == 'system';
        default:
          return true;
      }
    }).toList();
    if (list.isEmpty) return const EmptyText('Belum ada notifikasi.');
    return Column(children: [
      for (final n in list)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: NotificationCard(
            type: n.tipe,
            title: n.judul,
            time: Fmt.agoShort(n.waktu),
            message: n.isi,
            unread: !n.sudahDibaca,
            actions: _studentActions(n),
          ),
        ),
    ]);
  }

  List<NotifAction> _studentActions(AppNotif n) {
    final b = n.idPeminjaman;
    final l = n.idLaporan;
    if (l != null) return [NotifAction('Details', () => context.push('/qreporting/summary/$l'))];
    if (b == null) return const [];
    switch (n.tipe) {
      case 'action':
        return [NotifAction('Update', () => context.push('/booking/$b/dokumen')), NotifAction('Details', () => context.push('/bookings/$b'))];
      case 'approved':
        return [NotifAction('Check-In', () => context.push('/checkin/$b')), NotifAction('Details', () => context.push('/bookings/$b'))];
      case 'timelimit':
        return [NotifAction('Check-Out', () => context.push('/checkout/$b'))];
      case 'unfinished':
        return [
          NotifAction('Continue', () => context.push('/booking/$b/dokumen')),
          NotifAction('Cancel Booking', () async {
            final ok = await showConfirmDialog(context, title: 'Cancel Booking?', message: 'This booking will be cancelled.', confirmLabel: 'Yes', cancelLabel: 'No');
            if (!ok) return;
            try {
              await ref.read(bookingRepoP).cancel(b);
              refreshAll(ref);
            } catch (e) {
              if (mounted) showSnack(context, friendlyError(e));
            }
          }),
        ];
      default:
        return [NotifAction('Details', () => context.push('/bookings/$b'))];
    }
  }

  // ---- TU ----
  Widget _tuList(List<AppNotif> all) {
    if (all.isEmpty) return const EmptyText('Belum ada notifikasi.');
    final recent = all.where((n) => DateTime.now().difference(n.waktu).inHours < 48).toList();
    final past = all.where((n) => !recent.contains(n)).toList();
    final shown = _showPast ? all : (recent.isEmpty ? all.take(10).toList() : recent);
    return Column(children: [
      for (final n in shown)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: NotificationCard(
            type: n.tipe,
            title: n.judul,
            time: Fmt.ago(n.waktu),
            message: n.isi,
            unread: !n.sudahDibaca,
            icon: n.tipe == 'action' ? 'plus' : (n.tipe == 'update' ? 'file' : 'alert-circle'),
            iconBg: n.tipe == 'action' ? C.primary500 : (n.tipe == 'update' ? C.primary100 : C.secondary100),
            iconFg: n.tipe == 'action' ? Colors.white : (n.tipe == 'update' ? C.primary500 : C.secondary500),
            actions: n.idPeminjaman == null ? const [] : [NotifAction('Review', () => context.push('/tu/review/${n.idPeminjaman}'))],
          ),
        ),
      if (!_showPast && (past.isNotEmpty || recent.isNotEmpty && all.length > recent.length))
        GestureDetector(
          onTap: () => setState(() => _showPast = true),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('View Past Notifications', style: T.b4(C.primary500)),
            const SizedBox(width: 8),
            const AppIcon('chevron-down', size: 20, color: C.primary500),
          ]),
        ),
    ]);
  }

  // ---- Sarpras ----
  Widget _sarprasList(List<AppNotif> all) {
    final list = all.where((n) {
      switch (_tab) {
        case 1:
          return n.tipe == 'action' || n.tipe == 'timelimit' || n.tipe == 'rejected';
        case 2:
          return n.tipe == 'update' || n.tipe == 'unfinished';
        case 3:
          return n.tipe == 'approved';
        default:
          return true;
      }
    }).toList();
    if (list.isEmpty) return const EmptyText('Belum ada notifikasi.');
    return Column(children: [
      for (final n in list)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: NotificationCard(
            type: n.tipe,
            title: n.judul,
            time: Fmt.ago(n.waktu),
            message: n.isi,
            unread: !n.sudahDibaca,
            icon: n.tipe == 'approved' ? 'check-circle' : (n.tipe == 'update' ? 'file' : (n.tipe == 'timelimit' ? 'clock' : 'alert-circle')),
            iconBg: n.tipe == 'approved' ? C.success100 : (n.tipe == 'update' ? C.primary100 : (n.tipe == 'timelimit' ? C.warning100 : C.secondary100)),
            iconFg: n.tipe == 'approved' ? C.success500 : (n.tipe == 'update' ? C.primary500 : (n.tipe == 'timelimit' ? C.warning500 : C.secondary500)),
            actions: n.idLaporan == null ? const [] : [NotifAction(n.tipe == 'action' ? 'Manage' : 'Details', () => context.push('/sarpras/report/${n.idLaporan}'))],
          ),
        ),
    ]);
  }
}

/// Header putih dengan judul + subjudul kecil (Notifications milik Sarpras).
class _SubtitleBar extends StatelessWidget {
  const _SubtitleBar({required this.title, required this.subtitle, required this.onBack, required this.onHome});
  final String title, subtitle;
  final VoidCallback onBack, onHome;
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      padding: EdgeInsets.fromLTRB(40, top + 8, 40, 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)), boxShadow: C.shadowCard),
      child: Row(children: [
        InkResponse(onTap: onBack, child: const AppIcon('arrow-left')),
        Expanded(
          child: Column(children: [
            Text(title, style: T.s2()),
            const SizedBox(height: 2),
            Text(subtitle, textAlign: TextAlign.center, style: T.c3(C.grey600).copyWith(fontSize: 9, height: 12 / 9)),
          ]),
        ),
        InkResponse(onTap: onHome, child: const AppIcon('home')),
      ]),
    );
  }
}
