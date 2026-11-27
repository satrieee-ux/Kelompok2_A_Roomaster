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
import '../../data/refresh_all.dart';

String tuRoleLabel(String peran) => 'Mahasiswa ITS';

BoxDecoration tuWhiteCard() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: C.shadowCard);

class TuQueueCard extends StatelessWidget {
  const TuQueueCard({required this.b, required this.onReview, this.onQuickApprove});
  final Booking b;
  final VoidCallback onReview;
  final VoidCallback? onQuickApprove;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: tuWhiteCard(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text(b.namaRuangan, style: T.s1(), maxLines: 1, overflow: TextOverflow.ellipsis)),
          if (onQuickApprove == null) StatusPill(b.uiStatus, label: b.uiLabel),
        ]),
        const SizedBox(height: 4),
        Row(children: [const AppIcon('user', size: 16), const SizedBox(width: 8), Flexible(child: Text('${b.namaPeminjam} (${tuRoleLabel(b.peranPeminjam)})', style: T.b4().copyWith(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis))]),
        const SizedBox(height: 4),
        Row(children: [const AppIcon('clock', size: 16), const SizedBox(width: 8), Flexible(child: Text('${Fmt.dateLong(b.tanggal)} | ${Fmt.rangeWib(b.mulai, b.selesai).replaceAll('.', ':').replaceAll('-', ' - ')}', style: T.b3().copyWith(fontSize: 13)))]),
        const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: C.grey300)),
        Text('Requested since: ${Fmt.dateLong(b.tanggalPengajuan ?? b.tanggal)}', style: T.c2s()),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: AppButton('Review', onPressed: onReview, size: BtnSize.tiny, expand: true)),
          if (onQuickApprove != null) ...[
            const SizedBox(width: 12),
            Expanded(child: AppButton('Quick Approve', onPressed: onQuickApprove, size: BtnSize.tiny, expand: true, bg: C.secondary500, fg: Colors.white)),
          ],
        ]),
      ]),
    );
  }
}

Future<void> tuDoReview(BuildContext context, WidgetRef ref, Booking b, String aksi, String? catatan) async {
  try {
    await ref.read(bookingRepoP).tinjau(b.id, aksi, catatan);
    refreshAll(ref);
    ref.invalidate(bookingP(b.id));
    if (context.mounted) context.go('/tu/result/${aksi == 'setujui' ? 'approved' : (aksi == 'revisi' ? 'revised' : 'rejected')}?code=${b.kode}');
  } catch (e) {
    if (context.mounted) showSnack(context, friendlyError(e));
  }
}

Future<void> quickApprove(BuildContext context, WidgetRef ref, Booking b) async {
  final ok = await showConfirmDialog(context, title: 'Are you sure?', message: 'Before approving, make sure the request meets Roomaster’s Terms & Conditions.', confirmLabel: 'Proceed', cancelLabel: 'Cancel', icon: 'check-circle', iconColor: C.success500, iconBg: C.success100);
  if (ok && context.mounted) await tuDoReview(context, ref, b, 'setujui', null);
}
