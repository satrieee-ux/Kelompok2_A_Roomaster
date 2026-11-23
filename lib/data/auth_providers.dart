// ignore_for_file: unused_import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models.dart';
import 'auth_repo.dart';

final authRepoP = Provider((_) => AuthRepo());

final authStateP = StreamProvider<AuthState>((_) => Supabase.instance.client.auth.onAuthStateChange);

/// Profil pengguna login; null bila belum login.
final profileP = FutureProvider<Profile?>((ref) async {
  ref.watch(authStateP);
  return ref.read(authRepoP).profile();
});

final profileStatsP = FutureProvider<Map<String, int>>((ref) async {
  final p = await ref.watch(profileP.future);
  if (p == null) return {};
  return ref.read(authRepoP).stats(p.peran);
});
