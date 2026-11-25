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

class ReportSummaryScreen extends ConsumerWidget {
  const ReportSummaryScreen({super.key, required this.id});
  final int id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(reportP(id));
    return async.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(appBar: AppBar(), body: Center(child: ErrorBox(e, onRetry: () => ref.invalidate(reportP(id))))),
      data: (r) {
        final updates = ref.watch(reportUpdatesP(id)).valueOrNull ?? const <ReportUpdate>[];
        return PageShell(
          header: TopAppBar(title: 'Report Summary', onBack: () => goBack(context, '/qreporting/history'), onEnd: () => context.go('/menu-utama')),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          onRefresh: () async {
            ref.invalidate(reportP(id));
            ref.invalidate(reportUpdatesP(id));
          },
          bottom: ActionBar(note: 'All Reports are managed according to the facility usage terms and conditions.', children: [
            AppButton('Done', onPressed: () => goBack(context, '/qreporting/history'), expand: true),
            AppButton('Report another', onPressed: () => context.go('/qreporting'), variant: BtnVariant.secondary, expand: true),
          ]),
          child: Column(children: [
            StatusBanner(r.uiStatus, label: r.uiLabel, updated: Fmt.ago(updates.isEmpty ? r.tanggal : updates.last.waktu)),
            const SizedBox(height: 16),
            InfoCard(title: 'Facility Information', trailing: Text('Report #${r.nomor}', style: T.c3(C.grey500)), children: [
              KeyValue('Room Name', r.kodeRuangan.isEmpty ? r.namaRuangan : r.kodeRuangan, valueStyle: T.s1()),
              KeyValue('Location', r.lokasi ?? r.departemen ?? '-', valueStyle: T.b3()),
              KeyValue('Date of Report', Fmt.dateLong(r.tanggal), valueStyle: T.b2().copyWith(fontWeight: FontWeight.w600)),
              KeyValue('Issue Reported', null, child: Wrap(spacing: 16, runSpacing: 8, children: [
                for (final i in issueChips(r.kategori)) Row(mainAxisSize: MainAxisSize.min, children: [AppIcon(i.icon, size: 20), const SizedBox(width: 8), Text(i.label, style: T.b3())]),
              ])),
            ]),
            const SizedBox(height: 16),
            InfoCard(title: 'Issue Description', children: [Text(r.deskripsi.isEmpty ? '-' : r.deskripsi, style: T.b3())]),
            const SizedBox(height: 16),
            InfoCard(title: 'Recent Activity', titleStyle: T.s1(), children: [ActivityTimeline(items: reportTimeline(r, updates))]),
            const SizedBox(height: 16),
            Align(alignment: Alignment.centerLeft, child: Text('Evidence', style: T.s2())),
            const SizedBox(height: 12),
            ReportEvidenceGrid(id: id),
          ]),
        );
      },
    );
  }
}
