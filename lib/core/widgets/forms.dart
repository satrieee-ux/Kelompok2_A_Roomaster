import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text.dart';
import '../utils/format.dart';
import 'app_icon.dart';
import 'misc.dart';

/// Kolom input berlabel (Login / Sign Up / MyITS). type password otomatis punya tombol mata.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.controller,
    this.hint = '',
    this.obscure = false,
    this.keyboardType,
    this.icon,
    this.prefix,
    this.onIconTap,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.textInputAction,
    this.onSubmitted,
  });
  final String? label;
  final TextEditingController? controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? icon;
  final Widget? prefix;
  final VoidCallback? onIconTap;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hide = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (widget.label != null) ...[
        Text(widget.label!, style: T.b3(C.grey500)),
        const SizedBox(height: 4),
      ],
      Container(
        constraints: const BoxConstraints(minHeight: 46),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: C.grey50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: C.grey100),
          boxShadow: const [BoxShadow(color: Color(0x0F141A28), blurRadius: 2, offset: Offset(0, 1))],
        ),
        child: Row(children: [
          if (widget.prefix != null) ...[widget.prefix!, const SizedBox(width: 12)],
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              obscureText: _hide,
              keyboardType: widget.keyboardType,
              readOnly: widget.readOnly,
              onTap: widget.onTap,
              validator: widget.validator,
              textInputAction: widget.textInputAction,
              onFieldSubmitted: widget.onSubmitted,
              style: T.b3m(C.grey800),
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
                border: InputBorder.none,
                errorStyle: T.c1(C.danger500),
                hintText: widget.hint,
                hintStyle: T.b3m(C.grey500),
              ),
            ),
          ),
          if (widget.obscure)
            GestureDetector(
              onTap: () => setState(() => _hide = !_hide),
              child: AppIcon(_hide ? 'eye-off' : 'eye', size: 20, color: C.grey500),
            )
          else if (widget.icon != null)
            GestureDetector(onTap: widget.onIconTap, child: AppIcon(widget.icon!, size: 20, color: C.grey500)),
        ]),
      ),
    ]);
  }
}

/// Label tebal 14 untuk form booking / laporan.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(text, style: T.b4());
}

BoxDecoration fieldBox() => BoxDecoration(
      color: C.grey50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: C.grey200),
      boxShadow: const [BoxShadow(color: Color(0x0A141A28), blurRadius: 2, offset: Offset(0, 1))],
    );

/// Input satu baris (h42) atau area teks, gaya form booking.
class BoxInput extends StatelessWidget {
  const BoxInput({super.key, required this.controller, required this.hint, this.height = 42, this.maxLines = 1, this.onChanged});
  final TextEditingController controller;
  final String hint;
  final double height;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: maxLines > 1 ? 12 : 0),
      alignment: maxLines > 1 ? Alignment.topLeft : Alignment.centerLeft,
      decoration: fieldBox(),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: maxLines,
        style: T.b3(C.grey800),
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: T.b3(C.grey500),
        ),
      ),
    );
  }
}

/// Tombol berbentuk kolom (tanggal / waktu): ikon + teks.
class PickerField extends StatelessWidget {
  const PickerField({super.key, required this.icon, required this.text, required this.placeholder, required this.onTap});
  final String icon;
  final String? text;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: fieldBox(),
        child: Row(children: [
          AppIcon(icon, color: C.grey500),
          const SizedBox(width: 12),
          Text(text ?? placeholder, style: T.b1(text == null ? C.grey500 : C.grey800)),
        ]),
      ),
    );
  }
}

/// Dropdown gaya Roomaster.
class AppDropdown extends StatelessWidget {
  const AppDropdown({super.key, required this.value, required this.items, required this.onChanged, this.hint = 'Select'});
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: fieldBox(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          isExpanded: true,
          hint: Text(hint, style: T.b1(C.grey800)),
          icon: const AppIcon('chevron-down', color: C.grey500),
          borderRadius: BorderRadius.circular(12),
          dropdownColor: Colors.white,
          style: T.b3m(C.grey800),
          items: [
            for (final e in items)
              DropdownMenuItem(value: e, child: Text(e, style: T.b3m(C.grey800), overflow: TextOverflow.ellipsis)),
          ],
          selectedItemBuilder: (_) => [
            for (final e in items) Align(alignment: Alignment.centerLeft, child: Text(e, style: T.b1(C.grey800), overflow: TextOverflow.ellipsis)),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Checkbox kotak 24. side right = kotak di kanan (checklist).
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({super.key, required this.checked, required this.onChanged, required this.label, this.rightSide = false, this.muted = false});
  final bool checked;
  final ValueChanged<bool> onChanged;
  final String label;
  final bool rightSide;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: checked ? C.primary500 : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: C.primary500, width: 1.5),
      ),
      child: checked ? const Center(child: AppIcon('check', size: 16, color: Colors.white, stroke: 3)) : null,
    );
    final text = Text(label, style: muted ? T.b3(C.grey600) : T.b3m(C.grey800));
    return GestureDetector(
      onTap: () => onChanged(!checked),
      behavior: HitTestBehavior.opaque,
      child: rightSide
          ? Row(children: [Expanded(child: text), box])
          : Row(children: [box, const SizedBox(width: 16), Expanded(child: text)]),
    );
  }
}

