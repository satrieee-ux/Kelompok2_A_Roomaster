import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text.dart';
import 'app_button.dart';
import 'app_icon.dart';
import 'misc.dart';
import 'status.dart';

class _FavButton extends StatelessWidget {
  const _FavButton({required this.size, required this.iconSize, required this.favorite, this.onTap});
  final double size, iconSize;
  final bool favorite;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: C.primary50.withOpacity(.4), shape: BoxShape.circle),
          child: Center(child: AppIcon('heart', size: iconSize, color: favorite ? C.danger500 : C.primary500, filled: favorite)),
        ),
      );
}

/// Kartu ruangan vertikal. large = lebar penuh (gambar 208), kecil = 200 lebar (gambar 120).
class RoomCardVertical extends StatelessWidget {
  const RoomCardVertical({
    super.key,
    required this.title,
    required this.department,
    required this.capacity,
    required this.imagePath,
    required this.favorite,
    required this.onOpen,
    required this.onBook,
    this.onFavorite,
    this.large = false,
  });
  final String title, department, capacity;
  final String? imagePath;
  final bool favorite, large;
  final VoidCallback onOpen, onBook;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: large ? double.infinity : 200,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: C.shadowCard),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: onOpen,
          child: RoomImage(imagePath, width: double.infinity, height: large ? 208 : 120),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: large ? T.s1() : T.s2())),
              const SizedBox(width: 8),
              _FavButton(size: large ? 28 : 24, iconSize: large ? 16 : 14, favorite: favorite, onTap: onFavorite),
            ]),
            SizedBox(height: large ? 8 : 4),
            _meta('map-pin', department, 2),
            const SizedBox(height: 0),
            _meta('users', capacity, 1),
            const SizedBox(height: 12),
            AppButton('Book Now', onPressed: onBook, size: BtnSize.tiny, expand: true),
          ]),
        ),
      ]),
    );
  }

  Widget _meta(String icon, String text, int lines) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(top: 1), child: AppIcon(icon, size: 14, color: C.grey800)),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: T.c2(), maxLines: lines, overflow: TextOverflow.ellipsis)),
      ]);
}

/// Kartu ruangan horizontal (daftar kecil).
class RoomCardHorizontal extends StatelessWidget {
  const RoomCardHorizontal({
    super.key,
    required this.title,
    required this.department,
    required this.capacity,
    required this.imagePath,
    required this.favorite,
    required this.onOpen,
    this.onFavorite,
  });
  final String title, department, capacity;
  final String? imagePath;
  final bool favorite;
  final VoidCallback onOpen;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: C.shadowCard),
        child: Row(children: [
          RoomImage(imagePath, width: 100, height: 100, radius: BorderRadius.circular(16)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: T.s1(), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                const AppIcon('map-pin', size: 14, color: C.grey800),
                const SizedBox(width: 6),
                Expanded(child: Text(department, style: T.c2(), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 2),
              Row(children: [
                const AppIcon('users', size: 14, color: C.grey800),
                const SizedBox(width: 6),
                Expanded(child: Text(capacity, style: T.c2(), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            ]),
          ),
          const SizedBox(width: 16),
          _FavButton(size: 32, iconSize: 18, favorite: favorite, onTap: onFavorite),
        ]),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine(this.icon, this.text);
  final String icon, text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(top: 1), child: AppIcon(icon, size: 12, color: C.grey800)),
          const SizedBox(width: 4),
          Expanded(child: Text(text, style: T.c3(), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
      );
}

/// Kartu booking beranda (342x156) dengan tombol utama sesuai status.
class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.title,
    required this.date,
    required this.time,
    required this.department,
    required this.imagePath,
    required this.status,
    this.statusLabel,
    this.primaryLabel,
    this.onPrimary,
    required this.onDetails,
  });
  final String title, date, time, department;
  final String? imagePath;
  final String status;
  final String? statusLabel;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: C.shadowCard),
      child: Column(children: [
        SizedBox(
          height: 100,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            RoomImage(imagePath, width: 72, height: 72, radius: BorderRadius.circular(8)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Flexible(child: Text(title, style: T.s2(), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 10),
                  StatusPill(status, label: statusLabel),
                ]),
                const SizedBox(height: 4),
                _InfoLine('calendar', date),
                _InfoLine('clock', time),
                _InfoLine('map-pin', department),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        Row(children: [
          if (primaryLabel != null) ...[
            Expanded(child: AppButton(primaryLabel!, onPressed: onPrimary, size: BtnSize.tiny, expand: true)),
            const SizedBox(width: 10),
          ],
          Expanded(child: AppButton('Details', onPressed: onDetails, variant: BtnVariant.soft, size: BtnSize.tiny, expand: true)),
        ]),
      ]),
    );
  }
}

