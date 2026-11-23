// ignore_for_file: unused_import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models.dart';
import 'auth_providers.dart';
import 'booking_providers.dart';
import 'chat_providers.dart';
import 'notif_providers.dart';
import 'report_providers.dart';
import 'room_providers.dart';

/// Muat ulang data yang sering berubah setelah aksi.
void refreshAll(WidgetRef ref) {
  for (final p in [myBookingsP, upcomingP, myReportsP, tuBookingsP, sarprasReportsP, resolvedWeekP, notifsP, conversationsP, unreadNotifP, unreadChatP, roomsP, profileStatsP]) {
    ref.invalidate(p);
  }
}
