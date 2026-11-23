import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text.dart';
import 'app_button.dart';
import 'app_icon.dart';

/// Dialog konfirmasi generik (Cancel Booking, Pre-Book, Check-In/Out, Save Draft, Send Report).
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  String icon = 'alert-circle',
  Color iconColor = C.secondary500,
  Color iconBg = C.secondary100,
  bool danger = false,
}) async {
  final res = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withOpacity(.5),
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Center(child: AppIcon(icon, size: 32, color: iconColor)),
          ),
          const SizedBox(height: 16),
          Text(title, style: T.h5(), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(message, style: T.b3(C.grey800), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: AppButton(cancelLabel, onPressed: () => Navigator.pop(ctx, false), variant: BtnVariant.soft, size: BtnSize.medium, expand: true)),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                confirmLabel,
                onPressed: () => Navigator.pop(ctx, true),
                size: BtnSize.medium,
                expand: true,
                bg: danger ? C.danger500 : null,
              ),
            ),
          ]),
        ]),
      ),
    ),
  );
  return res ?? false;
}

Future<R?> _sheet<R>(BuildContext context, Widget Function(BuildContext) builder) => showModalBottomSheet<R>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(.5),
      builder: builder,
    );

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.title, required this.child, this.footer});
  final String title;
  final Widget child;
  final Widget? footer;
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .9),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 12),
        Container(width: 48, height: 4, decoration: BoxDecoration(color: C.grey300, borderRadius: BorderRadius.circular(2))),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
          child: Row(children: [
            Expanded(child: Text(title, style: T.s1())),
            GestureDetector(onTap: () => Navigator.pop(context), child: const Padding(padding: EdgeInsets.all(8), child: AppIcon('x', size: 20))),
          ]),
        ),
        Flexible(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(24, 8, 24, 16), child: child)),
        if (footer != null) Padding(padding: EdgeInsets.fromLTRB(24, 8, 24, 16 + bottom), child: footer),
      ]),
    );
  }
}

class FilterResult {
  const FilterResult({this.category, this.minCapacity, this.facilities = const {}});
  final String? category; // nilai enum kategori_ruangan
  final int? minCapacity;
  final Set<String> facilities; // nama fasilitas
}

Widget _chip(String label, bool on, VoidCallback tap) => GestureDetector(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: on ? C.primary900 : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: on ? C.primary900 : C.grey300),
        ),
        child: Text(label, style: T.b4(on ? Colors.white : C.grey800)),
      ),
    );

/// Sheet filter pencarian.
Future<FilterResult?> showFilterSheet(
  BuildContext context, {
  required FilterResult initial,
  required Map<String, String> categories, // enum -> label
  required List<String> facilityNames,
}) {
  return _sheet<FilterResult>(context, (ctx) {
    String? cat = initial.category;
    int? cap = initial.minCapacity;
    final fac = {...initial.facilities};
    return StatefulBuilder(builder: (ctx, set) {
      return _SheetFrame(
        title: 'Filter',
        footer: Row(children: [
          Expanded(
            child: AppButton('Reset', variant: BtnVariant.soft, expand: true, onPressed: () => Navigator.pop(ctx, const FilterResult())),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton('Apply', expand: true, onPressed: () => Navigator.pop(ctx, FilterResult(category: cat, minCapacity: cap, facilities: fac))),
          ),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Room Category', style: T.s2()),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final e in categories.entries) _chip(e.value, cat == e.key, () => set(() => cat = cat == e.key ? null : e.key)),
          ]),
          const SizedBox(height: 20),
          Text('Minimum Capacity', style: T.s2()),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final n in [10, 20, 30, 50, 100]) _chip('$n+', cap == n, () => set(() => cap = cap == n ? null : n)),
          ]),
          const SizedBox(height: 20),
          Text('Facilities', style: T.s2()),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final f in facilityNames) _chip(f, fac.contains(f), () => set(() => fac.contains(f) ? fac.remove(f) : fac.add(f))),
          ]),
        ]),
      );
    });
  });
}

/// Sheet pemilih tanggal (kalender bulanan sederhana).
Future<DateTime?> showDateSheet(BuildContext context, {DateTime? initial, DateTime? first, DateTime? last}) {
  final now = DateTime.now();
  final firstD = first ?? DateTime(now.year, now.month, now.day);
  final lastD = last ?? firstD.add(const Duration(days: 365));
  return _sheet<DateTime>(context, (ctx) {
    DateTime sel = initial ?? firstD;
    return StatefulBuilder(builder: (ctx, set) {
      return _SheetFrame(
        title: 'Select Date',
        footer: AppButton('Apply', expand: true, onPressed: () => Navigator.pop(ctx, sel)),
        child: Theme(
          data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: C.primary900)),
          child: CalendarDatePicker(
            initialDate: sel,
            firstDate: firstD,
            lastDate: lastD,
            onDateChanged: (d) => set(() => sel = d),
          ),
        ),
      );
    });
  });
}

class TimeRangeResult {
  const TimeRangeResult(this.startHour, this.endHour);
  final int startHour, endHour; // endHour eksklusif
}

