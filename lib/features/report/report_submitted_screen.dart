// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../app/nav.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text.dart';
import '../../core/utils/format.dart';
import '../../core/utils/pick.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/bars.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/forms.dart';
import '../../core/widgets/headers.dart';
import '../../core/widgets/misc.dart';
import '../../core/widgets/page.dart';
import '../../core/widgets/popups.dart';
import '../../core/widgets/status.dart';
import '../../core/widgets/tabs.dart';
import '../../data/models.dart';
import '../../core/widgets/success_page.dart';

class ReportSubmittedScreen extends ConsumerWidget {
  const ReportSubmittedScreen({super.key, required this.id});
  final int id;
  @override
  Widget build(BuildContext context, WidgetRef ref) => SuccessPage(
        top: 91,
        title: 'Report Submitted',
        body: Text('Your facility report has been successfully logged into the system. A maintenance team will review the details shortly.', textAlign: TextAlign.center, style: T.b1(C.grey600)),
        timeline: const [
          TimelineItem('check', StepMode.done, 'Report Submitted', 'Just Now'),
          TimelineItem('hourglass', StepMode.current, 'Pending Review', 'Awaiting Sarpras Admin approval.'),
          TimelineItem('calendar-check', StepMode.todo, 'Confirmation', 'Taken action for report'),
        ],
        actions: [
          AppButton('View Report Details', onPressed: () => context.go('/qreporting/summary/$id'), variant: BtnVariant.secondary, iconRight: 'arrow-right', expand: true),
          AppButton('Back to Home', onPressed: () => context.go('/menu-utama'), iconLeft: 'home', expand: true),
        ],
      );
}
