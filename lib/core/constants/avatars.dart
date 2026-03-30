/// Predefined emoji avatars for user profiles.
///
/// FUTURE UPGRADE SUGGESTIONS:
/// - DiceBear API (https://api.dicebear.com/7.x/adventurer/svg?seed=email)
///   → Generate unique SVG avatars from email seed. No assets needed.
/// - flutter_avataaar package → Cartoon-style customizable avatars
/// - Custom illustrations → 12-15 themed animals/objects (most premium)
/// - Photo upload → image_picker + Supabase Storage bucket
class Avatars {
  const Avatars._();

  static const List<String> all = [
    '😊', '😎', '🤓', '🧑‍💻', '👩‍🚀', '🦊', '🐱', '🐶',
    '🐼', '🦁', '🐯', '🦄', '🐸', '🐵', '🐻', '🐨',
    '🌟', '🔥', '💎', '🚀', '🎯', '💰', '🏆', '⭐',
    '🌈', '🎨', '🎵', '🌸', '🍀', '❤️', '💜', '🧡',
  ];

  /// Default avatar for new users.
  static const String defaultAvatar = '😊';

  /// Get a deterministic avatar from a user ID (fallback when no avatar is set).
  static String fromUserId(String userId) {
    final index = userId.hashCode.abs() % all.length;
    return all[index];
  }

  /// Categories for the avatar selector UI.
  static const Map<String, List<String>> categories = {
    'Faces': ['😊', '😎', '🤓', '🧑‍💻', '👩‍🚀'],
    'Animals': ['🦊', '🐱', '🐶', '🐼', '🦁', '🐯', '🦄', '🐸', '🐵', '🐻', '🐨'],
    'Objects': ['🌟', '🔥', '💎', '🚀', '🎯', '💰', '🏆', '⭐'],
    'Nature': ['🌈', '🎨', '🎵', '🌸', '🍀', '❤️', '💜', '🧡'],
  };
}
