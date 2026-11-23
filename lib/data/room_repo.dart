// ignore_for_file: unused_import
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/format.dart';
import '../core/widgets/misc.dart';
import 'models.dart';
import 'supabase_client.dart';

class RoomRepo {
  Future<List<Room>> all() async {
    final rows = await db.from('v_ruangan').select().order('nama_ruangan');
    final favs = await favoriteIds();
    return rows.map((e) => Room.fromMap(e).withFavorite(favs.contains(e['id']))).toList();
  }

  Future<Room> byId(int id) async {
    final m = await db.from('v_ruangan').select().eq('id', id).single();
    final favs = await favoriteIds();
    return Room.fromMap(m).withFavorite(favs.contains(id));
  }

  Future<Room?> byKode(String kode) async {
    final m = await db.from('v_ruangan').select().eq('kode_ruangan', kode.trim()).maybeSingle();
    return m == null ? null : Room.fromMap(m);
  }

  Future<Set<int>> favoriteIds() async {
    final rows = await db.from('ruangan_favorit').select('id_ruangan').eq('id_pengguna', myId);
    return rows.map<int>((e) => (e['id_ruangan'] as num).toInt()).toSet();
  }

  Future<void> setFavorite(int roomId, bool on) async {
    if (on) {
      await db.from('ruangan_favorit').upsert({'id_pengguna': myId, 'id_ruangan': roomId});
    } else {
      await db.from('ruangan_favorit').delete().eq('id_pengguna', myId).eq('id_ruangan', roomId);
    }
  }

  Future<List<String>> gallery(int roomId) async {
    final rows = await db.from('galeri_ruangan').select('path').eq('id_ruangan', roomId).order('urutan');
    return rows.map<String>((e) => e['path'] as String).toList();
  }

  Future<List<Review>> reviews(int roomId) async {
    final rows = await db.from('v_ulasan_ruangan').select().eq('id_ruangan', roomId).order('tanggal_ulasan', ascending: false);
    return rows.map(Review.fromMap).toList();
  }

  /// Seluruh ulasan + nama ruangan (untuk tab Ratings milik TU).
  Future<List<Review>> allReviews() async {
    final rows = await db.from('v_ulasan_ruangan').select().order('tanggal_ulasan', ascending: false).limit(300);
    final rooms = await db.from('data_ruangan').select('id,nama_ruangan');
    final names = {for (final r in rooms) (r['id'] as num).toInt(): r['nama_ruangan'] as String};
    return rows.map((e) => Review.fromMap({...e, 'nama_ruangan': names[(e['id_ruangan'] as num).toInt()]})).toList();
  }

  Future<Set<int>> usedHours(int roomId, DateTime date) async {
    final res = await db.rpc('jam_terpakai', params: {'p_id_ruangan': roomId, 'p_tanggal': Fmt.isoDate(date)});
    return (res as List).map<int>((e) => (e as num).toInt()).toSet();
  }

  Future<Set<int>> availableOn(DateTime date) async {
    final res = await db.rpc('ruangan_tersedia_pada', params: {'p_tanggal': Fmt.isoDate(date)});
    return (res as List).map<int>((e) => (e as num).toInt()).toSet();
  }
}