/// Chip pilihan (kategori laporan, tipe ruangan).
class ChoicePill extends StatelessWidget {
  const ChoicePill({super.key, required this.label, required this.selected, required this.onTap, this.icon, this.height = 32, this.expand = false});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? icon;
  final double height;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : C.primary500;
    final pill = Container(
      height: height,
      padding: EdgeInsets.only(left: icon != null ? 12 : 16, right: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: selected ? C.primary800 : C.grey200, borderRadius: BorderRadius.circular(99)),
      child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
        if (icon != null) ...[AppIcon(icon!, color: fg), const SizedBox(width: 8)],
        Text(label, style: T.c2(fg)),
      ]),
    );
    return GestureDetector(onTap: onTap, child: expand ? SizedBox(width: double.infinity, child: pill) : pill);
  }
}

/// Kartu berkas terunggah.
class FileCard extends StatelessWidget {
  const FileCard({super.key, required this.name, required this.size, this.onRemove, this.compact = false});
  final String name;
  final String size;
  final VoidCallback? onRemove;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: C.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.grey300),
      ),
      child: Row(children: [
        Container(
          width: compact ? 48 : 40,
          height: compact ? 48 : 40,
          decoration: BoxDecoration(color: C.grey100, borderRadius: BorderRadius.circular(8), border: Border.all(color: C.grey300)),
          child: Center(child: AppIcon('file-text', size: compact ? 24 : 20, color: C.grey600)),
        ),
        SizedBox(width: compact ? 12 : 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: T.b3m(), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('$size • Upload complete', style: T.c2(C.grey500)),
          ]),
        ),
        if (onRemove != null) GestureDetector(onTap: onRemove, child: const AppIcon('trash-2', size: 20, color: C.grey800)),
      ]),
    );
  }
}

/// Slot unggah dokumen: kotak "Upload File" atau kartu berkas.
class DocSlot extends StatelessWidget {
  const DocSlot({super.key, required this.label, this.fileName, this.fileSize, required this.onUpload, this.onRemove, this.busy = false});
  final String label;
  final String? fileName;
  final int? fileSize;
  final VoidCallback onUpload;
  final VoidCallback? onRemove;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: T.b4()),
      const SizedBox(height: 10),
      if (fileName == null)
        GestureDetector(
          onTap: busy ? null : onUpload,
          child: Container(
            height: 46,
            decoration: BoxDecoration(color: C.grey50, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.grey200)),
            child: Center(
              child: busy
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: C.primary500))
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      const AppIcon('upload', size: 20, color: C.grey500),
                      const SizedBox(width: 8),
                      Text('Upload File', style: x500()),
                    ]),
            ),
          ),
        )
      else
        FileCard(name: fileName!, size: Fmt.fileSize(fileSize ?? 0), onRemove: onRemove),
    ]);
  }

  TextStyle x500() => T.x(16, 24, FontWeight.w500, C.grey500);
}

/// Area foto: kartu kamera 320 + deretan thumbnail + tombol tambah (Check-In / Check-Out).
class MediaUploadBox extends StatelessWidget {
  const MediaUploadBox({super.key, required this.files, required this.onCamera, required this.onGallery, required this.onRemove});
  final List<PickedUpload> files;
  final VoidCallback onCamera, onGallery;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: onCamera,
        child: Container(
          height: 320,
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: C.shadowCard),
          clipBehavior: Clip.antiAlias,
          child: Stack(fit: StackFit.expand, children: [
            CustomPaint(painter: _CrossPainter()),
            if (files.isNotEmpty)
              Image.memory(files.first.bytes, fit: BoxFit.cover)
            else
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const AppIcon('camera-plus', size: 40, color: C.grey600),
                const SizedBox(height: 8),
                Text('Tap to activate camera or select media', style: T.b3m(C.grey600)),
              ]),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      Wrap(spacing: 12, runSpacing: 12, children: [
        for (var i = 0; i < files.length; i++)
          Stack(clipBehavior: Clip.none, children: [
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.memory(files[i].bytes, width: 96, height: 96, fit: BoxFit.cover)),
            Positioned(
              top: -6,
              right: -6,
              child: GestureDetector(
                onTap: () => onRemove(i),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(color: C.grey800, shape: BoxShape.circle),
                  child: const Center(child: AppIcon('x', size: 14, color: Colors.white)),
                ),
              ),
            ),
          ]),
        if (files.isEmpty)
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: C.grey400)),
            child: const Center(child: AppIcon('image', size: 20, color: C.grey400)),
          ),
        GestureDetector(
          onTap: onGallery,
          child: SizedBox(
            width: 96,
            height: 96,
            child: DashedBorder(
              fill: C.grey100,
              child: const Center(child: AppIcon('plus', size: 20, color: C.grey500)),
            ),
          ),
        ),
      ]),
    ]);
  }
}

class _CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = C.grey200
      ..strokeWidth = 1;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), p);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
