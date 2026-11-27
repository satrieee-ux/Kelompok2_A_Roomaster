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
import '../../data/refresh_all.dart';
import '../../data/report_providers.dart';
import '../../data/room_providers.dart';

// ---------------------------------------------------------------------
// Form laporan
// ---------------------------------------------------------------------
const _formCategories = [('ac', 'Air Conditioning', 'air-vent'), ('proyektor', 'Projector', 'projector'), ('pencahayaan', 'Lighting', 'lightbulb'), ('furnitur', 'Desk/Seating', 'armchair')];

class ReportFormScreen extends ConsumerStatefulWidget {
  const ReportFormScreen({super.key, this.roomId, this.draftId});
  final int? roomId, draftId;
  @override
  ConsumerState<ReportFormScreen> createState() => _ReportFormState();
}

class _ReportFormState extends ConsumerState<ReportFormScreen> {
  final _desc = TextEditingController();
  final _selected = <String>{};
  final _files = <PickedUpload>[];
  int? _roomId;
  int? _draftId;
  bool _busy = false, _loaded = false;

  @override
  void initState() {
    super.initState();
    _roomId = widget.roomId;
    _draftId = widget.draftId;
    if (_draftId != null) _load();
  }

  Future<void> _load() async {
    final r = await ref.read(reportRepoP).byId(_draftId!);
    setState(() {
      _roomId = r.idRuangan;
      _desc.text = r.deskripsi;
      _selected.addAll(r.kategori);
      _loaded = true;
    });
  }

  Future<bool> _save({required bool draft}) async {
    if (_roomId == null) return false;
    if (!draft && (_selected.isEmpty || _desc.text.trim().isEmpty)) {
      showSnack(context, 'Pilih minimal satu kategori dan isi deskripsi.');
      return false;
    }
    setState(() => _busy = true);
    try {
      final repo = ref.read(reportRepoP);
      final id = await repo.create(roomId: _roomId!, kategori: _selected.toList(), deskripsi: _desc.text.trim(), draft: draft, existingId: _draftId);
      _draftId = id;
      if (_files.isNotEmpty) {
        await repo.addMedia(id, _files);
        _files.clear();
      }
      refreshAll(ref);
      return true;
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e));
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    final anything = _selected.isNotEmpty || _desc.text.trim().isNotEmpty || _files.isNotEmpty;
    if (!anything) {
      goBack(context, '/qreporting');
      return;
    }
    final save = await showConfirmDialog(context, title: 'Save as Draft?', message: 'Draft your reports before cancelling to continue right where you left off.', confirmLabel: 'Yes', cancelLabel: 'No');
    if (!mounted) return;
    if (save) {
      if (await _save(draft: true) && mounted) context.go('/qreporting/history');
    } else {
      context.go('/qreporting');
    }
  }

  Future<void> _send() async {
    if (_selected.isEmpty || _desc.text.trim().isEmpty) {
      showSnack(context, 'Pilih minimal satu kategori dan isi deskripsi.');
      return;
    }
    final ok = await showConfirmDialog(context, title: 'Kirim Laporan?', message: 'Laporan kerusakan akan dikirim ke admin dan tidak dapat diubah setelah dikirim.', confirmLabel: 'Submit', cancelLabel: 'Back');
    if (!ok || !mounted) return;
    if (await _save(draft: false) && mounted) context.go('/qreporting/submitted/$_draftId');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.draftId != null && !_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final room = _roomId == null ? null : ref.watch(roomP(_roomId!)).valueOrNull;
    return PageShell(
      header: TopAppBar(title: 'Reporting', onBack: () => goBack(context, '/qreporting'), endIcon: 'x', onEnd: _cancel),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      bottom: ReportBar(onCancel: _cancel, onSend: _send, sending: _busy),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Damage Report', style: T.h5()),
        const SizedBox(height: 4),
        Text('Please provide details about the issue to help our maintenance team resolve it quickly.', style: T.b1(C.grey600)),
        const SizedBox(height: 20),
        Text('Room Location', style: T.s2()),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: C.grey50, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.grey300)),
          child: Row(children: [
            const AppIcon('map-pin', color: C.grey800),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(room == null ? '...' : '${room.kode} - ${room.nama}', style: T.b4()),
                Text(room?.alamat ?? room?.lokasi ?? '', style: T.c3(C.grey600)),
              ]),
            ),
            GestureDetector(onTap: () => context.go('/qreporting'), child: const AppIcon('pencil', color: C.grey600)),
          ]),
        ),
        const SizedBox(height: 20),
        Text('Categories', style: T.s2()),
        const SizedBox(height: 10),
        Wrap(spacing: 12, runSpacing: 12, children: [
          for (final c in _formCategories)
            ChoicePill(label: c.$2, icon: c.$3, selected: _selected.contains(c.$1), height: 40, onTap: () => setState(() => _selected.contains(c.$1) ? _selected.remove(c.$1) : _selected.add(c.$1))),
        ]),
        const SizedBox(height: 20),
        const Divider(color: C.grey300),
        const SizedBox(height: 20),
        const FieldLabel('Issue Description'),
        const SizedBox(height: 10),
        BoxInput(controller: _desc, hint: 'Briefly describe the issue', height: 106, maxLines: 4),
        const SizedBox(height: 20),
        Text('Evidence', style: T.s2()),
        const SizedBox(height: 4),
        Text('Upload photos or videos of the damage.', style: T.b3(C.grey600)),
        const SizedBox(height: 16),
        MediaUploadBox(
          files: _files,
          onCamera: () async {
            final f = await pickImage(ImageSource.camera);
            if (f != null) setState(() => _files.add(f));
          },
          onGallery: () async {
            final l = await pickGallery();
            if (l.isNotEmpty) setState(() => _files.addAll(l));
          },
          onRemove: (i) => setState(() => _files.removeAt(i)),
        ),
      ]),
    );
  }
}
