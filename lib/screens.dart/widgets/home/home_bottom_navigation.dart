import 'package:flutter/material.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({
    super.key,
    required this.isDark,
    required this.currentTab,
    required this.onTabChanged,
  });

  final bool isDark;
  final int currentTab;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String)>[
      (Icons.space_dashboard_rounded, 'Dashboard'),
      (Icons.timeline_rounded, 'Activity'),
      (Icons.flag_rounded, 'Goals'),
      (Icons.savings_rounded, 'Savings'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isDark
              ? Colors.black.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.95),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: List<Widget>.generate(items.length, (index) {
            final item = items[index];
            final selected = currentTab == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTabChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: selected
                        ? (isDark
                              ? const Color(0xFF36FFE9).withValues(alpha: 0.2)
                              : const Color(0xFF2B6EF7).withValues(alpha: 0.14))
                        : Colors.transparent,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AnimatedScale(
                        duration: const Duration(milliseconds: 220),
                        scale: selected ? 1.12 : 1,
                        child: Icon(
                          item.$1,
                          color: selected
                              ? (isDark
                                    ? const Color(0xFF36FFE9)
                                    : const Color(0xFF2B6EF7))
                              : (isDark
                                    ? const Color(0xFFA1BCD5)
                                    : const Color(0xFF6A81AA)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 220),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected
                              ? (isDark
                                    ? const Color(0xFF36FFE9)
                                    : const Color(0xFF2B6EF7))
                              : (isDark
                                    ? const Color(0xFFA1BCD5)
                                    : const Color(0xFF6A81AA)),
                        ),
                        child: Text(item.$2),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
