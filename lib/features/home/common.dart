// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/headers.dart';
import '../../data/auth_providers.dart';
import '../../data/chat_providers.dart';
import '../../data/notif_providers.dart';

/// Header gelap beranda dengan data profil + badge, dipakai Home / Rooms / TU / Sarpras.
class RoleHomeHeader extends ConsumerWidget {
  const RoleHomeHeader({
    super.key,
    required this.heading,
    this.search = true,
    this.chat = true,
    this.controller,
    this.onChanged,
    this.notifRoute = '/notifikasi',
    this.chatRoute = '/chat',
    this.searchRoute = '/search',
  });
  final String heading;
  final bool search, chat;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String notifRoute, chatRoute, searchRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(profileP).valueOrNull;
    final un = ref.watch(unreadNotifP).valueOrNull ?? 0;
    final uc = ref.watch(unreadChatP).valueOrNull ?? 0;
    return HomeHeader(
      name: p?.nama ?? '',
      avatarPath: p?.fotoProfil,
      heading: heading,
      showSearch: search,
      searchController: controller,
      onSearchChanged: onChanged,
      onSearch: () => context.push(searchRoute),
      onChat: chat ? () => context.push(chatRoute) : null,
      onNotif: () => context.push(notifRoute),
      onAvatar: () => context.go('/profile'),
      unreadChat: uc,
      unreadNotif: un,
    );
  }
}

class RoleCompactHeader extends ConsumerWidget {
  const RoleCompactHeader({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(profileP).valueOrNull;
    return CompactHeader(
      name: p?.nama ?? '',
      avatarPath: p?.fotoProfil,
      onSearch: () => context.push('/search'),
      onChat: () => context.push('/chat'),
      onNotif: () => context.push('/notifikasi'),
      onAvatar: () => context.go('/profile'),
    );
  }
}

String greeting() {
  final h = DateTime.now().hour;
  if (h < 11) return 'Good Morning';
  if (h < 15) return 'Good Afternoon';
  if (h < 18) return 'Good Evening';
  return 'Good Night';
}
