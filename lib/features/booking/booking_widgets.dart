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

/// Kartu Facility / Schedule / Activity / Documents (dipakai Ringkasan, Booking Summary, dan TU Review).
class BookingDetailCards extends StatelessWidget {
  const BookingDetailCards({super.key, required this.booking, this.room, this.docs = const [], this.onEditDocs, this.summaryStyle = true, this.showFacility = true});
  final Booking booking;
  final Room? room;
  final List<BookingDoc> docs;
  final VoidCallback? onEditDocs;
  final bool summaryStyle;
  final bool showFacility;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final facs = [Facility(Fmt.capacityShort(b.kapasitas), 'users'), ...?room?.fasilitas];
    final cardBorder = summaryStyle ? C.grey200 : C.grey300;
    return Column(children: [
      if (showFacility)
        InfoCard(
          title: 'Facility Information',
          border: cardBorder,
          trailing: summaryStyle ? Text('Booking #${b.kode}', style: T.c3(C.grey500)) : null,
          children: [
            KeyValue('Room Name', b.namaRuangan, valueStyle: T.s1()),
            KeyValue('Location', b.lokasi ?? b.departemenRuangan ?? '-', valueStyle: T.b3()),
            KeyValue('Capacity', Fmt.capacityLong(b.kapasitas), icon: 'users'),
            KeyValue('Facilities Included', null, child: Wrap(runSpacing: 8, children: [
              for (final f in facs.skip(1))
                SizedBox(width: (MediaQuery.sizeOf(context).width - 48 - 40 - 16) / 2, child: Row(children: [AppIcon(f.ikon, size: 20), const SizedBox(width: 8), Flexible(child: Text(f.nama, style: T.b3()))])),
            ])),
          ],
        ),
      if (showFacility) const SizedBox(height: 16),
      InfoCard(title: 'Schedule', border: cardBorder, children: [
        KeyValue('Date', Fmt.dateLong(b.tanggal), valueStyle: T.b2().copyWith(fontWeight: FontWeight.w600)),
        KeyValue('Time', Fmt.rangeHours(b.mulai, b.selesai), valueStyle: T.b2().copyWith(fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 16),
      InfoCard(title: 'Activity Details', border: cardBorder, children: [
        KeyValue('Activity Name', b.namaKegiatan, valueStyle: T.s2()),
        KeyValue('Department', b.departemenPenyelenggara, valueStyle: T.b3()),
        KeyValue('Description', b.tujuan, valueStyle: T.b3()),
      ]),
      const SizedBox(height: 16),
      InfoCard(
        title: 'Supporting Documents',
        border: cardBorder,
        trailing: onEditDocs == null ? null : GestureDetector(onTap: onEditDocs, child: const AppIcon('pencil', size: 20)),
        children: [
          if (docs.isEmpty) Text('No documents attached.', style: T.b3(C.grey500)),
          for (final d in docs)
            GestureDetector(
              onTap: () async {
                final url = await StorageUrls.signedUrl('dokumen', d.path);
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              },
              child: FileCard(name: d.nama, size: Fmt.fileSize(d.ukuran)),
            ),
        ],
      ),
    ]);
  }
}
