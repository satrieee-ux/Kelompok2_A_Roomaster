import 'package:intl/intl.dart';

/// Format tanggal/jam yang dipakai di UI (gaya Inggris seperti di Blade).
class Fmt {
  Fmt._();

  static DateTime parseDate(String s) {
    final p = s.substring(0, 10).split('-');
    return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }

  static String isoDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  /// "6 July 2026"
  static String dateLong(DateTime d) => DateFormat('d MMMM y').format(d);

  /// "24 Okt 2023" (gaya riwayat laporan)
  static String dateShort(DateTime d) => DateFormat('d MMM y').format(d);

  /// "DD/MM/YY"
  static String dateField(DateTime d) => DateFormat('dd/MM/yy').format(d);

  /// "09:00" dari "09:00:00"
  static String hm(String t) => t.length >= 5 ? t.substring(0, 5) : t;

  /// "08.00-16.00 WIB"
  static String rangeWib(String a, String b) => '${hm(a).replaceAll(':', '.')}-${hm(b).replaceAll(':', '.')} WIB';

  /// "09.00 - 12.00 (3 Hours)"
  static String rangeHours(String a, String b) {
    final h = _minutes(b) - _minutes(a);
    final jam = h / 60;
    final label = jam == jam.roundToDouble() ? '${jam.round()}' : jam.toStringAsFixed(1);
    return '${hm(a).replaceAll(':', '.')} - ${hm(b).replaceAll(':', '.')} ($label ${jam == 1 ? 'Hour' : 'Hours'})';
  }

  static int _minutes(String t) {
    final p = t.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  /// "10:45 AM"
  static String clock(DateTime d) => DateFormat('hh:mm a').format(d.toLocal());

  /// "Monday, Oct 23"
  static String chatDay(DateTime d) => DateFormat('EEEE, MMM d').format(d.toLocal());

  /// "2 mins ago", "3 hours ago", "1 day ago"
  static String ago(DateTime d) {
    final diff = DateTime.now().difference(d.toLocal());
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} ${diff.inMinutes == 1 ? 'min' : 'mins'} ago';
    if (diff.inHours < 24) return '${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'} ago';
    return '${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'} ago';
  }

  /// "2h ago" (banner status)
  static String agoShort(DateTime d) {
    final diff = DateTime.now().difference(d.toLocal());
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  static String fileSize(int bytes) {
    if (bytes >= 1048576) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '$bytes B';
  }

  /// "Up to 50 Person (M)"
  static String capacityLong(int n) {
    final s = n <= 20 ? 'S' : (n <= 50 ? 'M' : (n <= 100 ? 'L' : 'XL'));
    return 'Up to $n Person ($s)';
  }

  /// "20 Orang"
  static String capacityShort(int n) => '$n Orang';

}
