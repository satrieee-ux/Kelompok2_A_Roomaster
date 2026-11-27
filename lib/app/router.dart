import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/its_email_screen.dart';
import '../features/auth/its_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/auth/splash_screen.dart';
import '../features/booking/booking_form_screen.dart';
import '../features/booking/booking_review_screen.dart';
import '../features/booking/bookings_screen.dart';
import '../features/booking/check_in_screen.dart';
import '../features/booking/check_in_success_screen.dart';
import '../features/booking/check_out_success_screen.dart';
import '../features/home/home_screen.dart';
import '../features/inbox/chat_list_screen.dart';
import '../features/inbox/chat_room_screen.dart';
import '../features/inbox/notifications_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/report/report_form_screen.dart';
import '../features/report/report_history_screen.dart';
import '../features/report/report_submitted_screen.dart';
import '../features/report/report_summary_screen.dart';
import '../features/rooms/room_detail_screen.dart';
import '../features/rooms/rooms_screen.dart';
import '../features/rooms/search_screen.dart';
import '../features/sarpras/damage_report_screen.dart';
import '../features/sarpras/status_updated_screen.dart';
import '../features/tu/tu_ratings_screen.dart';
import '../features/tu/tu_result_screen.dart';
import '../features/tu/tu_review_screen.dart';

class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) => notifyListeners());
  }
  late final StreamSubscription<AuthState> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

int _id(GoRouterState s) => int.parse(s.pathParameters['id']!);

const _publicPaths = {'/', '/login', '/signup'};

final routerP = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh();
  ref.onDispose(refresh.dispose);
  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = Supabase.instance.client.auth.currentSession != null;
      final loc = state.matchedLocation;
      final isPublic = _publicPaths.contains(loc) || loc.startsWith('/login-its');
      if (!loggedIn && !isPublic) return '/login';
      if (loggedIn && (loc == '/' || loc == '/login' || loc == '/signup' || loc.startsWith('/login-its'))) return '/menu-utama';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(path: '/login-its/email', builder: (_, s) => ItsEmailScreen(prefill: s.extra as String?)),
      GoRoute(path: '/login-its/password', builder: (_, s) => ItsPasswordScreen(email: s.extra as String? ?? '')),

      // Ruangan & pencarian
      GoRoute(path: '/rooms', builder: (_, s) => RoomsScreen(category: s.uri.queryParameters['category'])),
      GoRoute(path: '/rooms/:id', builder: (_, s) => RoomDetailScreen(id: _id(s), initialTab: int.tryParse(s.uri.queryParameters['tab'] ?? '') ?? 0)),
      GoRoute(path: '/rooms/:id/book', builder: (_, s) => BookingFormScreen(roomId: _id(s))),
      GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
      GoRoute(path: '/booking/:id/ringkasan', builder: (_, s) => BookingReviewScreen(id: _id(s))),
      GoRoute(path: '/bookings', builder: (_, __) => const BookingsScreen()),
      GoRoute(path: '/checkin/:id', builder: (_, s) => CheckInScreen(id: _id(s))),
      GoRoute(path: '/checkin/:id/success', builder: (_, __) => const CheckInSuccessScreen()),
      GoRoute(path: '/checkout/:id/success', builder: (_, s) => CheckOutSuccessScreen(id: _id(s))),
      GoRoute(
        path: '/qreporting/report',
        builder: (_, s) => ReportFormScreen(roomId: int.tryParse(s.uri.queryParameters['room'] ?? ''), draftId: int.tryParse(s.uri.queryParameters['draft'] ?? '')),
      ),
      GoRoute(path: '/qreporting/submitted/:id', builder: (_, s) => ReportSubmittedScreen(id: _id(s))),
      GoRoute(path: '/qreporting/history', builder: (_, __) => const ReportHistoryScreen()),
      GoRoute(path: '/qreporting/summary/:id', builder: (_, s) => ReportSummaryScreen(id: _id(s))),

      // Inbox & profil
      GoRoute(path: '/notifikasi', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/chat', builder: (_, __) => const ChatListScreen()),
      GoRoute(path: '/chat/:id', builder: (_, s) => ChatRoomScreen(id: _id(s))),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/profile/edit', builder: (_, __) => const EditProfileScreen()),

      // TU
      GoRoute(path: '/tu/review/:id', builder: (_, s) => TuReviewScreen(id: _id(s))),
      GoRoute(path: '/tu/result/:kind', builder: (_, s) => TuResultScreen(kind: s.pathParameters['kind']!, code: s.uri.queryParameters['code'])),
      GoRoute(path: '/tu/ratings', builder: (_, __) => const TuRatingsScreen()),
      GoRoute(path: '/sarpras/report/:id', builder: (_, s) => DamageReportScreen(id: _id(s))),
      GoRoute(path: '/sarpras/updated', builder: (_, __) => const StatusUpdatedScreen()),
      GoRoute(path: '/menu-utama', builder: (_, __) => const HomeScreen()),  // sementara; diganti RoleGate di paket 7
    ],
  );
});
