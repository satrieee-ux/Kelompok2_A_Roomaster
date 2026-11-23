// ignore_for_file: unused_import
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/format.dart';
import '../core/widgets/misc.dart';
import 'models.dart';
import 'supabase_client.dart';

class BookingRepo {
  static const _v = 'v_peminjaman';

  Future<List<Booking>> mine() async {
    final rows = await db.from(_v).select().eq('id_peminjam', myId).order('tanggal_pakai', ascending: false).order('waktu_mulai', ascending: false);
    return rows.map(Booking.fromMap).toList();
  }

  Future<Booking> byId(int id) async => Booking.fromMap(await db.from(_v).select().eq('id', id).single());

  /// Booking terdekat milik saya yang akan/sedang berlangsung.
  Future<Booking?> upcoming() async {
    final today = Fmt.isoDate(DateTime.now());
    final rows = await db
        .from(_v)
        .select()
        .eq('id_peminjam', myId)
        .inFilter('status', ['disetujui', 'berlangsung'])
        .gte('tanggal_pakai', today)
        .order('tanggal_pakai')
        .order('waktu_mulai')
        .limit(1);
    return rows.isEmpty ? null : Booking.fromMap(rows.first);
  }

  /// Draft baru, atau perbarui draft/revisi yang sama.
  Future<int> saveDraft({
    int? id,
    required int roomId,
    required String kegiatan,
    required String tujuan,
    required String departemen,
    required DateTime tanggal,
    required String mulai,
    required String selesai,
  }) async {
    final data = {
      'nama_kegiatan': kegiatan,
      'tujuan': tujuan,
      'departemen_penyelenggara': departemen,
      'tanggal_pakai': Fmt.isoDate(tanggal),
      'waktu_mulai': mulai,
      'waktu_selesai': selesai,
    };
    if (id != null) {
      await db.from('peminjaman').update(data).eq('id', id);
      return id;
    }
    final m = await db.from('peminjaman').insert({...data, 'id_peminjam': myId, 'id_ruangan': roomId, 'status': 'draft'}).select('id').single();
    return (m['id'] as num).toInt();
  }

  Future<List<BookingDoc>> docs(int bookingId) async {
    final rows = await db.from('dokumen_peminjaman').select().eq('id_peminjaman', bookingId).order('waktu_unggah');
    return rows.map(BookingDoc.fromMap).toList();
  }

  Future<void> uploadDoc(int bookingId, String jenis, PickedUpload f) async {
    final old = await db.from('dokumen_peminjaman').select('id,path_berkas').eq('id_peminjaman', bookingId).eq('jenis_dokumen', jenis);
    for (final o in old) {
      await db.storage.from('dokumen').remove([o['path_berkas'] as String]);
      await db.from('dokumen_peminjaman').delete().eq('id', o['id']);
    }
    final safe = f.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final path = '$myId/$bookingId/${jenis}_${DateTime.now().millisecondsSinceEpoch}_$safe';
    await db.storage.from('dokumen').uploadBinary(path, f.bytes, fileOptions: FileOptions(contentType: f.mime));
    await db.from('dokumen_peminjaman').insert({
      'id_peminjaman': bookingId,
      'jenis_dokumen': jenis,
      'nama_berkas': f.name,
      'path_berkas': path,
      'ukuran_berkas': f.bytes.length,
    });
  }

  Future<void> removeDoc(BookingDoc d) async {
    await db.storage.from('dokumen').remove([d.path]);
    await db.from('dokumen_peminjaman').delete().eq('id', d.id);
  }

  Future<String> submit(int id) async => (await db.rpc('ajukan_peminjaman', params: {'p_id': id})).toString();
  Future<void> cancel(int id) => db.rpc('batalkan_peminjaman', params: {'p_id': id});

  Future<List<String>> _uploadAll(String bucket, String folder, List<PickedUpload> files) async {
    final out = <String>[];
    for (final f in files) {
      final safe = f.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      final p = '$myId/$folder/${DateTime.now().millisecondsSinceEpoch}_${out.length}_$safe';
      await db.storage.from(bucket).uploadBinary(p, f.bytes, fileOptions: FileOptions(contentType: f.mime));
      out.add(p);
    }
    return out;
  }

  Future<void> checkIn(int id, String catatan, List<PickedUpload> fotos) async {
    final paths = await _uploadAll('kondisi', '$id/checkin', fotos);
    await db.rpc('check_in', params: {'p_id': id, 'p_catatan': catatan, 'p_foto': paths});
  }

  Future<void> checkOut(int id, String catatan, List<String> checklist, List<PickedUpload> fotos) async {
    final paths = await _uploadAll('kondisi', '$id/checkout', fotos);
    await db.rpc('check_out', params: {'p_id': id, 'p_catatan': catatan, 'p_checklist': checklist, 'p_foto': paths});
  }

  Future<void> review(int id, int rating, String komentar) async {
    await db.from('ulasan_peminjaman').insert({'id_peminjaman': id, 'rating': rating, if (komentar.isNotEmpty) 'komentar': komentar});
  }

  Future<List<Map<String, dynamic>>> history(int id) => db.from('riwayat_peminjaman').select().eq('id_peminjaman', id).order('waktu');

  // ---- TU ----
  Future<List<Booking>> queue(List<String> statuses) async {
    final rows = await db.from(_v).select().inFilter('status', statuses).order('tanggal_pengajuan', ascending: true);
    return rows.map(Booking.fromMap).toList();
  }

  Future<void> tinjau(int id, String aksi, String? catatan) => db.rpc('tinjau_peminjaman', params: {'p_id': id, 'p_aksi': aksi, 'p_catatan': catatan});
}