/// Sheet pemilih jam: jam 8-19, [booked] = jam terpakai. Memilih rentang kontinu.
Future<TimeRangeResult?> showTimeSheet(
  BuildContext context, {
  required Set<int> booked,
  TimeRangeResult? initial,
  int firstHour = 8,
  int lastHour = 19,
}) {
  return _sheet<TimeRangeResult>(context, (ctx) {
    int? a = initial?.startHour;
    int? b = initial == null ? null : initial.endHour - 1;
    return StatefulBuilder(builder: (ctx, set) {
      bool inRange(int h) => a != null && h >= a! && h <= (b ?? a!);
      void tap(int h) {
        if (booked.contains(h)) return;
        if (a == null || b != null) {
          a = h;
          b = null;
        } else if (h < a!) {
          a = h;
        } else {
          var ok = true;
          for (var i = a!; i <= h; i++) {
            if (booked.contains(i)) ok = false;
          }
          if (ok) {
            b = h;
          } else {
            a = h;
          }
        }
        set(() {});
      }

      String hh(int h) => '${h.toString().padLeft(2, '0')}:00';
      final ready = a != null;
      final end = (b ?? a ?? 0) + 1;
      return _SheetFrame(
        title: 'Select Time',
        footer: AppButton(
          ready ? 'Apply  ${hh(a!)} - ${hh(end)}' : 'Apply',
          expand: true,
          variant: ready ? BtnVariant.primary : BtnVariant.disabled,
          onPressed: ready ? () => Navigator.pop(ctx, TimeRangeResult(a!, end)) : null,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 10, runSpacing: 10, children: [
            for (var h = firstHour; h <= lastHour; h++)
              GestureDetector(
                onTap: () => tap(h),
                child: Container(
                  width: 96,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: booked.contains(h) ? C.grey200 : (inRange(h) ? C.primary900 : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: inRange(h) ? C.primary900 : C.grey300),
                  ),
                  child: Text(
                    hh(h),
                    style: T.b4(booked.contains(h) ? C.grey500 : (inRange(h) ? Colors.white : C.grey800)).copyWith(
                      decoration: booked.contains(h) ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            _legend(C.primary900, 'Selected'),
            const SizedBox(width: 16),
            _legend(C.grey200, 'Booked'),
            const SizedBox(width: 16),
            _legend(Colors.white, 'Available', border: true),
          ]),
        ]),
      );
    });
  });
}

Widget _legend(Color c, String t, {bool border = false}) => Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 14, height: 14, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4), border: border ? Border.all(color: C.grey300) : null)),
      const SizedBox(width: 6),
      Text(t, style: T.c2()),
    ]);

class ReviewResult {
  const ReviewResult(this.rating, this.comment);
  final int rating;
  final String comment;
}

/// Sheet ulasan setelah check-out.
Future<ReviewResult?> showReviewSheet(BuildContext context) {
  return _sheet<ReviewResult>(context, (ctx) {
    var rating = 0;
    final ctrl = TextEditingController();
    return StatefulBuilder(builder: (ctx, set) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _SheetFrame(
          title: 'Rate Your Experience',
          footer: AppButton(
            'Submit Review',
            expand: true,
            variant: rating > 0 ? BtnVariant.primary : BtnVariant.disabled,
            onPressed: rating > 0 ? () => Navigator.pop(ctx, ReviewResult(rating, ctrl.text.trim())) : null,
          ),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (var i = 1; i <= 5; i++)
                GestureDetector(
                  onTap: () => set(() => rating = i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: AppIcon('star', size: 40, color: i <= rating ? C.secondary300 : C.grey300, filled: i <= rating),
                  ),
                ),
            ]),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              maxLines: 4,
              style: T.b3(),
              decoration: InputDecoration(
                hintText: 'Tell us about the room (optional)',
                hintStyle: T.b3(C.grey500),
                filled: true,
                fillColor: C.grey50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.grey300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.grey300)),
              ),
            ),
          ]),
        ),
      );
    });
  });
}

/// Dialog "Are you sure?" dengan kolom alasan (TU: Reject / Request Revision). Mengembalikan teks, atau null bila dibatalkan.
Future<String?> showReasonDialog(
  BuildContext context, {
  required String message,
  required String hint,
  bool required = true,
  String title = 'Are you sure?',
}) {
  final ctrl = TextEditingController();
  return showDialog<String>(
    context: context,
    barrierColor: Colors.black.withOpacity(.5),
    builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
      return Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom * 0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(title, style: T.s2(), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, style: T.b3(C.grey600), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              maxLines: 3,
              minLines: 2,
              onChanged: (_) => set(() {}),
              style: T.b3(),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: T.b3(C.grey500),
                filled: true,
                fillColor: C.grey50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.grey300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.grey300)),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: AppButton('Proceed', size: BtnSize.medium, expand: true, variant: (!required || ctrl.text.trim().isNotEmpty) ? BtnVariant.primary : BtnVariant.disabled, onPressed: (!required || ctrl.text.trim().isNotEmpty) ? () => Navigator.pop(ctx, ctrl.text.trim()) : null),
              ),
              const SizedBox(width: 12),
              Expanded(child: AppButton('Cancel', size: BtnSize.medium, expand: true, variant: BtnVariant.outline, onPressed: () => Navigator.pop(ctx))),
            ]),
          ]),
        ),
      );
    }),
  );
}
