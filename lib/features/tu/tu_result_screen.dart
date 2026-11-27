// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/forms.dart';
import '../../app/nav.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/bars.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/headers.dart';
import '../../core/widgets/misc.dart';
import '../../core/widgets/page.dart';
import '../../core/widgets/popups.dart';
import '../../core/widgets/status.dart';
import '../../core/widgets/tabs.dart';
import '../../data/models.dart';
import '../../core/widgets/success_page.dart';

class TuResultScreen extends StatelessWidget {
  const TuResultScreen({super.key, required this.kind, this.code});
  final String kind; // approved | revised | rejected
  final String? code;
  @override
  Widget build(BuildContext context) {
    final c = code == null ? 'The booking request' : 'The booking request from #$code';
    final title = {'approved': 'Request Approved', 'revised': 'Revision Requested', 'rejected': 'Request Rejected'}[kind] ?? 'Done';
    final text = {
      'approved': '$c has been completed and the requester will be notified immediately.',
      'revised': '$c has been sent back for revision and the requester will be notified immediately.',
      'rejected': '$c has been rejected and the requester will be notified immediately.',
    }[kind]!;
    return SuccessPage(
      top: 180,
      title: title,
      body: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(text, textAlign: TextAlign.center, style: T.b1(C.grey600))),
      actions: [AppButton('Back to Home', onPressed: () => context.go('/menu-utama'), iconLeft: 'home', expand: true)],
    );
  }
}
