// ignore_for_file: unused_import
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/forms.dart';
import '../../core/widgets/misc.dart';
import '../../core/utils/format.dart';
import 'auth_widgets.dart';

class ItsEmailScreen extends StatefulWidget {
  const ItsEmailScreen({super.key, this.prefill});
  final String? prefill;
  @override
  State<ItsEmailScreen> createState() => _ItsEmailState();
}

class _ItsEmailState extends State<ItsEmailScreen> {
  late final _email = TextEditingController(text: widget.prefill ?? '');
  @override
  Widget build(BuildContext context) {
    return MyItsCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 20),
        Text('Sign In', style: T.x(18, 28, FontWeight.w600, C.grey800)),
        const SizedBox(height: 12),
        AppTextField(label: 'Email ITS', controller: _email, hint: 'name@student.its.ac.id', keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 12),
        Text('Forgot Password ?', style: T.b4(const Color(0xFF3B9BEB))),
        const SizedBox(height: 20),
        AppButton(
          'Next',
          onPressed: () {
            if (_email.text.trim().isEmpty) {
              showSnack(context, 'Isi email ITS.');
              return;
            }
            context.push('/login-its/password', extra: _email.text.trim());
          },
          size: BtnSize.medium,
          expand: true,
          bg: const Color(0xFF0A91FF),
        ),
        const SizedBox(height: 20),
        const Divider(color: C.grey100),
        const SizedBox(height: 8),
        AppButton('Sign-in Options', onPressed: () => context.pop(), variant: BtnVariant.soft, size: BtnSize.medium, iconLeft: 'key-round', expand: true),
      ]),
    );
  }
}
