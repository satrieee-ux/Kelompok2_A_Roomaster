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
import '../../data/refresh_all.dart';
import '../../data/report_providers.dart';
import '../report/report_widgets.dart';

// ---------------------------------------------------------------------
// Damage Report (detail) + Update Status
// ---------------------------------------------------------------------
class DamageReportScreen extends ConsumerWidget {
  const DamageReportScreen({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(reportP(id));
    return async.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(appBar: AppBar(), body: Center(child: ErrorBox(e, onRetry: () => ref.invalidate(reportP(id))))),
      data: (r) {
        final updates = ref.watch(reportUpdatesP(id)).valueOrNull ?? const <ReportUpdate>[];
        final prio = r.tingkat == 'berat' ? C.secondary500 : (r.tingkat == 'sedang' ? C.warning500 : C.grey800);
        return PageShell(
          header: TopAppBar(title: 'Report Details', onBack: () => goBack(context, '/menu-utama'), onEnd: null),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          onRefresh: () async {
            ref.invalidate(reportP(id));
            ref.invalidate(reportUpdatesP(id));
          },
          bottom: DarkBottomBar(
            child: Row(children: [
              Expanded(child: AppButton('Cancel', size: BtnSize.medium, expand: true, bg: C.grey50, fg: C.primary500, onPressed: () => goBack(context, '/menu-utama'))),
              const SizedBox(width: 16),
              Expanded(child: AppButton('Update Status', size: BtnSize.medium, expand: true, bg: C.secondary500, fg: Colors.white, onPressed: r.status == 'draft' ? null : () => _openUpdate(context, ref, r))),
            ]),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.judul, style: T.h5()),
            const SizedBox(height: 2),
            Text('#${r.nomor}', style: T.b3(C.grey500)),
            const SizedBox(height: 16),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _kv('Location', '${r.kodeRuangan.isEmpty ? r.namaRuangan : r.kodeRuangan}${r.departemen == null ? '' : ', ${r.departemen}'}')),
              const SizedBox(width: 16),
              Expanded(child: _kv('Reported By', r.namaPelapor)),
            ]),
            const SizedBox(height: 16),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _kv('Date Reported', Fmt.dateShort(r.tanggal))),
              const SizedBox(width: 16),
              Expanded(child: _kv('Priority', r.tingkat == null ? 'Not set' : r.tingkatLabel, color: prio)),
            ]),
            const SizedBox(height: 16),
            _kv('Status', r.uiLabel),
            const SizedBox(height: 16),
            _kv('Details', r.deskripsi.isEmpty ? '-' : r.deskripsi),
            const SizedBox(height: 16),
            Text('Report Evidence', style: T.s2()),
            const SizedBox(height: 12),
            ReportEvidenceGrid(id: id),
            if (updates.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Update History', style: T.s2()),
              const SizedBox(height: 8),
              for (final u in updates.reversed)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: C.grey50, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.grey200)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Text(const {'ditinjau': 'Under Review', 'diproses': 'In Progress', 'menunggu_suku_cadang': 'Waiting for Parts', 'selesai': 'Resolved', 'ditolak': 'Rejected'}[u.status] ?? u.status, style: T.b4()), const Spacer(), Text(Fmt.ago(u.waktu), style: T.c3(C.grey500))]),
                    if (u.catatan != null && u.catatan!.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(u.catatan!, style: T.b3(C.grey600))),
                  ]),
                ),
            ],
          ]),
        );
      },
    );
  }

  Widget _kv(String k, String v, {Color? color}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(k, style: T.c2(C.grey600)),
        const SizedBox(height: 2),
        Text(v, style: T.b2(color ?? C.grey800).copyWith(fontSize: k == 'Details' ? 14 : 16, fontWeight: k == 'Details' ? FontWeight.w400 : FontWeight.w600, height: k == 'Details' ? 20 / 14 : 24 / 16)),
      ]);

  Future<void> _openUpdate(BuildContext context, WidgetRef ref, Report r) async {
    const statuses = [('ditinjau', 'Under Review'), ('diproses', 'In Progress'), ('menunggu_suku_cadang', 'Waiting for Parts'), ('selesai', 'Resolved'), ('ditolak', 'Rejected')];
    const levels = [('ringan', 'Low'), ('sedang', 'Medium'), ('berat', 'High')];
    var status = r.status == 'pending' || r.status == 'draft' ? 'ditinjau' : r.status;
    String? level = r.tingkat;
    final note = TextEditingController();
    var busy = false;
    final done = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 48, height: 4, decoration: BoxDecoration(color: C.grey300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('Update Status', style: T.s1()),
              const SizedBox(height: 16),
              Text('Status', style: T.b4()),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [for (final s in statuses) ChoicePill(label: s.$2, selected: status == s.$1, onTap: () => set(() => status = s.$1), height: 36)]),
              const SizedBox(height: 16),
              Text('Priority', style: T.b4()),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [for (final l in levels) ChoicePill(label: l.$2, selected: level == l.$1, onTap: () => set(() => level = l.$1), height: 36)]),
              if (level == 'berat') Padding(padding: const EdgeInsets.only(top: 8), child: Text('High priority closes the room for booking until the report is resolved.', style: T.c1(C.secondary500))),
              const SizedBox(height: 16),
              Text('Technician Note', style: T.b4()),
              const SizedBox(height: 8),
              BoxInput(controller: note, hint: 'Describe the action taken or next step...', height: 96, maxLines: 4),
              const SizedBox(height: 20),
              AppButton('Submit', expand: true, loading: busy, onPressed: busy ? null : () async {
                set(() => busy = true);
                try {
                  await ref.read(reportRepoP).updateStatus(r.id, status, note.text.trim().isEmpty ? null : note.text.trim(), level);
                  if (ctx.mounted) Navigator.pop(ctx, true);
                } catch (e) {
                  set(() => busy = false);
                  if (ctx.mounted) showSnack(ctx, friendlyError(e));
                }
              }),
            ]),
          ),
        );
      }),
    );
    if (done == true) {
      refreshAll(ref);
      ref.invalidate(reportP(r.id));
      ref.invalidate(reportUpdatesP(r.id));
      if (context.mounted) context.go('/sarpras/updated');
    }
  }
}
