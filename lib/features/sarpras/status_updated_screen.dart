// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/nav.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/bars.dart';
import '../../core/widgets/forms.dart';
import '../../core/widgets/headers.dart';
import '../../core/widgets/misc.dart';
import '../../core/widgets/page.dart';
import '../../core/widgets/status.dart';
import '../../data/models.dart';
import '../../core/widgets/success_page.dart';

class StatusUpdatedScreen extends StatelessWidget {
  const StatusUpdatedScreen({super.key});
  @override
  Widget build(BuildContext context) => SuccessPage(
        top: 180,
        title: 'Status Update Success',
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('Your facility report status has been updated. Fix the corresponding facility accordingly before updating the status as done, as stated in Roomaster’s user Terms & Conditions.', textAlign: TextAlign.center, style: T.b1(C.grey600)),
        ),
        actions: [AppButton('Back to Home', onPressed: () => context.go('/menu-utama'), iconLeft: 'home', expand: true)],
      );
}
