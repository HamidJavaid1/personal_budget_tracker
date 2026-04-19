import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LimitReachNotification extends StatelessWidget {
  const LimitReachNotification({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.accentColor,
  });

  factory LimitReachNotification.goalReached({
    Key? key,
    required String goalTitle,
    required double savedAmount,
    required double targetAmount,
    required String Function(double amount) moneyFormatter,
  }) {
    return LimitReachNotification(
      key: key,
      title: 'Goal reached: $goalTitle',
      message:
          'You saved ${moneyFormatter(savedAmount)} out of ${moneyFormatter(targetAmount)}. Open this goal to review it.',
      icon: Icons.celebration_rounded,
      accentColor: const Color(0xFF2B6EF7),
    );
  }

  factory LimitReachNotification.budgetExceeded({
    Key? key,
    required String category,
    required String overBy,
  }) {
    return LimitReachNotification(
      key: key,
      title: '$category limit reached',
      message:
          'You are over budget by $overBy. Check Budget Goals to rebalance.',
      icon: Icons.warning_amber_rounded,
      accentColor: const Color(0xFFFF5A3D),
    );
  }

  final String title;
  final String message;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bodyColor = isDark
        ? const Color(0xFFBDE6FF)
        : const Color(0xFF48688F);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? <Color>[const Color(0xFF142A4E), const Color(0xFF0F213E)]
              : <Color>[const Color(0xFFF2F8FF), const Color(0xFFE7F2FF)],
        ),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.9 : 0.8),
          width: 1.2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: isDark ? 0.24 : 0.16),
              border: Border.all(
                color: accentColor.withValues(alpha: isDark ? 0.8 : 0.6),
              ),
            ),
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFFEAF8FF)
                        : const Color(0xFF0E2453),
                  ),
                ),
                const SizedBox(height: 3),
                Text(message, style: TextStyle(color: bodyColor, height: 1.25)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
