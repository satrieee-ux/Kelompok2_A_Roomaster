// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/nav.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text.dart';
import '../../core/utils/format.dart';
import '../../core/utils/pick.dart';
import '../../core/utils/storage_url.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/bars.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/forms.dart';
import '../../core/widgets/headers.dart';
import '../../core/widgets/misc.dart';
import '../../core/widgets/page.dart';
import '../../core/widgets/popups.dart';
import '../../core/widgets/status.dart';
import '../../core/widgets/tabs.dart';
import '../../data/models.dart';
import '../../data/booking_providers.dart';
import '../home/common.dart';

// ---------------------------------------------------------------------
// Daftar booking
// ---------------------------------------------------------------------
class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});
  @override
  ConsumerState<BookingsScreen> createState() => _BookingsState();
}

class _BookingsState extends ConsumerState<BookingsScreen> {
  int _tab = 0;
  bool _desc = true;

  bool _match(Booking b) {
    switch (_tab) {
      case 1:
        return b.isActive;
      case 2:
        return b.status == 'disetujui' || b.status == 'berlangsung';
      case 3:
        return b.status == 'pending' || b.status == 'revisi';
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(myBookingsP);
    return PageShell(
      header: Container(
        color: C.grey100,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const RoleCompactHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Your Bookings', style: T.h5(C.primary800)),
              GestureDetector(onTap: () => setState(() => _desc = !_desc), child: const AppIcon('sort', size: 20, color: C.primary500)),
            ]),
          ),
          Padding(padding: const EdgeInsets.fromLTRB(24, 12, 24, 0), child: LineTabs(items: const ['All', 'Active', 'Approved', 'Pending'], active: _tab, onTap: (i) => setState(() => _tab = i))),
        ]),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      onRefresh: () async => ref.invalidate(myBookingsP),
      bottom: RoomasterNavBar(active: 'scheduled', onSelect: (k) => goStudentNav(context, k)),
      child: async.when(
        loading: () => const LoadingBox(),
        error: (e, _) => ErrorBox(e, onRetry: () => ref.invalidate(myBookingsP)),
        data: (all) {
          final list = all.where(_match).toList();
          if (!_desc) list.sort((a, b) => a.startAt.compareTo(b.startAt));
          if (list.isEmpty) return const EmptyText('No bookings here yet.');
          return Column(children: [
            for (final b in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: BookingHistoryCard(
                  title: b.namaRuangan,
                  date: Fmt.dateShort(b.tanggal),
                  time: Fmt.rangeWib(b.mulai, b.selesai),
                  department: b.departemenRuangan ?? '-',
                  imagePath: b.fotoRuangan,
                  status: b.uiStatus,
                  statusLabel: b.uiLabel,
                  onDetails: () => context.push(b.status == 'draft' ? '/booking/${b.id}/dokumen' : '/bookings/${b.id}'),
                ),
              ),
          ]);
        },
      ),
    );
  }
}
