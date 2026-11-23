// ignore_for_file: unused_import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models.dart';
import 'auth_providers.dart';
import 'booking_repo.dart';

final bookingRepoP = Provider((_) => BookingRepo());

final myBookingsP = FutureProvider<List<Booking>>((ref) {
  ref.watch(authStateP);
  return ref.read(bookingRepoP).mine();
});

final bookingP = FutureProvider.family<Booking, int>((ref, id) => ref.read(bookingRepoP).byId(id));

final upcomingP = FutureProvider<Booking?>((ref) {
  ref.watch(authStateP);
  return ref.read(bookingRepoP).upcoming();
});

final bookingDocsP = FutureProvider.family<List<BookingDoc>, int>((ref, id) => ref.read(bookingRepoP).docs(id));

final bookingHistoryP = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, id) => ref.read(bookingRepoP).history(id));

/// TU: antrean peminjaman semua status yang relevan (disaring di klien menurut tab).
final tuBookingsP = FutureProvider<List<Booking>>((ref) {
  ref.watch(authStateP);
  return ref.read(bookingRepoP).queue(['pending', 'revisi', 'disetujui', 'berlangsung', 'selesai', 'ditolak']);
});
