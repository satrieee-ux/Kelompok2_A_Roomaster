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
import '../../data/refresh_all.dart';

Widget profileNavBar(BuildContext context, String peran, String active) {
  if (peran == 'tu') return StaffNavBar(items: StaffNavBar.tu, active: active, onSelect: (k) => goTuNav(context, k));
  if (peran == 'sarpras') return StaffNavBar(items: StaffNavBar.sarpras, active: active, onSelect: (k) => goSarprasNav(context, k));
  return RoomasterNavBar(active: 'profile', onSelect: (k) => goStudentNav(context, k));
}

Future<void> confirmLogout(BuildContext context, WidgetRef ref) async {
  final ok = await showConfirmDialog(context, title: 'Log Out?', message: 'You will need to sign in again to use Roomaster.', confirmLabel: 'Log Out', cancelLabel: 'Cancel', icon: 'log-out', danger: true, iconBg: C.danger100, iconColor: C.danger500);
  if (!ok) return;
  await ref.read(authRepoP).signOut();
  refreshAll(ref);
  if (context.mounted) context.go('/');
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(profileP);
    final stats = ref.watch(profileStatsP).valueOrNull ?? const <String, int>{};
    return async.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: ErrorBox(e, onRetry: () => ref.invalidate(profileP)))),
      data: (p) {
        if (p == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final id = p.nrp ?? p.nip;
        return PageShell(
          header: TopAppBar(title: 'Profile', onBack: () => context.go('/menu-utama'), endIcon: 'log-out', onEnd: () => confirmLogout(context, ref)),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          onRefresh: () async {
            ref.invalidate(profileP);
            ref.invalidate(profileStatsP);
          },
          bottom: profileNavBar(context, p.peran, 'profile'),
          child: Column(children: [
            UserAvatar(name: p.nama, path: p.fotoProfil, size: 96, online: true, ringColor: C.grey100),
            const SizedBox(height: 12),
            Text(p.nama, style: T.s1(), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: C.primary50, borderRadius: BorderRadius.circular(999)),
              child: Text(p.peranLabel, style: T.c2(C.primary500)),
            ),
            const SizedBox(height: 20),
            if (stats.isNotEmpty)
              Row(children: [
                for (final e in stats.entries)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(color: C.grey50, borderRadius: BorderRadius.circular(12), boxShadow: C.shadowCard),
                      child: Column(children: [Text('${e.value}', style: T.s1()), Text(e.key, style: T.c2(C.grey500))]),
                    ),
                  ),
              ]),
            const SizedBox(height: 20),
            _Card(children: [
              _Info('mail', 'Email', p.email),
              if (id != null) _Info('badge-check', p.nrp != null ? 'NRP' : 'NIP', id),
              _Info('phone', 'Phone Number', p.noTelepon ?? '-'),
              if (p.tanggalLahir != null) _Info('calendar', 'Birth of date', Fmt.dateLong(p.tanggalLahir!)),
            ]),
            const SizedBox(height: 16),
            if (!p.isStaf)
              _Card(children: [
                _Link('heart', 'Favorite Rooms', () => context.go('/rooms')),
                _Link('calendar-check', 'My Bookings', () => context.go('/bookings')),
                _Link('history', 'Report History', () => context.push('/qreporting/history')),
              ]),
            if (p.peran == 'tu') _Card(children: [_Link('star', 'Room Ratings', () => context.go('/tu/ratings')), _Link('message-square', 'Chats', () => context.push('/chat'))]),
            if (p.peran == 'sarpras') _Card(children: [_Link('history', 'Report History', () => context.go('/sarpras/history'))]),
            const SizedBox(height: 16),
            _Card(children: [
              _Link('pencil', 'Edit Profile', () => context.push('/profile/edit')),
              _Link('lock', 'Change Password', () => showChangePassword(context, ref)),
            ]),
            const SizedBox(height: 24),
            AppButton('Log Out', onPressed: () => confirmLogout(context, ref), variant: BtnVariant.outline, iconLeft: 'log-out', expand: true),
          ]),
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 0),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: C.grey50, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.grey200)),
        child: Column(children: [
          for (var i = 0; i < children.length; i++) ...[if (i > 0) const Divider(height: 1, color: C.grey200), children[i]],
        ]),
      );
}

class _Info extends StatelessWidget {
  const _Info(this.icon, this.k, this.v);
  final String icon, k, v;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          AppIcon(icon, size: 20, color: C.grey500),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(k, style: T.c2(C.grey500)), Text(v, style: T.b3m())])),
        ]),
      );
}

class _Link extends StatelessWidget {
  const _Link(this.icon, this.label, this.onTap);
  final String icon, label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(children: [
            AppIcon(icon, size: 20, color: C.primary500),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: T.b3m())),
            const AppIcon('chevron-right', size: 20, color: C.grey400),
          ]),
        ),
      );
}

Future<void> showChangePassword(BuildContext context, WidgetRef ref) async {
  final a = TextEditingController(), b = TextEditingController();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Change Password', style: T.s1()),
        const SizedBox(height: 16),
        AppTextField(label: 'New Password', controller: a, hint: 'Min. 6 characters', obscure: true),
        const SizedBox(height: 12),
        AppTextField(label: 'Confirm Password', controller: b, hint: 'Repeat password', obscure: true),
        const SizedBox(height: 20),
        AppButton('Save', expand: true, onPressed: () async {
          if (a.text.length < 6 || a.text != b.text) {
            showSnack(ctx, 'Password minimal 6 karakter dan harus sama.');
            return;
          }
          try {
            await ref.read(authRepoP).changePassword(a.text);
            if (ctx.mounted) Navigator.pop(ctx);
            if (context.mounted) showSnack(context, 'Password diperbarui.');
          } catch (e) {
            if (ctx.mounted) showSnack(ctx, friendlyError(e));
          }
        }),
      ]),
    ),
  );
}
