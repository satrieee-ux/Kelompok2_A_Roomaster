// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/nav.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/bars.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/headers.dart';
import '../../core/widgets/misc.dart';
import '../../core/widgets/page.dart';
import '../../core/widgets/popups.dart';
import '../../core/widgets/tabs.dart';
import '../../data/models.dart';
import '../../data/room_providers.dart';
import 'room_section.dart';

// ---------------------------------------------------------------------
// Search (Melakukan Search + Melihat Hasil Search)
// ---------------------------------------------------------------------
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchState();
}

class _SearchState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  String _q = '';
  FilterResult _filter = const FilterResult();
  DateTime? _date;
  Set<int>? _availableIds;
  List<int> _recentIds = [];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((sp) {
      if (mounted) setState(() => _recentIds = (sp.getStringList('recent_rooms') ?? []).map(int.parse).toList());
    });
  }

  bool get _hasResults => _q.isNotEmpty || _filter.category != null || _filter.minCapacity != null || _filter.facilities.isNotEmpty || _date != null;

  Future<void> _openFilter(List<Room> all) async {
    final facs = <String>{for (final r in all) ...r.fasilitas.map((f) => f.nama)}.toList()..sort();
    final res = await showFilterSheet(context, initial: _filter, categories: kCategoryLabels, facilityNames: facs);
    if (res != null) setState(() => _filter = res);
  }

  Future<void> _openDate() async {
    final d = await showDateSheet(context, initial: _date);
    if (d == null) return;
    try {
      final ids = await ref.read(roomRepoP).availableOn(d);
      setState(() {
        _date = d;
        _availableIds = ids;
      });
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e));
    }
  }

  List<SearchChip> _chips() => [
        if (_date != null) SearchChip(icon: 'calendar', label: Fmt.dateShort(_date!)),
        if (_filter.minCapacity != null) SearchChip(icon: 'users', label: '${_filter.minCapacity}+'),
        if (_filter.category != null) SearchChip(label: kCategoryLabels[_filter.category] ?? _filter.category),
        for (final f in _filter.facilities) SearchChip(label: f),
        if (_hasResults) const SearchChip(icon: 'x'),
      ];

  void _chipTap(int i) {
    final chips = _chips();
    if (chips[i].icon == 'x' && chips[i].label == null) {
      setState(() {
        _q = '';
        _ctrl.clear();
        _filter = const FilterResult();
        _date = null;
        _availableIds = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsP);
    return PageShell(
      header: SearchHeader(
        onBack: () => goBack(context, '/rooms'),
        onFilter: () => _openFilter(roomsAsync.valueOrNull ?? []),
        onDate: _openDate,
        controller: _ctrl,
        onSubmitted: (v) => setState(() => _q = v.trim()),
        chips: _chips(),
        onChipTap: _chipTap,
        autofocus: !_hasResults,
      ),
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: roomsAsync.when(
        loading: () => const LoadingBox(),
        error: (e, _) => ErrorBox(e, onRetry: () => ref.invalidate(roomsP)),
        data: (all) {
          if (!_hasResults) {
            final recent = [for (final id in _recentIds) ...all.where((r) => r.id == id)];
            final forYou = [...all]..sort((a, b) => b.ratingRata.compareTo(a.ratingRata));
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              RoomSection(title: 'Recently Searched', rooms: recent),
              RoomSection(title: 'For You', layout: 'list', rooms: forYou.take(8).toList()),
            ]);
          }
          final q = _q.toLowerCase();
          final res = all.where((r) {
            if (q.isNotEmpty && !('${r.nama} ${r.kode} ${r.departemen ?? ''} ${r.lokasi ?? ''}').toLowerCase().contains(q)) return false;
            if (_filter.category != null && r.kategori != _filter.category) return false;
            if (_filter.minCapacity != null && r.kapasitas < _filter.minCapacity!) return false;
            if (_filter.facilities.isNotEmpty && !_filter.facilities.every((f) => r.fasilitas.any((x) => x.nama == f))) return false;
            if (_availableIds != null && !_availableIds!.contains(r.id)) return false;
            return true;
          }).toList();
          final more = all.where((r) => !res.contains(r)).toList()..sort((a, b) => b.ratingRata.compareTo(a.ratingRata));
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            res.isEmpty ? const Padding(padding: EdgeInsets.only(bottom: 16), child: EmptyText('No rooms match your search.')) : RoomSection(title: 'Search Results', layout: 'stack', rooms: res),
            RoomSection(title: 'More For You', rooms: more.take(6).toList()),
          ]);
        },
      ),
    );
  }
}
