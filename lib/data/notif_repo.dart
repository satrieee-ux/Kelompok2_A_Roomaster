// ignore_for_file: unused_import
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/format.dart';
import '../core/widgets/misc.dart';
import 'models.dart';
import 'supabase_client.dart';

class NotifRepo {
  Future<List<AppNotif>> list() async {
    final rows = await db.from('notifikasi').select().eq('id_pengguna', myId).order('waktu', ascending: false).limit(100);
    return rows.map(AppNotif.fromMap).toList();
  }

  Future<int> unread() async {
    final rows = await db.from('notifikasi').select('id').eq('id_pengguna', myId).eq('sudah_dibaca', false);
    return rows.length;
  }

  Future<void> markAllRead() => db.rpc('tandai_notifikasi_dibaca');
}
