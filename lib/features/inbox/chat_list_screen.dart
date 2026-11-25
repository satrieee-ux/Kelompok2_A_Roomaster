// ignore_for_file: unused_import
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/nav.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text.dart';
import '../../core/utils/format.dart';
import '../../core/utils/pick.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/bars.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/headers.dart';
import '../../core/widgets/misc.dart';
import '../../core/widgets/page.dart';
import '../../core/widgets/popups.dart';
import '../../core/widgets/tabs.dart';
import '../../data/models.dart';
import '../../data/auth_providers.dart';
import '../../data/chat_providers.dart';

// ---------------------------------------------------------------------
// Daftar percakapan
// ---------------------------------------------------------------------
class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});
  @override
  ConsumerState<ChatListScreen> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatListScreen> {
  final _q = TextEditingController();
  bool _busy = false;

  Future<void> _newMessage(String role) async {
    setState(() => _busy = true);
    try {
      int id;
      if (role == 'tu') {
        final list = await ref.read(chatRepoP).borrowers();
        if (!mounted) return;
        if (list.isEmpty) {
          showSnack(context, 'Belum ada peminjam yang bisa dihubungi.');
          return;
        }
        final chosen = await showModalBottomSheet<Profile>(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          builder: (ctx) => SafeArea(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 16),
              Text('Choose a borrower', style: T.s1()),
              const SizedBox(height: 8),
              Flexible(
                child: ListView(shrinkWrap: true, children: [
                  for (final p in list)
                    ListTile(
                      leading: UserAvatar(name: p.nama, path: p.fotoProfil, size: 40),
                      title: Text(p.nama, style: T.b4()),
                      subtitle: Text(p.peranLabel, style: T.c2(C.grey500)),
                      onTap: () => Navigator.pop(ctx, p),
                    ),
                ]),
              ),
            ]),
          ),
        );
        if (chosen == null) return;
        id = await ref.read(chatRepoP).startWithBorrower(chosen.id);
      } else {
        id = await ref.read(chatRepoP).start();
      }
      ref.invalidate(conversationsP);
      if (mounted) context.push('/chat/$id');
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(profileP).valueOrNull?.peran ?? 'mahasiswa';
    final async = ref.watch(conversationsP);
    final isTu = role == 'tu';
    return PageShell(
      bg: C.grey50,
      header: TopAppBar(title: 'Chats', onBack: () => goBack(context), onEnd: () => context.go('/menu-utama')),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      onRefresh: () async => ref.invalidate(conversationsP),
      child: Column(children: [
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: C.grey50, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.grey300)),
          child: Row(children: [
            const AppIcon('search', size: 20, color: C.grey500),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _q,
                onChanged: (_) => setState(() {}),
                style: T.b1(),
                decoration: InputDecoration(hintText: 'Search conversations...', hintStyle: T.b1(C.grey500), border: InputBorder.none, isDense: true),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 32),
        async.when(
          loading: () => const LoadingBox(),
          error: (e, _) => ErrorBox(e, onRetry: () => ref.invalidate(conversationsP)),
          data: (all) {
            final q = _q.text.trim().toLowerCase();
            final list = all.where((c) => q.isEmpty || c.namaLawan.toLowerCase().contains(q) || c.preview.toLowerCase().contains(q)).toList();
            return Column(children: [
              for (final c in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ConversationCard(
                    name: c.namaLawan,
                    preview: c.preview,
                    time: c.waktuTerakhir == null ? '' : Fmt.clock(c.waktuTerakhir!),
                    unread: c.belumDibaca,
                    avatarPath: c.fotoLawan,
                    onTap: () => context.push('/chat/${c.id}'),
                  ),
                ),
            ]);
          },
        ),
        const SizedBox(height: 16),
        DashedBorder(
          radius: 12,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 56),
            child: Column(children: [
              const AppIcon('messages-square', size: 32, color: C.grey500),
              const SizedBox(height: 12),
              Text('Start a new conversation?', style: T.s2()),
              const SizedBox(height: 4),
              Text(isTu ? 'Contact borrowers about their requests.' : 'Contact administrators for facility requests.', textAlign: TextAlign.center, style: T.b3(C.grey500)),
              const SizedBox(height: 12),
              AppButton('New Message', onPressed: _busy ? null : () => _newMessage(role), size: BtnSize.medium, loading: _busy),
            ]),
          ),
        ),
      ]),
    );
  }
}
