/// A score-based achievement badge.
///
/// Named `ScoreBadge` (rather than `Badge`) to avoid clashing with
/// Flutter's own `material.Badge` widget.
class ScoreBadge {
  const ScoreBadge({
    required this.threshold,
    required this.emoji,
    required this.label,
  });

  final int threshold;
  final String emoji;
  final String label;
}

/// Badges unlock permanently (across runs) the first time the player's
/// score crosses each threshold.
const List<ScoreBadge> kBadges = [
  ScoreBadge(threshold: 50, emoji: '🥉', label: 'Bronze Jumper'),
  ScoreBadge(threshold: 150, emoji: '🥈', label: 'Silver Soarer'),
  ScoreBadge(threshold: 300, emoji: '🥇', label: 'Gold Bouncer'),
  ScoreBadge(threshold: 500, emoji: '💎', label: 'Diamond Climber'),
  ScoreBadge(threshold: 1000, emoji: '👑', label: 'Sky Legend'),
];
