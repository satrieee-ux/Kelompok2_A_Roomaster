import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text.dart';
import 'app_icon.dart';

class TabItem {
  const TabItem(this.label, {this.icon});
  final String label;
  final String? icon;
}

/// Tab garis bawah (Tab 5 Tabs), item melebar rata.
class LineTabs extends StatelessWidget {
  const LineTabs({super.key, required this.items, required this.active, required this.onTap});
  final List<String> items;
  final int active;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.grey300))),
      child: Row(children: [
        for (var i = 0; i < items.length; i++)
          Expanded(
            child: InkWell(
              onTap: () => onTap(i),
              child: SizedBox(
                height: 40,
                child: Stack(alignment: Alignment.center, children: [
                  Text(items[i], style: T.b4(i == active ? C.grey900 : C.grey400)),
                  if (i == active)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: -1,
                      child: Container(
                        height: 3,
                        decoration: const BoxDecoration(
                          color: C.primary800,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(99)),
                        ),
                      ),
                    ),
                ]),
              ),
            ),
          ),
      ]),
    );
  }
}

/// Tab chip (pill), scroll horizontal, padding kiri 24.
class PillTabs extends StatelessWidget {
  const PillTabs({super.key, required this.items, required this.active, required this.onTap});
  final List<TabItem> items;
  final int active;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final on = i == active;
          final it = items[i];
          return GestureDetector(
            onTap: () => onTap(i),
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: on ? C.primary800 : C.grey200,
                borderRadius: BorderRadius.circular(99),
                boxShadow: on ? const [BoxShadow(color: Color(0x803B7BA0), blurRadius: 12)] : null,
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (it.icon != null) ...[
                  AppIcon(it.icon!, size: 16, color: on ? Colors.white : C.primary500),
                  const SizedBox(width: 6),
                ],
                Text(it.label, style: T.c2(on ? Colors.white : C.primary500)),
              ]),
            ),
          );
        },
      ),
    );
  }
}
