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
import '../../data/auth_providers.dart';
import '../../data/booking_providers.dart';
import '../../data/refresh_all.dart';
import 'check_widgets.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key, required this.id});
  final int id;
  @override
  ConsumerState<CheckInScreen> createState() => _CheckInState();
}

class _CheckInState extends ConsumerState<CheckInScreen> with MediaPicking {
  final _notes = TextEditingController();
  bool _busy = false;

  Future<void> _go() async {
    final ok = await showConfirmDialog(context, title: 'Are you sure?', message: 'Before proceeding, make sure that your check-in is aligned with Roomasters’ Terms and Conditions.', confirmLabel: 'Proceed');
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(bookingRepoP).checkIn(widget.id, _notes.text.trim(), files);
      refreshAll(ref);
      ref.invalidate(bookingP(widget.id));
      if (mounted) context.go('/checkin/${widget.id}/success');
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _row(String k, Widget v, {bool first = false}) => Container(
        constraints: const BoxConstraints(minHeight: 40),
        decoration: BoxDecoration(border: first ? null : const Border(top: BorderSide(color: C.grey200))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(k, style: T.b3(C.grey500)), Flexible(child: v)]),
      );

  @override
  Widget build(BuildContext context) {
    final b = ref.watch(bookingP(widget.id)).valueOrNull;
    final me = ref.watch(profileP).valueOrNull;
    return PageShell(
      header: TopAppBar(title: 'Check-In', onBack: () => goBack(context), endIcon: 'home', onEnd: null, plain: false),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      bottom: ActionBar(color: C.grey100, bordered: false, note: 'By checking in, you agree to the facility usage terms and conditions.', children: [AppButton('Check In', onPressed: _busy ? null : _go, expand: true, loading: _busy)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Check-In Process', style: T.h5()),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(color: C.grey50, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.grey300), boxShadow: C.shadowCard),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Booking Details', style: T.s2()),
            const SizedBox(height: 8),
            _row('Guest Name', Text(me?.nama ?? '', style: T.b4(), textAlign: TextAlign.right), first: true),
            _row('Room Booked', Text(b?.namaRuangan ?? '-', style: T.s1())),
            _row('Check-In Date', Text(b == null ? '-' : Fmt.dateShort(b.tanggal), style: T.b4().copyWith(fontWeight: FontWeight.w500))),
            _row('Reservation ID', Text(b?.kode ?? '-', style: T.b4().copyWith(fontWeight: FontWeight.w500))),
          ]),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: C.grey50, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.grey300), boxShadow: C.shadowCard),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(padding: EdgeInsets.only(top: 1), child: AppIcon('alert-circle', color: C.warning500)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Standard Procedure', style: T.s2().copyWith(fontWeight: FontWeight.w500)),
                Text('Please document the initial state of the room before using the room. Any form of failure of compliance will be handled according Roomaster’s user Terms & Conditions.', style: T.b3(C.grey600)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        const Divider(color: C.grey300),
        const SizedBox(height: 16),
        Text('Initial Condition Documentation', style: T.s1()),
        const SizedBox(height: 16),
        ConditionForm(files: files, onCamera: camera, onGallery: gallery, onRemove: (i) => setState(() => files.removeAt(i)), notes: _notes),
      ]),
    );
  }
}
