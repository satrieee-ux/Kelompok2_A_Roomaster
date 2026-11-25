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

// ---------------------------------------------------------------------
// Check-in / Check-out
// ---------------------------------------------------------------------
class ConditionForm extends StatelessWidget {
  const ConditionForm({required this.files, required this.onCamera, required this.onGallery, required this.onRemove, required this.notes});
  final List<PickedUpload> files;
  final VoidCallback onCamera, onGallery;
  final void Function(int) onRemove;
  final TextEditingController notes;
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      MediaUploadBox(files: files, onCamera: onCamera, onGallery: onGallery, onRemove: onRemove),
      const SizedBox(height: 16),
      const Divider(color: C.grey300),
      const SizedBox(height: 16),
      const FieldLabel('Additional Notes'),
      const SizedBox(height: 8),
      TextField(
        controller: notes,
        maxLines: 4,
        style: T.b3(),
        decoration: InputDecoration(
          hintText: 'Note any existing damages, odors, or missing items here...',
          hintStyle: T.b3(C.grey400),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: C.grey600)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: C.grey600)),
        ),
      ),
    ]);
  }
}

mixin MediaPicking<W extends ConsumerStatefulWidget> on ConsumerState<W> {
  final files = <PickedUpload>[];
  Future<void> camera() async {
    final f = await pickImage(ImageSource.camera);
    if (f != null) setState(() => files.add(f));
  }

  Future<void> gallery() async {
    final l = await pickGallery();
    if (l.isNotEmpty) setState(() => files.addAll(l));
  }
}
