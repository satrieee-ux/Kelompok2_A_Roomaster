// ignore_for_file: unused_import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models.dart';
import 'auth_providers.dart';
import 'notif_repo.dart';

final notifRepoP = Provider((_) => NotifRepo());

final notifsP = FutureProvider<List<AppNotif>>((ref) {
  ref.watch(authStateP);
  return ref.read(notifRepoP).list();
});

/// Badge ikon bel/chat. Di-refresh lewat invalidate saat membuka layar.
final unreadNotifP = FutureProvider<int>((ref) {
  ref.watch(authStateP);
  return ref.read(notifRepoP).unread();
});
