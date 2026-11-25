// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/nav.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text.dart';
import '../../core/utils/format.dart';
import '../../core/utils/pick.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/bars.dart';
import '../../core/widgets/forms.dart';
import '../../core/widgets/headers.dart';
import '../../core/widgets/misc.dart';
import '../../core/widgets/page.dart';
import '../../core/widgets/popups.dart';
import '../../data/models.dart';
import '../../data/auth_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditState();
}

class _EditState extends ConsumerState<EditProfileScreen> {
  final _nama = TextEditingController(), _phone = TextEditingController(), _birth = TextEditingController();
  DateTime? _date;
  PickedUpload? _photo;
  bool _busy = false, _init = false;

  void _fill(Profile p) {
    if (_init) return;
    _init = true;
    _nama.text = p.nama;
    _phone.text = p.noTelepon ?? '';
    _date = p.tanggalLahir;
    _birth.text = p.tanggalLahir == null ? '' : Fmt.dateField(p.tanggalLahir!);
  }

  Future<void> _save(Profile p) async {
    if (_nama.text.trim().isEmpty) {
      showSnack(context, 'Nama tidak boleh kosong.');
      return;
    }
    setState(() => _busy = true);
    try {
      final repo = ref.read(authRepoP);
      String? path;
      if (_photo != null) path = await repo.uploadAvatar(_photo!);
      await repo.updateProfile(nama: _nama.text.trim(), noTelepon: _phone.text.trim(), tanggalLahir: _date, fotoProfil: path);
      ref.invalidate(profileP);
      if (mounted) {
        showSnack(context, 'Profil diperbarui.');
        goBack(context, '/profile');
      }
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(profileP).valueOrNull;
    if (p == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    _fill(p);
    return PageShell(
      header: TopAppBar(title: 'Edit Profile', onBack: () => goBack(context, '/profile'), onEnd: null),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      bottom: ActionBar(children: [AppButton('Save', onPressed: _busy ? null : () => _save(p), expand: true, loading: _busy)]),
      child: Column(children: [
        GestureDetector(
          onTap: () async {
            final f = await pickImage(ImageSource.gallery);
            if (f != null) setState(() => _photo = f);
          },
          child: Stack(children: [
            _photo != null ? ClipOval(child: Image.memory(_photo!.bytes, width: 96, height: 96, fit: BoxFit.cover)) : UserAvatar(name: p.nama, path: p.fotoProfil, size: 96),
            Positioned(right: 0, bottom: 0, child: Container(width: 32, height: 32, decoration: const BoxDecoration(color: C.primary900, shape: BoxShape.circle), child: const Center(child: AppIcon('camera-plus', size: 16, color: Colors.white)))),
          ]),
        ),
        const SizedBox(height: 24),
        AppTextField(label: 'Full Name', controller: _nama, hint: 'Full name'),
        const SizedBox(height: 16),
        AppTextField(label: 'Phone Number', controller: _phone, hint: '8xx xxxx xxxx', keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Birth of date',
          controller: _birth,
          hint: 'DD/MM/YYYY',
          icon: 'calendar',
          readOnly: true,
          onTap: () async {
            final d = await showDatePicker(context: context, initialDate: _date ?? DateTime(2003, 1, 1), firstDate: DateTime(1950), lastDate: DateTime.now());
            if (d != null) setState(() {
              _date = d;
              _birth.text = Fmt.dateField(d);
            });
          },
        ),
      ]),
    );
  }
}
