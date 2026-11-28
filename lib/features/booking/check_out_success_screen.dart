// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/nav.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text.dart';
import '../../core/utils/format.dart';
import '../../core/utils/pick.dart';
import '../../core/utils/storage_url.dart';
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
import '../../data/booking_providers.dart';

class CheckOutSuccessScreen extends ConsumerWidget {
  const CheckOutSuccessScreen({super.key, required this.id});
  final int id;
  @override
  Widget build(BuildContext context, WidgetRef ref) => SuccessPage(
        top: 131,
        title: 'Check-Out Success',
        body: Text('Your room booking check-out process has been completed. If there are any faulty equipment, please report accordingly as stated in Roomaster’s user Terms & Conditions.', textAlign: TextAlign.center, style: T.b1(C.grey600)),
        actions: [
          AppButton('Back to Home', onPressed: () => context.go('/menu-utama'), iconLeft: 'home', expand: true),
          AppButton('Review Room', variant: BtnVariant.secondary, expand: true, onPressed: () async {
            final r = await showReviewSheet(context);
            if (r == null) return;
            try {
              await ref.read(bookingRepoP).review(id, r.rating, r.comment);
              ref.invalidate(bookingP(id));
              if (context.mounted) {
                showSnack(context, 'Thanks for your review!');
                context.go('/menu-utama');
              }
            } catch (e) {
              if (context.mounted) showSnack(context, friendlyError(e));
            }
          }),
        ],
      );
}