/// Kartu riwayat booking: foto 80, 3 baris info, tombol Details penuh.
class BookingHistoryCard extends StatelessWidget {
  const BookingHistoryCard({
    super.key,
    required this.title,
    required this.date,
    required this.time,
    required this.department,
    required this.imagePath,
    required this.status,
    this.statusLabel,
    required this.onDetails,
  });
  final String title, date, time, department;
  final String? imagePath;
  final String status;
  final String? statusLabel;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: C.shadowCard),
      child: Column(children: [
        SizedBox(
          height: 100,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            RoomImage(imagePath, width: 80, height: 80, radius: BorderRadius.circular(12)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  height: 24,
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Flexible(child: Text(title, style: T.s2(), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    StatusPill(status, label: statusLabel),
                  ]),
                ),
                const SizedBox(height: 4),
                _InfoLine('calendar', date),
                _InfoLine('clock', time),
                _InfoLine('map-pin', department),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        AppButton('Details', onPressed: onDetails, variant: BtnVariant.soft, size: BtnSize.tiny, expand: true),
      ]),
    );
  }
}

class IssueChip {
  const IssueChip(this.icon, this.label);
  final String icon, label;
}

/// Kartu riwayat laporan.
class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.title,
    required this.date,
    required this.department,
    required this.status,
    this.statusLabel,
    required this.issues,
    required this.onDetails,
    this.onContinue,
  });
  final String title, date, department;
  final String status;
  final String? statusLabel;
  final List<IssueChip> issues;
  final VoidCallback onDetails;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(color: C.grey50, borderRadius: BorderRadius.circular(12), boxShadow: C.shadowCard),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 28,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(child: Text(title, style: T.s1(), maxLines: 1, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            StatusPill(status, label: statusLabel),
          ]),
        ),
        const SizedBox(height: 4),
        _InfoLine('calendar', date),
        _InfoLine('map-pin', department),
        const SizedBox(height: 8),
        Wrap(spacing: 16, runSpacing: 8, children: [
          for (final i in issues)
            Row(mainAxisSize: MainAxisSize.min, children: [
              AppIcon(i.icon, color: C.grey600),
              const SizedBox(width: 8),
              Text(i.label, style: T.b3()),
            ]),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          if (onContinue != null) ...[
            Expanded(child: AppButton('Continue', onPressed: onContinue, size: BtnSize.tiny, expand: true)),
            const SizedBox(width: 16),
          ],
          Expanded(child: AppButton('Details', onPressed: onDetails, variant: BtnVariant.soft, size: BtnSize.tiny, expand: true)),
        ]),
      ]),
    );
  }
}

/// Kartu ulasan.
class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.name, required this.date, required this.comment, required this.rating, this.avatarPath, this.width});
  final String name, date, comment;
  final int rating;
  final String? avatarPath;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: C.shadowCard),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          UserAvatar(name: name, path: avatarPath, online: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: T.b4(), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(date, style: T.c3(C.grey500)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              for (var i = 1; i <= 5; i++)
                Padding(
                  padding: const EdgeInsets.only(left: 1),
                  child: AppIcon('star', size: 10, color: i <= rating ? C.secondary300 : C.grey300, filled: i <= rating),
                ),
            ]),
          ),
        ]),
        const SizedBox(height: 8),
        Text(comment, style: T.c3()),
      ]),
    );
  }
}

class NotifAction {
  const NotifAction(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;
}

/// Kartu notifikasi. type: action|approved|rejected|timelimit|unfinished|update|system
class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.type, required this.title, required this.time, required this.message, this.actions = const [], this.unread = false, this.icon, this.iconBg, this.iconFg, this.boldPart});
  final String type, title, time, message;
  final List<NotifAction> actions;
  final bool unread;

  /// Override ikon/warna (dipakai tampilan TU & Sarpras).
  final String? icon;
  final Color? iconBg, iconFg;

  /// Bagian judul yang dicetak tebal (mis. nama ruangan).
  final String? boldPart;

  Widget _title() {
    if (boldPart == null || !title.contains(boldPart!)) {
      return Text(title, style: T.s2(), maxLines: 2, overflow: TextOverflow.ellipsis);
    }
    final i = title.indexOf(boldPart!);
    return Text.rich(
      TextSpan(style: T.b1(), children: [
        TextSpan(text: title.substring(0, i)),
        TextSpan(text: boldPart, style: T.s2()),
        TextSpan(text: title.substring(i + boldPart!.length)),
      ]),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    late String icon;
    late Color bg, fg;
    switch (type) {
      case 'action':
        icon = 'alert-circle';
        bg = C.secondary100;
        fg = C.secondary500;
        break;
      case 'approved':
        icon = 'check-circle';
        bg = C.success100;
        fg = C.success500;
        break;
      case 'rejected':
        icon = 'x';
        bg = C.danger100;
        fg = C.danger500;
        break;
      case 'timelimit':
        icon = 'clock';
        bg = C.warning100;
        fg = C.warning500;
        break;
      case 'unfinished':
        icon = 'file';
        bg = C.primary100;
        fg = C.primary500;
        break;
      case 'update':
        icon = 'info';
        bg = C.primary100;
        fg = C.primary500;
        break;
      default:
        icon = 'bell';
        bg = C.grey200;
        fg = C.grey500;
    }
    icon = this.icon ?? icon;
    bg = iconBg ?? bg;
    fg = iconFg ?? fg;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(color: C.grey50, borderRadius: BorderRadius.circular(12), boxShadow: C.shadowCard),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Center(child: AppIcon(icon, color: fg)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Flexible(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Flexible(child: _title()),
                  if (unread) ...[
                    const SizedBox(width: 6),
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: C.secondary500, shape: BoxShape.circle)),
                  ],
                ]),
              ),
              const SizedBox(width: 8),
              Text(time, style: T.c1(C.grey800.withOpacity(.8))),
            ]),
            const SizedBox(height: 2),
            Text(message, style: T.c1(C.grey800.withOpacity(.8))),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      actions[i].label,
                      onPressed: actions[i].onTap,
                      variant: i == 0 ? BtnVariant.primary : BtnVariant.soft,
                      size: BtnSize.tiny,
                      expand: true,
                    ),
                  ),
                ],
              ]),
            ],
          ]),
        ),
      ]),
    );
  }
}

