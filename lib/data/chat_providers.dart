// ignore_for_file: unused_import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models.dart';
import 'auth_providers.dart';
import 'chat_repo.dart';

final chatRepoP = Provider((_) => ChatRepo());

final conversationsP = FutureProvider<List<Conversation>>((ref) {
  ref.watch(authStateP);
  return ref.read(chatRepoP).list();
});

final unreadChatP = FutureProvider<int>((ref) {
  ref.watch(authStateP);
  return ref.read(chatRepoP).unread();
});
