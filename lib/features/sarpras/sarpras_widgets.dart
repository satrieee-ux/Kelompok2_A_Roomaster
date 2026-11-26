// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/nav.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/bars.dart';
import '../../core/widgets/forms.dart';
import '../../core/widgets/headers.dart';
import '../../core/widgets/misc.dart';
import '../../core/widgets/page.dart';
import '../../core/widgets/status.dart';
import '../../data/models.dart';

BoxDecoration sarprasCard() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: C.shadowCard);

String sarprasFirstDesc(Report r) => r.deskripsi.isEmpty ? '-' : r.deskripsi;

/// Kartu laporan aktif / riwayat milik Sarpras.
class SarprasReportCard extends StatelessWidget {
  const SarprasReportCard({required this.r, required this.onDetails, this.showPill = false});
  final Report r;
  final VoidCallback onDetails;
  final bool showPill;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: sarprasCard(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: C.grey300)),
            child: Text(r.nomor, style: T.c3(C.grey500)),
          ),
          if (showPill) StatusPill(r.uiStatus, label: r.uiLabel),
        ]),
        const SizedBox(height: 8),
        Text(r.kodeRuangan.isEmpty ? r.namaRuangan : r.kodeRuangan, style: T.s1()),
        const SizedBox(height: 4),
        Text('${r.judul} - ${sarprasFirstDesc(r)}', style: T.b3(C.grey600), maxLines: 2, overflow: TextOverflow.ellipsis),
        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: C.grey300)),
        Row(children: [
          Expanded(child: Text('Reported Since: ${Fmt.dateLong(r.tanggal)}', style: T.c2s())),
          const SizedBox(width: 12),
          SizedBox(width: 120, child: AppButton('Details', onPressed: onDetails, variant: BtnVariant.soft, size: BtnSize.tiny, expand: true)),
        ]),
      ]),
    );
  }
}
