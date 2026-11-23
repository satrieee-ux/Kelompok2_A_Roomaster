// ignore_for_file: unused_import
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/format.dart';
import '../core/widgets/misc.dart';
import 'models.dart';
import 'supabase_client.dart';

class ReportRepo {
  Future<List<Report>> mine() async {
    final rows = await db.from('v_laporan').select().eq('id_pelapor', myId).order('tanggal_lapor', ascending: false);
    return rows.map(Report.fromMap).toList();
  }

  Future<Report> byId(int id) async => Report.fromMap(await db.from('v_laporan').select().eq('id', id).single());

  Future<int> create({required int roomId, required List<String> kategori, required String deskripsi, required bool draft, int? existingId}) async {
    final data = {'kategori_kerusakan': kategori, 'deskripsi_masalah': deskripsi, 'status': draft ? 'draft' : 'pending'};
    if (existingId != null) {
      await db.from('laporan_kerusakan').update(data).eq('id', existingId);
      return existingId;
    }
    final m = await db.from('laporan_kerusakan').insert({...data, 'id_ruangan': roomId, 'id_pelapor': myId}).select('id').single();
    return (m['id'] as num).toInt();
  }

  Future<void> addMedia(int reportId, List<PickedUpload> files) async {
    var i = 0;
    for (final f in files) {
      final safe = f.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      final p = '$myId/$reportId/${DateTime.now().millisecondsSinceEpoch}_${i}_$safe';
      await db.storage.from('laporan').uploadBinary(p, f.bytes, fileOptions: FileOptions(contentType: f.mime));
      await db.from('laporan_media').insert({
        'id_laporan': reportId,
        'tipe': f.mime.startsWith('video') ? 'video' : 'foto',
        'path_berkas': p,
        'ukuran': f.bytes.length,
        'urutan': i,
      });
      i++;
    }
  }

  Future<List<ReportMedia>> media(int reportId) async {
    final rows = await db.from('laporan_media').select().eq('id_laporan', reportId).order('urutan');
    return rows.map(ReportMedia.fromMap).toList();
  }

  Future<List<ReportUpdate>> updates(int reportId) async {
    final rows = await db.from('laporan_update').select().eq('id_laporan', reportId).order('waktu');
    return rows.map(ReportUpdate.fromMap).toList();
  }

  // ---- Sarpras ----
  Future<List<Report>> all() async {
    final rows = await db.from('v_laporan').select().neq('status', 'draft').order('tanggal_lapor', ascending: false);
    return rows.map(Report.fromMap).toList();
  }

  /// Jumlah laporan yang diselesaikan dalam 7 hari terakhir.
  Future<int> resolvedThisWeek() async {
    final since = DateTime.now().subtract(const Duration(days: 7)).toUtc().toIso8601String();
    final rows = await db.from('laporan_update').select('id_laporan').eq('status_baru', 'selesai').gte('waktu', since);
    return rows.map((e) => e['id_laporan']).toSet().length;
  }

  Future<void> updateStatus(int id, String status, String? catatan, String? tingkat) =>
      db.rpc('perbarui_laporan', params: {'p_id': id, 'p_status': status, 'p_catatan': catatan, 'p_tingkat': tingkat});
}
