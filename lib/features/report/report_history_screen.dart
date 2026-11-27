// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../app/nav.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text.dart';
import '../../core/utils/format.dart';
import '../../core/utils/pick.dart';
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
import '../../data/report_providers.dart';
import 'report_widgets.dart';

class ReportHistoryScreen extends ConsumerStatefulWidget {
  const ReportHistoryScreen({super.key});
  @override
  ConsumerState<ReportHistoryScreen> createState() => _HistoryState();
}

class _HistoryState extends ConsumerState<ReportHistoryScreen> {
  int _tab = 0;
  bool _match(Report r) {
    switch (_tab) {
      case 1:
        return !r.isFinal;
      case 2:
        return const {'ditinjau', 'diproses', 'menunggu_suku_cadang', 'selesai'}.contains(r.status);
      case 3:
        return r.status == 'pending';
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(myReportsP);
    return PageShell(
      header: Container(
        color: C.grey100,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TopAppBar(title: 'Reports History', onBack: () => goBack(context, '/qreporting'), onEnd: () => context.go('/menu-utama')),
          Padding(padding: const EdgeInsets.fromLTRB(24, 20, 24, 0), child: LineTabs(items: const ['All', 'Active', 'Approved', 'Pending'], active: _tab, onTap: (i) => setState(() => _tab = i))),
        ]),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      onRefresh: () async => ref.invalidate(myReportsP),
      child: async.when(
        loading: () => const LoadingBox(),
        error: (e, _) => ErrorBox(e, onRetry: () => ref.invalidate(myReportsP)),
        data: (all) {
          final list = all.where(_match).toList();
          if (list.isEmpty) return const EmptyText('Belum ada laporan.');
          return Column(children: [
            for (final r in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ReportCard(
                  title: r.kodeRuangan.isEmpty ? r.namaRuangan : r.kodeRuangan,
                  date: Fmt.dateShort(r.tanggal),
                  department: r.departemen ?? '-',
                  status: r.uiStatus,
                  statusLabel: r.uiLabel,
                  issues: issueChips(r.kategori),
                  onDetails: () => context.push('/qreporting/summary/${r.id}'),
                  onContinue: r.status == 'draft' ? () => context.push('/qreporting/report?draft=${r.id}') : null,
                ),
              ),
          ]);
        },
      ),
    );
  }
}
