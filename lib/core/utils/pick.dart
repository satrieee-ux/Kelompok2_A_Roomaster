import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import '../widgets/misc.dart';

String _mime(String name, List<int> bytes) => lookupMimeType(name, headerBytes: bytes.length > 16 ? bytes.sublist(0, 16) : bytes) ?? 'application/octet-stream';

Future<PickedUpload?> pickImage(ImageSource source) async {
  final x = await ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 2000);
  if (x == null) return null;
  final b = await x.readAsBytes();
  return PickedUpload(name: x.name, bytes: b, mime: _mime(x.name, b));
}

Future<List<PickedUpload>> pickGallery({bool video = false}) async {
  final out = <PickedUpload>[];
  if (video) {
    final x = await ImagePicker().pickMedia();
    if (x != null) {
      final b = await x.readAsBytes();
      out.add(PickedUpload(name: x.name, bytes: b, mime: _mime(x.name, b)));
    }
    return out;
  }
  final xs = await ImagePicker().pickMultiImage(imageQuality: 85, maxWidth: 2000);
  for (final x in xs) {
    final b = await x.readAsBytes();
    out.add(PickedUpload(name: x.name, bytes: b, mime: _mime(x.name, b)));
  }
  return out;
}

/// Dokumen: pdf/jpg/png, maks 10 MB.
Future<PickedUpload?> pickDocument() async {
  final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'], withData: true);
  if (r == null || r.files.isEmpty) return null;
  final f = r.files.first;
  final b = f.bytes;
  if (b == null) return null;
  if (b.length > 10 * 1024 * 1024) throw Exception('Ukuran berkas maksimal 10 MB.');
  return PickedUpload(name: f.name, bytes: b, mime: _mime(f.name, b));
}
