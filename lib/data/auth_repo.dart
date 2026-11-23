// ignore_for_file: unused_import
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/format.dart';
import '../core/widgets/misc.dart';
import 'models.dart';
import 'supabase_client.dart';

/// Satu kelas repository per area. Semua RLS ditegakkan di server.
class AuthRepo {
  Future<void> signIn(String email, String password) async {
    await db.auth.signInWithPassword(email: email.trim(), password: password);
  }

  /// Mengembalikan true bila sesi langsung aktif (konfirmasi email dimatikan).
  Future<bool> signUp({required String nama, required String email, required String password, String? nrp, String? peran}) async {
    final res = await db.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'nama': nama.trim(), if (nrp != null && nrp.isNotEmpty) 'nrp': nrp, if (peran != null) 'peran': peran},
    );
    return res.session != null;
  }

  Future<void> signOut() => db.auth.signOut();

  Future<void> resetPassword(String email) => db.auth.resetPasswordForEmail(email.trim());

  Future<Profile?> profile() async {
    final u = db.auth.currentUser;
    if (u == null) return null;
    final m = await db.from('profiles').select().eq('id', u.id).maybeSingle();
    return m == null ? null : Profile.fromMap(m);
  }

  Future<void> updateProfile({String? nama, String? noTelepon, DateTime? tanggalLahir, String? fotoProfil}) async {
    await db.from('profiles').update({
      if (nama != null) 'nama': nama,
      if (noTelepon != null) 'no_telepon': noTelepon,
      if (tanggalLahir != null) 'tanggal_lahir': Fmt.isoDate(tanggalLahir),
      if (fotoProfil != null) 'foto_profil': fotoProfil,
    }).eq('id', myId);
  }

  Future<String> uploadAvatar(PickedUpload f) async {
    final ext = f.name.contains('.') ? f.name.split('.').last : 'jpg';
    final path = '$myId/avatar_${DateTime.now().millisecondsSinceEpoch}.$ext';
    await db.storage.from('profil').uploadBinary(path, f.bytes, fileOptions: FileOptions(contentType: f.mime, upsert: true));
    return path;
  }

  Future<void> changePassword(String newPassword) async {
    await db.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Statistik ringkas untuk halaman profil.
  Future<Map<String, int>> stats(String peran) async {
    if (peran == 'tu') {
      final pend = await db.from('peminjaman').select('id').eq('status', 'pending');
      final done = await db.from('peminjaman').select('id').eq('id_peninjau', myId);
      return {'Pending': pend.length, 'Reviewed': done.length};
    }
    if (peran == 'sarpras') {
      final act = await db.from('laporan_kerusakan').select('id').inFilter('status', ['pending', 'ditinjau', 'diproses', 'menunggu_suku_cadang']);
      final done = await db.from('laporan_kerusakan').select('id').eq('id_penangan', myId).eq('status', 'selesai');
      return {'Active': act.length, 'Resolved': done.length};
    }
    final b = await db.from('peminjaman').select('id').eq('id_peminjam', myId);
    final f = await db.from('ruangan_favorit').select('id_ruangan').eq('id_pengguna', myId);
    final r = await db.from('laporan_kerusakan').select('id').eq('id_pelapor', myId);
    return {'Bookings': b.length, 'Favorites': f.length, 'Reports': r.length};
  }
}
