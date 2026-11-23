// ignore_for_file: unused_import
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/format.dart';
import '../core/widgets/misc.dart';
import 'models.dart';
import 'supabase_client.dart';

class ChatRepo {
  Future<List<Conversation>> list() async {
    final rows = await db.from('v_percakapan').select().order('waktu_pesan_terakhir', ascending: false, nullsFirst: false);
    return rows.map(Conversation.fromMap).toList();
  }

  Future<int> unread() async {
    final l = await list();
    return l.fold<int>(0, (a, c) => a + c.belumDibaca);
  }

  Future<int> start({int? roomId, String? staffId}) async =>
      ((await db.rpc('mulai_percakapan', params: {'p_id_staf': staffId, 'p_id_ruangan': roomId})) as num).toInt();

  Future<Conversation> byId(int id) async => Conversation.fromMap(await db.from('v_percakapan').select().eq('id', id).single());

  Stream<List<Message>> stream(int conversationId) => db
      .from('pesan')
      .stream(primaryKey: ['id'])
      .eq('id_percakapan', conversationId)
      .order('waktu_kirim')
      .map((rows) => rows.map(Message.fromMap).toList());

  Future<void> send(int conversationId, {String? text, PickedUpload? file}) async {
    String? path;
    if (file != null) {
      final safe = file.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      path = '$conversationId/${DateTime.now().millisecondsSinceEpoch}_$safe';
      await db.storage.from('chat').uploadBinary(path, file.bytes, fileOptions: FileOptions(contentType: file.mime));
    }
    await db.from('pesan').insert({
      'id_percakapan': conversationId,
      'id_pengirim': myId,
      if (text != null && text.trim().isNotEmpty) 'isi_pesan': text.trim(),
      if (path != null) 'lampiran': path,
    });
  }

  Future<void> markRead(int conversationId) => db.rpc('tandai_pesan_dibaca', params: {'p_id_percakapan': conversationId});

  Future<int> startWithBorrower(String borrowerId, {int? roomId}) async =>
      ((await db.rpc('mulai_percakapan_peminjam', params: {'p_id_peminjam': borrowerId, 'p_id_ruangan': roomId})) as num).toInt();

  /// Peminjam yang pernah mengajukan booking (kandidat "New Message" milik TU).
  Future<List<Profile>> borrowers() async {
    final rows = await db.from('v_peminjaman').select('id_peminjam').neq('status', 'draft');
    final ids = rows.map<String>((e) => e['id_peminjam'] as String).toSet().toList();
    if (ids.isEmpty) return [];
    final ps = await db.from('profiles').select().inFilter('id', ids).order('nama');
    return ps.map(Profile.fromMap).toList();
  }
}
