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

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});
  @override
  ConsumerState<SignupScreen> createState() => _SignupState();
}

class _SignupState extends ConsumerState<SignupScreen> {
  final _first = TextEditingController(), _last = TextEditingController(), _email = TextEditingController();
  final _phone = TextEditingController(), _pass = TextEditingController(), _birth = TextEditingController();
  DateTime? _birthDate;
  bool _busy = false;

  Future<void> _submit() async {
    final nama = '${_first.text.trim()} ${_last.text.trim()}'.trim();
    if (nama.isEmpty || _email.text.trim().isEmpty || _pass.text.length < 6) {
      showSnack(context, 'Lengkapi nama, email, dan password (min. 6 karakter).');
      return;
    }
    setState(() => _busy = true);
    try {
      final email = _email.text.trim().toLowerCase();
      if (!email.endsWith('@student.its.ac.id')) {
        showSnack(context, 'Pendaftaran hanya untuk mahasiswa ITS (email @student.its.ac.id).');
        return;
      }
      final nrp = email.endsWith('@student.its.ac.id') ? email.split('@').first : null;
      final active = await ref.read(authRepoP).signUp(nama: nama, email: email, password: _pass.text, nrp: nrp);
      if (!mounted) return;
      if (active) {
        // lengkapi data profil opsional
        try {
          await ref.read(authRepoP).updateProfile(noTelepon: _phone.text.trim().isEmpty ? null : _phone.text.trim(), tanggalLahir: _birthDate);
        } catch (_) {}
        if (mounted) context.go('/menu-utama');
      } else {
        showSnack(context, 'Akun dibuat. Cek email untuk konfirmasi, lalu log in.');
        context.go('/login');
      }
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickBirth() async {
    final d = await showDatePicker(context: context, initialDate: _birthDate ?? DateTime(2003, 1, 1), firstDate: DateTime(1950), lastDate: DateTime.now());
    if (d != null) setState(() {
      _birthDate = d;
      _birth.text = Fmt.dateField(d);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthFrame(
      active: 'signup',
      padBottom: 56,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: AppTextField(label: 'First Name', controller: _first, hint: 'First name', textInputAction: TextInputAction.next)),
          const SizedBox(width: 16),
          Expanded(child: AppTextField(label: 'Last Name', controller: _last, hint: 'Last name', textInputAction: TextInputAction.next)),
        ]),
        const SizedBox(height: 16),
        AppTextField(label: 'Email', controller: _email, hint: 'name@email.com', keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        AppTextField(label: 'Birth of date', controller: _birth, hint: 'DD/MM/YYYY', icon: 'calendar', readOnly: true, onTap: _pickBirth),
        const SizedBox(height: 16),
        AppTextField(label: 'Phone Number', controller: _phone, hint: '8xx xxxx xxxx', keyboardType: TextInputType.phone, prefix: Text('+62', style: T.b4())),
        const SizedBox(height: 16),
        AppTextField(label: 'Set Password', controller: _pass, hint: 'Min. 6 characters', obscure: true),
        const SizedBox(height: 24),
        AppButton('Sign Up', onPressed: _busy ? null : _submit, size: BtnSize.medium, expand: true, loading: _busy),
        const SocialLogin(myits: 'Masuk dengan MyITS'),
      ]),
    );
  }
}

// ---------------- MyITS SSO (tampilan) -> Supabase email+password ----------------
