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
import '../../data/auth_providers.dart';
import 'auth_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginState();
}

class _LoginState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _remember = false, _busy = false;

  Future<void> _submit() async {
    if (_email.text.trim().isEmpty || _pass.text.isEmpty) {
      showSnack(context, 'Isi email dan password.');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(authRepoP).signIn(_email.text, _pass.text);
      if (mounted) context.go('/menu-utama');
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthFrame(
      active: 'login',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AppTextField(label: 'Email', controller: _email, hint: 'name@email.com', keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next),
        const SizedBox(height: 8),
        AppTextField(label: 'Password', controller: _pass, hint: 'Password', obscure: true, textInputAction: TextInputAction.done, onSubmitted: (_) => _submit()),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          GestureDetector(
            onTap: () => setState(() => _remember = !_remember),
            child: Row(children: [
              Icon(_remember ? Icons.check_box : Icons.check_box_outline_blank, size: 18, color: _remember ? C.primary800 : C.grey500),
              const SizedBox(width: 8),
              Text('Remember me', style: T.b3(C.grey500)),
            ]),
          ),
          GestureDetector(
            onTap: () async {
              if (_email.text.trim().isEmpty) {
                showSnack(context, 'Isi email dulu untuk reset password.');
                return;
              }
              try {
                await ref.read(authRepoP).resetPassword(_email.text);
                if (context.mounted) showSnack(context, 'Tautan reset password dikirim ke email.');
              } catch (e) {
                if (context.mounted) showSnack(context, friendlyError(e));
              }
            },
            child: Text('Forgot Password ?', style: T.b4(const Color(0xFF3B9BEB))),
          ),
        ]),
        const SizedBox(height: 24),
        AppButton('Log In', onPressed: _busy ? null : _submit, size: BtnSize.medium, expand: true, loading: _busy),
        const SocialLogin(myits: 'MyITS Account'),
        const SizedBox(height: 24),
        Center(
          child: GestureDetector(
            onTap: () => context.go('/signup'),
            child: Text.rich(TextSpan(style: T.b3(C.grey500), children: [
              const TextSpan(text: "Don't have an account? "),
              TextSpan(text: 'Sign Up', style: T.b4(const Color(0xFF3B9BEB)).copyWith(decoration: TextDecoration.underline)),
            ])),
          ),
        ),
      ]),
    );
  }
}
