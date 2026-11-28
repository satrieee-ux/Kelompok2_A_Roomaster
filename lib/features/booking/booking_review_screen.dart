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
import 'booking_widgets.dart';

// ---------------------------------------------------------------------
// Langkah 3: Ringkasan -> Finish Booking
// ---------------------------------------------------------------------
class BookingReviewScreen extends ConsumerStatefulWidget {
  const BookingReviewScreen({super.key, required this.id});
  final int id;
  @override
  ConsumerState<BookingReviewScreen> createState() => _ReviewState();
}

class _ReviewState extends ConsumerState<BookingReviewScreen> {
  bool _busy = false;

  Future<void> _finish() async {
    final ok = await showConfirmDialog(context, title: 'Are you sure?', message: 'Before proceeding, make sure that your booking is aligned with Roomasters’ Terms and Conditions.', confirmLabel: 'Proceed', cancelLabel: 'Cancel');
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(bookingRepoP).submit(widget.id);
      refreshAll(ref);
      ref.invalidate(bookingP(widget.id));
      if (mounted) context.go('/booking/${widget.id}/berhasil');
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel(Booking b) async {
    final ok = await showConfirmDialog(context, title: 'Cancel Booking?', message: 'This booking will be cancelled.', confirmLabel: 'Yes', cancelLabel: 'No');
    if (!ok || !mounted) return;
    try {
      await ref.read(bookingRepoP).cancel(widget.id);
      refreshAll(ref);
      if (mounted) context.go('/rooms/${b.idRuangan}');
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(bookingP(widget.id));
    return async.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: ErrorBox(e, onRetry: () => ref.invalidate(bookingP(widget.id))))),
      data: (b) {
        final room = ref.watch(roomP(b.idRuangan)).valueOrNull;
        final docs = ref.watch(bookingDocsP(b.id)).valueOrNull ?? const <BookingDoc>[];
        return PageShell(
          header: TopAppBar(title: 'Booking', onBack: () => goBack(context), endIcon: 'x', onEnd: () => context.go('/rooms/${b.idRuangan}')),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const BookingStepper(step: 3),
            const SizedBox(height: 16),
            Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Room Details', style: T.h5()),
              Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('Booking #${b.kode}', style: T.c3(C.grey500))),
            ]),
            const SizedBox(height: 16),
            BookingDetailCards(booking: b, room: room, docs: docs, onEditDocs: () => context.push('/booking/${b.id}/dokumen'), summaryStyle: false),
            const SizedBox(height: 16),
            const Divider(color: C.grey200),
            const SizedBox(height: 16),
            AppButton('Finish Booking', onPressed: _busy ? null : _finish, expand: true, loading: _busy),
            const SizedBox(height: 8),
            AppButton('Cancel', onPressed: () => _cancel(b), variant: BtnVariant.secondary, expand: true),
            const SizedBox(height: 12),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Text('By submitting, you agree to the facility usage terms and conditions.', textAlign: TextAlign.center, style: T.c2(C.grey500))),
          ]),
        );
      },
    );
  }
}
