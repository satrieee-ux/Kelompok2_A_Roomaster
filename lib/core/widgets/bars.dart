import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text.dart';
import 'app_button.dart';
import 'app_icon.dart';

/// Navbar bawah (sticky). active: home|rooms|qreport|scheduled|profile
class RoomasterNavBar extends StatelessWidget {
  const RoomasterNavBar({super.key, required this.active, required this.onSelect});
  final String active;
  final void Function(String key) onSelect;

  static const _items = <(String, String, String)>[
    ('home', 'Home', 'home'),
    ('rooms', 'Rooms', 'door-open'),
    ('qreport', 'QReport', 'scan-qr'),
    ('scheduled', 'Scheduled', 'calendar-check'),
    ('profile', 'Profile', 'user'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      height: 69 + (bottom < 8 ? 8 : bottom),
      padding: EdgeInsets.only(bottom: bottom < 8 ? 8 : bottom),
      decoration: const BoxDecoration(
        color: C.grey50,
        border: Border(top: BorderSide(color: C.grey200)),
      ),
      child: Row(children: [
        for (final it in _items)
          Expanded(
            child: InkWell(
              onTap: () => onSelect(it.$1),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                AppIcon(it.$3, color: active == it.$1 ? C.grey900 : C.grey400, stroke: active == it.$1 ? 2.25 : 1.75),
                const SizedBox(height: 4),
                Text(it.$2, style: T.c3(active == it.$1 ? C.grey900 : C.grey400)),
              ]),
            ),
          ),
      ]),
    );
  }
}

/// Bar gelap bawah (BookBar, DocBar, DetailBar, ChatBar, ReportBar). Tinggi 100, sudut atas 32.
class DarkBottomBar extends StatelessWidget {
  const DarkBottomBar({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final extra = MediaQuery.paddingOf(context).bottom - 34;
    return Container(
      height: 100 + (extra > 0 ? extra : 0),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      decoration: const BoxDecoration(
        color: C.primary900,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Align(alignment: Alignment.topCenter, child: child),
    );
  }
}

/// BookBar: Book Now + tombol favorit bulat.
class BookBar extends StatelessWidget {
  const BookBar({super.key, required this.onBook, required this.favorite, required this.onFavorite, this.enabled = true});
  final VoidCallback onBook;
  final bool favorite;
  final VoidCallback onFavorite;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DarkBottomBar(
      child: Row(children: [
        Expanded(
          child: AppButton('Book Now', onPressed: enabled ? onBook : null, variant: BtnVariant.secondary, size: BtnSize.medium, expand: true),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: onFavorite,
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: C.grey50, shape: BoxShape.circle),
            child: Center(child: AppIcon('heart', size: 20, color: favorite ? C.danger500 : C.primary500, filled: favorite)),
          ),
        ),
      ]),
    );
  }
}

/// DocBar: satu tombol Continue (abu-abu bila tidak aktif).
class DocBar extends StatelessWidget {
  const DocBar({super.key, required this.onContinue, this.label = 'Continue', this.loading = false});
  final VoidCallback? onContinue;
  final String label;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return DarkBottomBar(
      child: AppButton(
        label,
        onPressed: onContinue,
        variant: onContinue == null ? BtnVariant.disabled : BtnVariant.secondary,
        size: BtnSize.medium,
        expand: true,
        loading: loading,
      ),
    );
  }
}

/// DetailBar: keranjang + Cancel + Check Availability.
class DetailBar extends StatelessWidget {
  const DetailBar({super.key, required this.onCancel, required this.onCheck});
  final VoidCallback onCancel;
  final VoidCallback? onCheck;

  @override
  Widget build(BuildContext context) {
    return DarkBottomBar(
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(color: C.primary500, shape: BoxShape.circle),
          child: const Center(child: AppIcon('shopping-cart', size: 20, color: Colors.white)),
        ),
        const SizedBox(width: 16),
        SizedBox(width: 101, child: AppButton('Cancel', onPressed: onCancel, variant: BtnVariant.soft, size: BtnSize.medium, expand: true)),
        const SizedBox(width: 16),
        Expanded(
          child: AppButton(
            'Check Availability',
            onPressed: onCheck,
            variant: onCheck == null ? BtnVariant.disabled : BtnVariant.secondary,
            size: BtnSize.medium,
            expand: true,
          ),
        ),
      ]),
    );
  }
}

