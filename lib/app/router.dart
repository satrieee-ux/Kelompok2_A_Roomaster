import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/splash_screen.dart';

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
      GoRoute(path: '/menu-utama', builder: (_, __) => const _MenuSementara()),  // sementara; diganti di paket 4 dan 7
    ],
  );
});

class _MenuSementara extends StatelessWidget {
  const _MenuSementara();
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Login berhasil. Menu utama dibuat di paket 4.'),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => Supabase.instance.client.auth.signOut(), child: const Text('Keluar')),
          ]),
        ),
      );
}
