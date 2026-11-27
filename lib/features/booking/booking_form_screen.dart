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
import '../../data/refresh_all.dart';
import '../../data/room_providers.dart';

// ---------------------------------------------------------------------
// Langkah 1: Details (form) -> draft dibuat saat "Continue"
// ---------------------------------------------------------------------
class BookingFormScreen extends ConsumerStatefulWidget {
  const BookingFormScreen({super.key, required this.roomId, this.bookingId});
  final int roomId;
  final int? bookingId; // lanjutkan draft / revisi
  @override
  ConsumerState<BookingFormScreen> createState() => _BookingFormState();
}

class _BookingFormState extends ConsumerState<BookingFormScreen> {
  final _activity = TextEditingController(), _purpose = TextEditingController();
  String? _dept;
  DateTime? _date;
  TimeRangeResult? _time;
  bool _busy = false, _loaded = false;
  int? _bookingId;

  @override
  void initState() {
    super.initState();
    _bookingId = widget.bookingId;
    if (_bookingId != null) _load();
  }

  Future<void> _load() async {
    final b = await ref.read(bookingRepoP).byId(_bookingId!);
    setState(() {
      _activity.text = b.namaKegiatan;
      _purpose.text = b.tujuan;
      _dept = b.departemenPenyelenggara;
      _date = b.tanggal;
      _time = TimeRangeResult(int.parse(b.mulai.substring(0, 2)), int.parse(b.selesai.substring(0, 2)));
      _loaded = true;
    });
  }

  bool get _formOk => _activity.text.trim().isNotEmpty && _purpose.text.trim().isNotEmpty && _dept != null;

  Future<void> _pickDate() async {
    final d = await showDateSheet(context, initial: _date);
    if (d != null) setState(() {
      _date = d;
      _time = null;
    });
  }

  Future<void> _pickTime() async {
    if (_date == null) {
      showSnack(context, 'Pilih tanggal dulu.');
      return;
    }
    try {
      final used = await ref.read(roomRepoP).usedHours(widget.roomId, _date!);
      // jangan hitung jam milik draft ini sendiri
      if (_time != null && _bookingId != null) {
        for (var h = _time!.startHour; h < _time!.endHour; h++) {
          used.remove(h);
        }
      }
      if (!mounted) return;
      final t = await showTimeSheet(context, booked: used, initial: _time);
      if (t != null) setState(() => _time = t);
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e));
    }
  }

  Future<void> _cancel() async {
    final ok = await showConfirmDialog(context, title: 'Cancel Booking?', message: 'Your progress on this form will be discarded.', confirmLabel: 'Yes', cancelLabel: 'No');
    if (!ok || !mounted) return;
    if (_bookingId != null) {
      try {
        await ref.read(bookingRepoP).cancel(_bookingId!);
        refreshAll(ref);
      } catch (_) {}
    }
    if (mounted) context.go('/rooms/${widget.roomId}');
  }

  Future<void> _continue() async {
    if (!_formOk || _date == null || _time == null) {
      showSnack(context, 'Lengkapi semua kolom, tanggal, dan jam.');
      return;
    }
    setState(() => _busy = true);
    try {
      String hh(int h) => '${h.toString().padLeft(2, '0')}:00:00';
      final id = await ref.read(bookingRepoP).saveDraft(
            id: _bookingId,
            roomId: widget.roomId,
            kegiatan: _activity.text.trim(),
            tujuan: _purpose.text.trim(),
            departemen: _dept!,
            tanggal: _date!,
            mulai: hh(_time!.startHour),
            selesai: hh(_time!.endHour),
          );
      _bookingId = id;
      refreshAll(ref);
      if (mounted) context.push('/booking/$id/dokumen');
    } catch (e) {
      final m = friendlyError(e);
      if (mounted) showSnack(context, m.contains('bentrok') || m.contains('exclusion') ? 'Jam yang dipilih sudah terpakai. Pilih jam lain.' : m);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rooms = ref.watch(roomsP).valueOrNull ?? const <Room>[];
    final depts = <String>{...rooms.map((r) => r.departemen).whereType<String>(), 'Departemen Sistem Informasi', 'Departemen Teknik Informatika'}.toList()..sort();
    final hasTime = _time != null;
    final timeLabel = hasTime ? '${_time!.startHour.toString().padLeft(2, '0')}:00 - ${_time!.endHour.toString().padLeft(2, '0')}:00' : null;
    if (widget.bookingId != null && !_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return PageShell(
      header: TopAppBar(title: 'Booking', onBack: () => goBack(context, '/rooms/${widget.roomId}'), endIcon: 'x', onEnd: _cancel),
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
      bottom: hasTime
          ? DocBar(onContinue: _formOk ? _continue : null, loading: _busy)
          : DetailBar(onCancel: _cancel, onCheck: (_date != null && _formOk) ? _pickTime : null),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Details', style: T.h5()),
        const SizedBox(height: 16),
        const BookingStepper(step: 1),
        const SizedBox(height: 32),
        const FieldLabel('Activity Name'),
        const SizedBox(height: 10),
        BoxInput(controller: _activity, hint: 'e.g. Weekly Meeting', onChanged: (_) => setState(() {})),
        const SizedBox(height: 10),
        const FieldLabel('Purpose'),
        const SizedBox(height: 10),
        BoxInput(controller: _purpose, hint: 'Briefly describe the purpose of the booking', height: 106, maxLines: 4, onChanged: (_) => setState(() {})),
        const SizedBox(height: 10),
        const FieldLabel('Department'),
        const SizedBox(height: 10),
        AppDropdown(value: _dept, items: depts, onChanged: (v) => setState(() => _dept = v), hint: 'Select department'),
        const SizedBox(height: 10),
        const FieldLabel('Date'),
        const SizedBox(height: 10),
        PickerField(icon: 'calendar', text: _date == null ? null : Fmt.dateField(_date!), placeholder: 'DD/MM/YY', onTap: _pickDate),
        if (hasTime) ...[
          const SizedBox(height: 10),
          const FieldLabel('Time'),
          const SizedBox(height: 10),
          PickerField(icon: 'clock', text: timeLabel, placeholder: 'Select time', onTap: _pickTime),
        ] else ...[
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: C.grey50, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.grey300), boxShadow: C.shadowCard),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(padding: EdgeInsets.only(top: 2), child: AppIcon('info', size: 20, color: C.warning500)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Availability Status', style: T.s2().copyWith(fontWeight: FontWeight.w500)),
                  Text('Please fill in the date above to', style: T.b3(C.grey600)),
                  GestureDetector(
                    onTap: _date == null ? _pickDate : (_formOk ? _pickTime : () => showSnack(context, 'Isi nama kegiatan, tujuan, dan departemen dulu.')),
                    child: Text('check room availability.', style: T.b4(C.primary500).copyWith(decoration: TextDecoration.underline)),
                  ),
                ]),
              ),
            ]),
          ),
        ],
      ]),
    );
  }
}
