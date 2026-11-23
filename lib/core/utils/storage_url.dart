import 'package:supabase_flutter/supabase_flutter.dart';

/// Konversi path Storage menjadi URL.
class StorageUrls {
  StorageUrls._();

  static SupabaseClient get _c => Supabase.instance.client;
  static final Map<String, _Cached> _signed = {};

  static bool isAsset(String? p) => p != null && p.startsWith('asset:');
  static String assetPath(String p) => p.substring(6);

  /// Bucket publik (profil, ruangan).
  static String publicUrl(String bucket, String path) => _c.storage.from(bucket).getPublicUrl(path);

  /// Bucket privat (dokumen, kondisi, laporan, chat). URL ditembolok ~50 menit.
  static Future<String> signedUrl(String bucket, String path) async {
    final key = '$bucket/$path';
    final hit = _signed[key];
    if (hit != null && hit.expires.isAfter(DateTime.now())) return hit.url;
    final url = await _c.storage.from(bucket).createSignedUrl(path, 3600);
    _signed[key] = _Cached(url, DateTime.now().add(const Duration(minutes: 50)));
    return url;
  }
}

class _Cached {
  _Cached(this.url, this.expires);
  final String url;
  final DateTime expires;
}
