import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text.dart';
import 'app_icon.dart';

/// Kunci tampilan status: completed|draft|approved|action_required|pending|rejected|upcoming
class _Look {
  const _Look(this.label, this.bg, this.fg, this.muted, this.icon);
  final String label;
  final Color bg, fg, muted;
  final String icon;
}

const _looks = <String, _Look>{
  'completed': _Look('Completed', C.primary500, Colors.white, Color(0xCCFFFFFF), 'check-circle'),
  'draft': _Look('Draft', C.primary50, C.primary500, Color(0xB33B7BA0), 'file'),
  'approved': _Look('Approved', C.success50, C.success500, C.success400, 'check-circle'),
  'action_required': _Look('Action Required', C.secondary50, C.secondary500, C.secondary300, 'alert-circle'),
  'pending': _Look('Pending', C.warning50, C.warning500, C.warning300, 'clock'),
  'rejected': _Look('Rejected', C.danger50, C.danger500, C.danger300, 'x'),
  'upcoming': _Look('Upcoming', C.secondary500, Colors.white, Color(0xCCFFFFFF), 'door-open'),
};

_Look _look(String s) => _looks[s] ?? _looks['pending']!;

/// Pill status kecil.
class StatusPill extends StatelessWidget {
  const StatusPill(this.status, {super.key, this.label});
  final String status;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final l = _look(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: l.bg, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        AppIcon(l.icon, size: 12, color: l.fg),
        const SizedBox(width: 4),
        Text(label ?? l.label, style: T.c3(l.fg), maxLines: 1),
      ]),
    );
  }
}

/// Banner status lebar penuh ("Status: Approved   Updated 2h ago").
class StatusBanner extends StatelessWidget {
  const StatusBanner(this.status, {super.key, this.label, this.updated});
  final String status;
  final String? label;
  final String? updated;

  @override
  Widget build(BuildContext context) {
    final l = _look(status);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: l.bg, borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            AppIcon(l.icon, size: 20, color: l.fg),
            const SizedBox(width: 8),
            Flexible(child: Text('Status: ${label ?? l.label}', style: T.b4(l.fg), overflow: TextOverflow.ellipsis)),
          ]),
        ),
        if (updated != null) Text('Updated $updated', style: T.c1(l.muted)),
      ]),
    );
  }
}
