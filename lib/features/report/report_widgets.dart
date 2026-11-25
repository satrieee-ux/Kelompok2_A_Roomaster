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

// ---------------------------------------------------------------------
// Riwayat laporan
// ---------------------------------------------------------------------
List<IssueChip> issueChips(List<String> kategori) => [
      for (final k in kategori)
        IssueChip(kReportCategoryIcon[k] ?? 'wrench', const {'ac': 'Faulty AC', 'jaringan': 'Poor Connection', 'proyektor': 'Projector', 'pencahayaan': 'Lighting', 'furnitur': 'Desk/Seating'}[k] ?? (kReportCategoryLabel[k] ?? k)),
    ];

// ---------------------------------------------------------------------
// Ringkasan laporan (juga dipakai Sarpras untuk bukti)
// ---------------------------------------------------------------------
List<TimelineItem> reportTimeline(Report r, List<ReportUpdate> updates) {
  final items = <TimelineItem>[
    TimelineItem('check', StepMode.done, r.status == 'draft' ? 'Draft Saved' : 'Report Submitted', Fmt.ago(r.tanggal)),
  ];
  if (r.status == 'draft') return [...items, const TimelineItem('hourglass', StepMode.todo, 'Pending Review', 'Submit your report to continue.')];
  if (updates.isEmpty) {
    items.add(const TimelineItem('hourglass', StepMode.current, 'Pending Review', 'Awaiting Sarpras Admin approval.'));
  } else {
    for (var i = 0; i < updates.length; i++) {
      final u = updates[i];
      final last = i == updates.length - 1;
      items.add(TimelineItem(u.status == 'selesai' ? 'check' : (u.status == 'ditolak' ? 'x' : 'wrench'), last && !r.isFinal ? StepMode.current : StepMode.done,
          const {'ditinjau': 'Under Review', 'diproses': 'In Progress', 'menunggu_suku_cadang': 'Waiting for Parts', 'selesai': 'Resolved', 'ditolak': 'Rejected'}[u.status] ?? u.status,
          u.catatan?.isNotEmpty == true ? u.catatan! : Fmt.ago(u.waktu)));
    }
  }
  if (!r.isFinal) items.add(const TimelineItem('calendar-check', StepMode.todo, 'Confirmation', 'Taken action for report'));
  return items;
}

class ReportEvidenceGrid extends ConsumerWidget {
  const ReportEvidenceGrid({super.key, required this.id, this.height = 146});
  final int id;
  final double height;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = (ref.watch(reportMediaP(id)).valueOrNull ?? const <ReportMedia>[]).where((m) => m.idUpdate == null).toList();
    if (media.isEmpty) return Text('No evidence attached.', style: T.b3(C.grey500));
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.15,
      children: [for (final m in media) SignedImage(bucket: 'laporan', path: m.path, radius: BorderRadius.circular(12))],
    );
  }
}