/// Item daftar percakapan.
class ConversationCard extends StatelessWidget {
  const ConversationCard({super.key, required this.name, required this.preview, required this.time, required this.unread, this.avatarPath, required this.onTap});
  final String name, preview, time;
  final int unread;
  final String? avatarPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: C.grey100, borderRadius: BorderRadius.circular(12), boxShadow: C.shadowCard),
        child: Row(children: [
          UserAvatar(name: name, path: avatarPath, size: 48, online: true, ringColor: C.grey100),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: T.s2(), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(preview, style: T.c1(C.grey800.withOpacity(.8)), maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(time, style: T.c3(C.grey500)),
            const SizedBox(height: 12),
            if (unread > 0)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(color: C.primary900, shape: BoxShape.circle),
                child: Center(child: Text('$unread', style: T.c2s(Colors.white))),
              )
            else
              const SizedBox(height: 24),
          ]),
        ]),
      ),
    );
  }
}

/// Gelembung chat. out = pesan milik saya (gelap, kanan).
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.out, this.text, required this.time, this.image, required this.name, this.avatarPath});
  final bool out;
  final String? text;
  final Widget? image;
  final String time;
  final String name;
  final String? avatarPath;

  @override
  Widget build(BuildContext context) {
    final bubble = Column(
      crossAxisAlignment: out ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (image != null)
          Container(
            width: 240,
            height: 160,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: C.grey300, width: 4)),
            clipBehavior: Clip.antiAlias,
            child: image,
          ),
        if (text != null && text!.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxWidth: 220),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: out ? C.primary900 : C.grey200, borderRadius: BorderRadius.circular(16)),
            child: Text(text!, style: T.b1(out ? Colors.white : C.grey800)),
          ),
        const SizedBox(height: 4),
        Text(time, style: T.c2(C.grey800.withOpacity(.7))),
      ],
    );
    final avatar = UserAvatar(name: name, path: avatarPath, size: 32, online: true, ringColor: C.grey50);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: out ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: out
            ? [Flexible(child: bubble), const SizedBox(width: 12), avatar]
            : [avatar, const SizedBox(width: 12), Flexible(child: bubble)],
      ),
    );
  }
}

/// Kartu isian berjudul (Facility Information, Schedule, dst.).
class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.title, required this.children, this.titleStyle, this.trailing, this.gap = 20, this.border = C.grey200, this.padding = const EdgeInsets.all(20)});
  final String title;
  final List<Widget> children;
  final TextStyle? titleStyle;
  final Widget? trailing;
  final double gap;
  final Color border;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(color: C.grey50, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text(title, style: titleStyle ?? T.s2())),
          if (trailing != null) trailing!,
        ]),
        const SizedBox(height: 16),
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(height: gap),
          children[i],
        ],
      ]),
    );
  }
}

/// Pasangan kunci-nilai vertikal (Room Name / SI-4202).
class KeyValue extends StatelessWidget {
  const KeyValue(this.k, this.v, {super.key, this.valueStyle, this.icon, this.child});
  final String k;
  final String? v;
  final TextStyle? valueStyle;
  final String? icon;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(k, style: T.b4(C.grey500)),
      const SizedBox(height: 4),
      if (child != null)
        child!
      else if (icon != null)
        Row(children: [AppIcon(icon!, size: 20), const SizedBox(width: 8), Text(v ?? '', style: valueStyle ?? T.b3())])
      else
        Text(v ?? '', style: valueStyle ?? T.b3()),
    ]);
  }
}
