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
import '../../data/booking_providers.dart';
import '../home/common.dart';
import 'tu_widgets.dart';

// ---------------------------------------------------------------------
// TU Approval Dashboard
// ---------------------------------------------------------------------
class TuDashboardScreen extends ConsumerStatefulWidget {
  const TuDashboardScreen({super.key});
  @override
  ConsumerState<TuDashboardScreen> createState() => _TuDashState();
}

class _TuDashState extends ConsumerState<TuDashboardScreen> {
  int _tab = 0;
  final _q = TextEditingController();

  bool _match(Booking b) {
    final q = _q.text.trim().toLowerCase();
    if (q.isNotEmpty && !('${b.namaRuangan} ${b.namaPeminjam} ${b.kode} ${b.namaKegiatan}').toLowerCase().contains(q)) return false;
    switch (_tab) {
      case 1:
        return const {'disetujui', 'berlangsung', 'selesai'}.contains(b.status);
      case 2:
        return b.status == 'ditolak' || b.status == 'revisi';
      default:
        return b.status == 'pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(tuBookingsP);
    return PageShell(
      header: Column(mainAxisSize: MainAxisSize.min, children: [
        RoleHomeHeader(heading: 'Let’s Review these Books.', controller: _q, onChanged: (_) => setState(() {}), chatRoute: '/chat', notifRoute: '/notifikasi'),
        Container(color: C.grey50, padding: const EdgeInsets.fromLTRB(0, 0, 0, 0), child: LineTabs(items: const ['Pending', 'Approved', 'Rejected'], active: _tab, onTap: (i) => setState(() => _tab = i))),
      ]),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      onRefresh: () async => ref.invalidate(tuBookingsP),
      bottom: StaffNavBar(items: StaffNavBar.tu, active: 'dashboard', onSelect: (k) => goTuNav(context, k)),
      child: async.when(
        loading: () => const LoadingBox(),
        error: (e, _) => ErrorBox(e, onRetry: () => ref.invalidate(tuBookingsP)),
        data: (all) {
          final list = all.where(_match).toList();
          final pending = all.where((b) => b.status == 'pending').length;
          if (_tab != 0) list.sort((a, b) => b.startAt.compareTo(a.startAt));
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_tab == 0 ? 'Review Queue' : (_tab == 1 ? 'Approved Requests' : 'Rejected & Revision'), style: T.h5()),
            const SizedBox(height: 4),
            Text(_tab == 0 ? 'There are $pending pending booking requests awaiting your approval.' : '${list.length} requests in this list.', style: T.b3(C.grey600)),
            const SizedBox(height: 16),
            if (list.isEmpty) const EmptyText('Nothing here.'),
            for (final b in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TuQueueCard(b: b, onReview: () => context.push('/tu/review/${b.id}'), onQuickApprove: _tab == 0 ? () => quickApprove(context, ref, b) : null),
              ),
          ]);
        },
      ),
    );
  }
}
