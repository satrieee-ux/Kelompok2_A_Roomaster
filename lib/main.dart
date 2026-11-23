import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';

const _url = String.fromEnvironment('SUPABASE_URL');
const _anon = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en');
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  if (_url.isEmpty || _anon.isEmpty) {
    runApp(const MaterialApp(home: Scaffold(body: Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Set --dart-define=SUPABASE_URL=... dan --dart-define=SUPABASE_ANON_KEY=...')))))); 
    return;
  }
  await Supabase.initialize(url: _url, anonKey: _anon);
  runApp(const ProviderScope(child: RoomasterApp()));
}
