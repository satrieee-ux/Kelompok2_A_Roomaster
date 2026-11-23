import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text.dart';
import 'app_icon.dart';
import 'misc.dart';

/// Tinggi area status bar iPhone 13 yang sudah termasuk dalam spesifikasi desain (47px).
const double kDesignStatusBar = 47;

double _top(BuildContext c) => MediaQuery.paddingOf(c).top;

/// Header gelap beranda: avatar + chat + notif, sapaan, kolom search. Sticky (ditaruh di luar scroll).
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.name,
    this.avatarPath,
    required this.heading,
    this.onSearch,
    this.onChat,
    required this.onNotif,
    this.onAvatar,
    this.unreadChat = 0,
    this.unreadNotif = 0,
    this.searchController,
    this.onSearchChanged,
    this.showSearch = true,
  });
  final String name;
  final String? avatarPath;
  final String heading;
  final VoidCallback? onSearch, onChat;
  final VoidCallback onNotif;
  final VoidCallback? onAvatar;
  final int unreadChat, unreadNotif;

  /// Bila diisi, kolom search dapat diketik (dashboard TU). Bila null, kolom hanya tombol menuju layar search.
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final bool showSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: C.primary900,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: _top(context) + (108 - kDesignStatusBar),
          child: Padding(
            padding: const EdgeInsets.only(left: 24, right: 8, bottom: 16),
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              GestureDetector(
                onTap: onAvatar,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: UserAvatar(name: name, path: avatarPath, size: 32, online: true, ringColor: C.primary900),
                ),
              ),
              const Spacer(),
              if (onChat != null) _HeaderIcon('message-square', onChat!, badge: unreadChat),
              _HeaderIcon('bell', onNotif, badge: unreadNotif),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(heading, style: T.h5(Colors.white)),
        ),
        if (showSearch) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GestureDetector(
              onTap: searchController == null ? onSearch : null,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: C.grey100, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const AppIcon('search', color: C.grey500),
                  const SizedBox(width: 12),
                  Expanded(
                    child: searchController == null
                        ? Text('Search', style: T.b1(C.grey500))
                        : TextField(
                            controller: searchController,
                            onChanged: onSearchChanged,
                            style: T.b1(),
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: T.b1(C.grey500),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                  ),
                ]),
              ),
            ),
          ),
        ],
      ]),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon(this.icon, this.onTap, {this.badge = 0});
  final String icon;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: SizedBox(
        width: 48,
        height: 44,
        child: Stack(alignment: Alignment.center, children: [
          AppIcon(icon, color: Colors.white),
          if (badge > 0)
            Positioned(
              top: 6,
              right: 8,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: C.secondary500,
                  shape: BoxShape.circle,
                  border: Border.all(color: C.primary900, width: 2),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

/// Header gelap ringkas (Your Bookings): avatar + search + chat + notif.
class CompactHeader extends StatelessWidget {
  const CompactHeader({
    super.key,
    required this.name,
    this.avatarPath,
    required this.onSearch,
    required this.onChat,
    required this.onNotif,
    this.onAvatar,
  });
  final String name;
  final String? avatarPath;
  final VoidCallback onSearch, onChat, onNotif;
  final VoidCallback? onAvatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: C.primary900,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      height: _top(context) + (108 - kDesignStatusBar),
      padding: const EdgeInsets.only(left: 24, right: 8, bottom: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        GestureDetector(
          onTap: onAvatar,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: UserAvatar(name: name, path: avatarPath, size: 32, online: true, ringColor: C.primary900),
          ),
        ),
        const Spacer(),
        _HeaderIcon('search', onSearch),
        _HeaderIcon('message-square', onChat),
        _HeaderIcon('bell', onNotif),
      ]),
    );
  }
}

