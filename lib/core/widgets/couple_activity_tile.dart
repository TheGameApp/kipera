import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../extensions/context_extensions.dart';
import 'currency_text.dart';
import 'user_avatar.dart';

/// Activity tile for couple goals that shows which partner made each check-in.
/// Displays the user avatar, name, amount, and date with visual distinction
/// between the current user (green accent) and the partner (pink accent).
class CoupleActivityTile extends StatelessWidget {
  final String emoji;
  final String displayName;
  final double amount;
  final DateTime date;
  final bool isCurrentUser;

  const CoupleActivityTile({
    super.key,
    required this.emoji,
    required this.displayName,
    required this.amount,
    required this.date,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final accentColor = isCurrentUser
        ? AppColors.primary
        : AppColors.pink;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: accentColor, width: 3),
        ),
      ),
      child: Row(
        children: [
          UserAvatar(
            emoji: emoji,
            size: 32,
            borderColor: isCurrentUser ? null : AppColors.pink,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCurrentUser ? context.l10n.userLabel : displayName,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCurrentUser ? null : AppColors.pink,
                  ),
                ),
                Text(
                  _formatDate(context, date),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          CurrencyText(
            amount: amount,
            prefix: '+',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return context.l10n.todayLabel;
    if (dateOnly == today.subtract(const Duration(days: 1))) {
      return context.l10n.yesterdayLabel;
    }

    return DateFormat.MMMd(context.l10n.localeName).format(date);
  }
}
