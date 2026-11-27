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
import 'tu_widgets.dart';

// ---------------------------------------------------------------------
// TU ACC (review)
// ---------------------------------------------------------------------
class TuReviewScreen extends ConsumerWidget {
  const TuReviewScreen({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(bookingP(id));
    return async.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(appBar: AppBar(), body: Center(child: ErrorBox(e, onRetry: () => ref.invalidate(bookingP(id))))),
      data: (b) {
        final docs = ref.watch(bookingDocsP(id)).valueOrNull ?? const <BookingDoc>[];
        final canAct = b.status == 'pending';
        return PageShell(
          header: TopAppBar(title: 'Review', onBack: () => goBack(context), onEnd: () => context.go('/menu-utama')),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          onRefresh: () async => ref.invalidate(bookingP(id)),
          bottom: canAct
              ? DarkBottomBar(
                  child: Row(children: [
                    Expanded(
                      child: AppButton('Reject', size: BtnSize.medium, expand: true, bg: C.grey50, fg: C.primary500, onPressed: () async {
                        final r = await showReasonDialog(context, message: 'Before rejecting, make sure that the request indeed did not meet Roomaster’s Terms & Conditions.', hint: 'State the reason of rejection...');
                        if (r != null && context.mounted) await tuDoReview(context, ref, b, 'tolak', r);
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton('Revise', size: BtnSize.medium, expand: true, bg: C.primary500, fg: Colors.white, onPressed: () async {
                        final r = await showReasonDialog(context, message: 'Before requesting for revision, make sure that the request indeed did not meet Roomaster’s Terms & Conditions.', hint: 'State the reason of revision...');
                        if (r != null && context.mounted) await tuDoReview(context, ref, b, 'revisi', r);
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: AppButton('Approve', size: BtnSize.medium, expand: true, bg: C.secondary500, fg: Colors.white, onPressed: () => quickApprove(context, ref, b))),
                  ]),
                )
              : ActionBar(children: [Row(mainAxisAlignment: MainAxisAlignment.center, children: [StatusPill(b.uiStatus, label: b.uiLabel), const SizedBox(width: 8), Text('This request is no longer pending.', style: T.c2(C.grey600))])]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: C.grey300)),
              child: Text('#${b.kode}', style: T.c2(C.grey500)),
            ),
            const SizedBox(height: 12),
            Text(b.namaRuangan, style: T.h5()),
            Text(b.namaKegiatan, style: T.b1(C.grey600)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: C.grey50, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.grey300)),
              child: IntrinsicHeight(
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Requested By', style: T.c2(C.grey600)), const SizedBox(height: 4), Text(b.namaPeminjam, style: T.b2())])),
                  const VerticalDivider(color: C.grey300, width: 24),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Submitted', style: T.c2(C.grey600)), const SizedBox(height: 4), Text(Fmt.dateShort(b.tanggalPengajuan ?? b.tanggal), style: T.b2())])),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            InfoCard(
              title: 'Schedule & Utilization',
              titleStyle: T.s2(),
              children: [
                KeyValue('Date', Fmt.dateLong(b.tanggal), valueStyle: T.b2()),
                KeyValue('Time', Fmt.rangeHours(b.mulai, b.selesai), valueStyle: T.b2()),
                KeyValue('Purpose of Use', b.tujuan, valueStyle: T.b3()),
                KeyValue('Organizer', b.departemenPenyelenggara, valueStyle: T.b3()),
                KeyValue('Room Capacity', Fmt.capacityLong(b.kapasitas), valueStyle: T.b3()),
              ],
            ),
            const SizedBox(height: 16),
            InfoCard(title: 'Supporting Documents', gap: 12, children: [
              if (docs.isEmpty) Text('No documents attached.', style: T.b3(C.grey500)),
              for (final d in docs) FileCard(name: d.nama, size: Fmt.fileSize(d.ukuran)),
            ]),
            if (b.catatanTu != null && b.catatanTu!.isNotEmpty) ...[
              const SizedBox(height: 16),
              InfoCard(title: 'Review Note', children: [Text(b.catatanTu!, style: T.b3())]),
            ],
          ]),
        );
      },
    );
  }
}