/// ReportBar: Cancel + Send.
class ReportBar extends StatelessWidget {
  const ReportBar({super.key, required this.onCancel, required this.onSend, this.sending = false});
  final VoidCallback onCancel, onSend;
  final bool sending;

  @override
  Widget build(BuildContext context) {
    return DarkBottomBar(
      child: Row(children: [
        Expanded(child: AppButton('Cancel', onPressed: onCancel, variant: BtnVariant.soft, size: BtnSize.medium, expand: true)),
        const SizedBox(width: 16),
        Expanded(child: AppButton('Send', onPressed: onSend, variant: BtnVariant.secondary, size: BtnSize.medium, expand: true, loading: sending)),
      ]),
    );
  }
}

/// ChatBar: kolom pesan + lampiran + kirim.
class ChatBar extends StatelessWidget {
  const ChatBar({super.key, required this.controller, required this.onSend, required this.onAttach, this.sending = false});
  final TextEditingController controller;
  final VoidCallback onSend, onAttach;
  final bool sending;

  @override
  Widget build(BuildContext context) {
    return DarkBottomBar(
      child: Row(children: [
        Expanded(
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: C.grey200, borderRadius: BorderRadius.circular(99)),
            child: Row(children: [
              GestureDetector(onTap: onAttach, child: const AppIcon('paperclip', color: C.primary500)),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: T.b3(C.grey800),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: 'Type a message...',
                    hintStyle: T.b3(C.grey400),
                  ),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: sending ? null : onSend,
          child: Container(
            width: 56,
            height: 40,
            decoration: BoxDecoration(color: C.secondary500, borderRadius: BorderRadius.circular(99)),
            child: const Center(child: AppIcon('send', color: Colors.white)),
          ),
        ),
      ]),
    );
  }
}

/// Bar aksi terang (Done / Review Room / Check In ...). Sticky bawah.
class ActionBar extends StatelessWidget {
  const ActionBar({super.key, required this.children, this.note, this.bordered = true, this.color = C.grey50});
  final List<Widget> children;
  final String? note;
  final bool bordered;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottom > 20 ? bottom : 20),
      decoration: BoxDecoration(
        color: color,
        border: bordered ? const Border(top: BorderSide(color: C.grey200)) : null,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          children[i],
        ],
        if (note != null) ...[
          const SizedBox(height: 12),
          Text(note!, textAlign: TextAlign.center, style: T.c1(C.grey500)),
        ],
      ]),
    );
  }
}

class NavItem {
  const NavItem(this.key, this.label, this.icon);
  final String key, label, icon;
}

/// Navbar bawah 3 item untuk TU (Dashboard/Ratings/Profile) dan Sarpras (Dashboard/History/Profile).
class StaffNavBar extends StatelessWidget {
  const StaffNavBar({super.key, required this.items, required this.active, required this.onSelect});
  final List<NavItem> items;
  final String active;
  final void Function(String key) onSelect;

  static const tu = [NavItem('dashboard', 'Dashboard', 'home'), NavItem('ratings', 'Ratings', 'star'), NavItem('profile', 'Profile', 'user')];
  static const sarpras = [NavItem('dashboard', 'Dashboard', 'home'), NavItem('history', 'History', 'history'), NavItem('profile', 'Profile', 'user')];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      height: 69 + (bottom < 8 ? 8 : bottom),
      padding: EdgeInsets.only(bottom: bottom < 8 ? 8 : bottom),
      decoration: const BoxDecoration(color: C.grey50, border: Border(top: BorderSide(color: C.grey200))),
      child: Row(children: [
        for (final it in items)
          Expanded(
            child: InkWell(
              onTap: () => onSelect(it.key),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                AppIcon(it.icon, color: active == it.key ? C.grey900 : C.grey400, stroke: active == it.key ? 2.25 : 1.75),
                const SizedBox(height: 4),
                Text(it.label, style: T.c3(active == it.key ? C.grey900 : C.grey400)),
              ]),
            ),
          ),
      ]),
    );
  }
}