/// Header pencarian gelap. `filters` kosong = kolom input; berisi = kotak chip filter.
class SearchHeader extends StatelessWidget {
  const SearchHeader({
    super.key,
    required this.onBack,
    required this.onFilter,
    required this.onDate,
    this.controller,
    this.onSubmitted,
    this.chips = const [],
    this.onChipTap,
    this.autofocus = true,
  });
  final VoidCallback onBack, onFilter, onDate;
  final TextEditingController? controller;
  final ValueChanged<String>? onSubmitted;
  final List<SearchChip> chips;
  final void Function(int index)? onChipTap;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: C.primary900,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(24, _top(context) + (66 - kDesignStatusBar), 24, 20),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(
          child: chips.isEmpty
              ? Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: C.grey100, borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    GestureDetector(onTap: onBack, child: const AppIcon('arrow-left', color: C.grey500)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        autofocus: autofocus,
                        textInputAction: TextInputAction.search,
                        onSubmitted: onSubmitted,
                        style: T.b1(C.grey800),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: 'Search',
                          hintStyle: T.b1(C.grey500),
                        ),
                      ),
                    ),
                  ]),
                )
              : Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: C.grey100, borderRadius: BorderRadius.circular(12)),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    GestureDetector(onTap: onBack, child: const AppIcon('arrow-left', color: C.grey400)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Wrap(spacing: 8, runSpacing: 8, children: [
                        for (var i = 0; i < chips.length; i++)
                          GestureDetector(
                            onTap: onChipTap == null ? null : () => onChipTap!(i),
                            child: _chip(chips[i]),
                          ),
                      ]),
                    ),
                  ]),
                ),
        ),
        const SizedBox(width: 12),
        GestureDetector(onTap: onFilter, child: const AppIcon('list-filter', color: Colors.white)),
        const SizedBox(width: 12),
        GestureDetector(onTap: onDate, child: const AppIcon('calendar', color: Colors.white)),
      ]),
    );
  }

  Widget _chip(SearchChip c) {
    final iconOnly = c.label == null;
    return Container(
      height: iconOnly || c.icon != null ? 40 : 32,
      width: iconOnly ? 40 : null,
      padding: iconOnly ? EdgeInsets.zero : EdgeInsets.only(left: c.icon != null ? 12 : 16, right: 16),
      decoration: BoxDecoration(color: C.grey200, borderRadius: BorderRadius.circular(99)),
      child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
        if (c.icon != null) AppIcon(c.icon!, color: C.primary500),
        if (c.icon != null && c.label != null) const SizedBox(width: 8),
        if (c.label != null) Text(c.label!, style: T.c2(C.primary500)),
      ]),
    );
  }
}

class SearchChip {
  const SearchChip({this.icon, this.label});
  final String? icon;
  final String? label;
}

/// Mobile TopAppBar putih: back + judul + ikon kanan (default home).
class TopAppBar extends StatelessWidget {
  const TopAppBar({
    super.key,
    required this.title,
    required this.onBack,
    this.endIcon = 'home',
    this.onEnd,
    this.plain = false,
  });
  final String title;
  final VoidCallback onBack;
  final String endIcon;
  final VoidCallback? onEnd;

  /// plain = tanpa latar putih/bayangan (header QReporting).
  final bool plain;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _top(context) + (112 - kDesignStatusBar),
      padding: EdgeInsets.only(left: plain ? 16 : 40, right: plain ? 16 : 40, bottom: 12),
      decoration: BoxDecoration(
        color: plain ? C.grey100 : Colors.white,
        borderRadius: plain ? null : const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: plain ? null : C.shadowCard,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          height: 44,
          child: Row(children: [
            InkResponse(onTap: onBack, child: const AppIcon('arrow-left', color: C.grey800)),
            Expanded(child: Center(child: Text(title, style: T.s2(), maxLines: 1, overflow: TextOverflow.ellipsis))),
            onEnd == null
                ? const SizedBox(width: 24)
                : InkResponse(onTap: onEnd, child: AppIcon(endIcon, color: C.grey800)),
          ]),
        ),
      ),
    );
  }
}

/// Header ruang chat: back + avatar + nama + status respons + menu.
class ChatHeader extends StatelessWidget {
  const ChatHeader({super.key, required this.name, this.avatarPath, required this.status, required this.onBack});
  final String name;
  final String? avatarPath;
  final String status;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _top(context) + (124 - kDesignStatusBar),
      padding: const EdgeInsets.only(left: 40, right: 40, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: C.shadowCard,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Row(children: [
          InkResponse(onTap: onBack, child: const AppIcon('arrow-left', color: C.grey800)),
          const SizedBox(width: 12),
          UserAvatar(name: name, path: avatarPath, size: 40, online: true, ringColor: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(name, style: T.s2(), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(status, style: T.c3(C.grey500)),
            ]),
          ),
          const SizedBox(width: 12),
          const AppIcon('ellipsis-vertical', color: C.grey800),
        ]),
      ),
    );
  }
}
