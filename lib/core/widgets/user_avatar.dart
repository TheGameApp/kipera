import 'package:flutter/material.dart';
import '../constants/avatars.dart';
import '../constants/app_colors.dart';
import '../extensions/context_extensions.dart';

/// Reusable avatar widget that displays a user's emoji avatar
/// inside a styled circular container.
class UserAvatar extends StatelessWidget {
  /// The emoji string to display. If null, falls back to [Avatars.defaultAvatar].
  final String? emoji;

  /// Size of the avatar circle.
  final double size;

  /// Optional border color (e.g., pink for partner, default for current user).
  final Color? borderColor;

  /// Optional tap callback (for avatar selector).
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.emoji,
    this.size = 40,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final displayEmoji = emoji ?? Avatars.defaultAvatar;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? AppColors.surfaceDark
              : AppColors.inputBgLight,
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 2)
              : Border.all(
                  color: isDark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
                  width: 1,
                ),
        ),
        child: Center(
          child: Text(
            displayEmoji,
            style: TextStyle(fontSize: size * 0.5),
          ),
        ),
      ),
    );
  }
}

/// Stacked avatars for couple goals (user overlapping partner).
class CoupleAvatarStack extends StatelessWidget {
  final String? userEmoji;
  final String? partnerEmoji;
  final double size;

  const CoupleAvatarStack({
    super.key,
    this.userEmoji,
    this.partnerEmoji,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.6,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: UserAvatar(
              emoji: userEmoji,
              size: size,
            ),
          ),
          Positioned(
            left: size * 0.6,
            child: UserAvatar(
              emoji: partnerEmoji,
              size: size,
              borderColor: AppColors.pink,
            ),
          ),
        ],
      ),
    );
  }
}
