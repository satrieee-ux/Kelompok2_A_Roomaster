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

class ItsPasswordScreen extends ConsumerStatefulWidget {
  const ItsPasswordScreen({super.key, required this.email});
  final String email;
  @override
  ConsumerState<ItsPasswordScreen> createState() => _ItsPasswordState();
}

class _ItsPasswordState extends ConsumerState<ItsPasswordScreen> {
  final _pass = TextEditingController();
  bool _busy = false, _remember = false;

  Future<void> _go() async {
    setState(() => _busy = true);
    try {
      await ref.read(authRepoP).signIn(widget.email, _pass.text);
      if (mounted) context.go('/menu-utama');
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyItsCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => context.pop(),
          child: Row(children: [const AppIcon('arrow-left', size: 20, color: C.grey500), const SizedBox(width: 8), Flexible(child: Text(widget.email, style: T.b3(C.grey500), overflow: TextOverflow.ellipsis))]),
        ),
        const SizedBox(height: 8),
        Text('Enter Password', style: T.x(18, 28, FontWeight.w600, C.grey800)),
        const SizedBox(height: 12),
        AppTextField(controller: _pass, hint: 'Password', obscure: true, onSubmitted: (_) => _go()),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Forgot Password ?', style: T.b4(const Color(0xFF3B9BEB))),
          GestureDetector(
            onTap: () => setState(() => _remember = !_remember),
            child: Row(children: [
              Icon(_remember ? Icons.check_box : Icons.check_box_outline_blank, size: 18, color: _remember ? C.primary800 : C.grey500),
              const SizedBox(width: 8),
              Text('Remember me', style: T.b3(C.grey500)),
            ]),
          ),
        ]),
        const SizedBox(height: 20),
        AppButton('Log In', onPressed: _busy ? null : _go, size: BtnSize.medium, expand: true, bg: const Color(0xFF0A91FF), loading: _busy),
      ]),
    );
  }
}
