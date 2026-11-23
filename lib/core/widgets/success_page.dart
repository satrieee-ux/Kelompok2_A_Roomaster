// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/nav.dart';
import '../theme/colors.dart';
import '../theme/text.dart';
import '../utils/format.dart';
import '../utils/pick.dart';
import '../utils/storage_url.dart';
import 'app_button.dart';
import 'app_icon.dart';
import 'bars.dart';
import 'cards.dart';
import 'forms.dart';
import 'headers.dart';
import 'misc.dart';
import 'page.dart';
import 'popups.dart';
import 'status.dart';
import 'tabs.dart';

/// Halaman sukses generik (Request Submitted, Check-In Success, dst.).
class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key, required this.title, required this.body, this.timeline, required this.actions, this.top = 91});
  final String title;
  final Widget body;
  final List<TimelineItem>? timeline;
  final List<Widget> actions;
  final double top;
  @override
  Widget build(BuildContext context) {
    return PageShell(
      padding: EdgeInsets.fromLTRB(24, top, 24, 20),
      child: Column(children: [
        const SuccessBadge(),
        const SizedBox(height: 20),
        Text(title, textAlign: TextAlign.center, style: T.h5()),
        const SizedBox(height: 20),
        body,
        if (timeline != null) ...[
          const SizedBox(height: 24),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: ActivityTimeline(items: timeline!)),
        ],
        const SizedBox(height: 32),
        for (var i = 0; i < actions.length; i++) ...[if (i > 0) const SizedBox(height: 8), actions[i]],
      ]),
    );
  }
}
