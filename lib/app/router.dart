import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Router kerangka. Rute layar ditambahkan bertahap oleh tiap paket commit.
final routerP = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const _Kerangka()),
    ],
  );
});

class _Kerangka extends StatelessWidget {
  const _Kerangka();
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Roomaster - kerangka awal (belum ada layar)')));
}
