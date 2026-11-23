// ignore_for_file: unused_import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models.dart';
import 'auth_providers.dart';
import 'room_repo.dart';

final roomRepoP = Provider((_) => RoomRepo());

final roomsP = FutureProvider<List<Room>>((ref) {
  ref.watch(authStateP);
  return ref.read(roomRepoP).all();
});

final roomP = FutureProvider.family<Room, int>((ref, id) => ref.read(roomRepoP).byId(id));

final roomGalleryP = FutureProvider.family<List<String>, int>((ref, id) => ref.read(roomRepoP).gallery(id));

final roomReviewsP = FutureProvider.family<List<Review>, int>((ref, id) => ref.read(roomRepoP).reviews(id));

final allReviewsP = FutureProvider<List<Review>>((ref) => ref.read(roomRepoP).allReviews());
