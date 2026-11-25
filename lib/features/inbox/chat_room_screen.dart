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
import '../../data/supabase_client.dart';

// ---------------------------------------------------------------------
// Ruang chat (realtime)
// ---------------------------------------------------------------------
class ChatRoomScreen extends ConsumerStatefulWidget {
  const ChatRoomScreen({super.key, required this.id});
  final int id;
  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomState();
}

class _ChatRoomState extends ConsumerState<ChatRoomScreen> {
  final _text = TextEditingController();
  final _scroll = ScrollController();
  late final Stream<List<Message>> _stream = ref.read(chatRepoP).stream(widget.id);
  Conversation? _conv;
  bool _sending = false;
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    ref.read(chatRepoP).byId(widget.id).then((c) {
      if (mounted) setState(() => _conv = c);
    });
    ref.read(chatRepoP).markRead(widget.id).then((_) {
      ref.invalidate(unreadChatP);
      ref.invalidate(conversationsP);
    });
  }

  Future<void> _send({PickedUpload? file}) async {
    final t = _text.text;
    if ((t.trim().isEmpty) && file == null) return;
    setState(() => _sending = true);
    try {
      await ref.read(chatRepoP).send(widget.id, text: t, file: file);
      _text.clear();
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _attach() async {
    final src = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const AppIcon('camera-plus'), title: const Text('Camera'), onTap: () => Navigator.pop(ctx, ImageSource.camera)),
          ListTile(leading: const AppIcon('image'), title: const Text('Gallery'), onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
        ]),
      ),
    );
    if (src == null) return;
    final f = await pickImage(src);
    if (f != null) await _send(file: f);
  }

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(profileP).valueOrNull;
    final myUid = me?.id ?? myId;
    final c = _conv;
    String status = '';
    if (c != null && me != null && !me.isStaf) {
      final m = c.responsMenit;
      status = 'Average Response: ${m == null ? '-' : (m >= 60 ? '${(m / 60).round()}h' : '${m}m')}';
    } else if (me?.peran == 'tu') {
      status = 'Borrower';
    }
    return PageShell(
      bg: C.grey50,
      scroll: false,
      header: ChatHeader(name: c?.namaLawan ?? '...', avatarPath: c?.fotoLawan, status: status, onBack: () => goBack(context, '/chat')),
      bottom: ChatBar(controller: _text, onSend: _send, onAttach: _attach, sending: _sending),
      child: StreamBuilder<List<Message>>(
        stream: _stream,
        builder: (context, snap) {
          if (snap.hasError) return Center(child: ErrorBox(snap.error!));
          if (!snap.hasData) return const LoadingBox();
          final msgs = snap.data!;
          if (msgs.length != _lastCount) {
            _lastCount = msgs.length;
            _toBottom();
            if (msgs.isNotEmpty && msgs.last.idPengirim != myUid) ref.read(chatRepoP).markRead(widget.id);
          }
          final items = <Widget>[];
          DateTime? day;
          for (final m in msgs) {
            final d = m.waktu.toLocal();
            if (day == null || d.day != day.day || d.month != day.month || d.year != day.year) {
              day = d;
              items.add(Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: C.grey800, borderRadius: BorderRadius.circular(999)),
                  child: Text(Fmt.chatDay(m.waktu), style: T.c2(Colors.white)),
                ),
              ));
            }
            final out = m.idPengirim == myUid;
            items.add(Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: ChatBubble(
                out: out,
                text: m.isi,
                time: Fmt.clock(m.waktu),
                name: out ? (me?.nama ?? '') : (c?.namaLawan ?? ''),
                avatarPath: out ? me?.fotoProfil : c?.fotoLawan,
                image: m.lampiran == null ? null : SignedImage(bucket: 'chat', path: m.lampiran!, fit: BoxFit.cover),
              ),
            ));
          }
          if (items.isEmpty) return const EmptyText('Say hello 👋');
          return ListView(controller: _scroll, padding: const EdgeInsets.only(top: 16, bottom: 20), children: items);
        },
      ),
    );
  }
}
