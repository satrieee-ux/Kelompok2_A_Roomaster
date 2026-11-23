// ignore_for_file: unused_import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models.dart';
import 'auth_providers.dart';
import 'report_repo.dart';

final reportRepoP = Provider((_) => ReportRepo());

final myReportsP = FutureProvider<List<Report>>((ref) {
  ref.watch(authStateP);
  return ref.read(reportRepoP).mine();
});

final reportP = FutureProvider.family<Report, int>((ref, id) => ref.read(reportRepoP).byId(id));

final reportMediaP = FutureProvider.family<List<ReportMedia>, int>((ref, id) => ref.read(reportRepoP).media(id));

final reportUpdatesP = FutureProvider.family<List<ReportUpdate>, int>((ref, id) => ref.read(reportRepoP).updates(id));

final sarprasReportsP = FutureProvider<List<Report>>((ref) {
  ref.watch(authStateP);
  return ref.read(reportRepoP).all();
});

final resolvedWeekP = FutureProvider<int>((ref) {
  ref.watch(authStateP);
  return ref.read(reportRepoP).resolvedThisWeek();
});
