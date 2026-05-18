enum MilestoneStatus { notStarted, inProgress, achieved }

enum MilestoneCategory {
  grossMotor,
  fineMotor,
  language,
  cognitive,
  social,
  feedingSleep,
}

extension MilestoneCategoryExt on MilestoneCategory {
  String get label {
    switch (this) {
      case MilestoneCategory.grossMotor:    return 'Gross Motor';
      case MilestoneCategory.fineMotor:     return 'Fine Motor';
      case MilestoneCategory.language:      return 'Language';
      case MilestoneCategory.cognitive:     return 'Cognitive';
      case MilestoneCategory.social:        return 'Social';
      case MilestoneCategory.feedingSleep:  return 'Feeding & Sleep';
    }
  }

  String get emoji {
    switch (this) {
      case MilestoneCategory.grossMotor:    return '🏃';
      case MilestoneCategory.fineMotor:     return '✋';
      case MilestoneCategory.language:      return '💬';
      case MilestoneCategory.cognitive:     return '🧠';
      case MilestoneCategory.social:        return '💗';
      case MilestoneCategory.feedingSleep:  return '🍼';
    }
  }

  String get description {
    switch (this) {
      case MilestoneCategory.grossMotor:    return 'Physical development and movement milestones.';
      case MilestoneCategory.fineMotor:     return 'Hand, finger and eye-hand coordination.';
      case MilestoneCategory.language:      return 'Communication, speech and understanding.';
      case MilestoneCategory.cognitive:     return 'Thinking, learning and problem-solving.';
      case MilestoneCategory.social:        return 'Social bonding and emotional growth.';
      case MilestoneCategory.feedingSleep:  return 'Feeding patterns, sleep routines and self-regulation.';
    }
  }
}

// ── Age band ──────────────────────────────────────────────────────────────────

class AgeBand {
  final int index;
  final String label;       // e.g. "0-1 Weeks"
  final String shortLabel;  // e.g. "0-1w"
  final String emoji;
  final int minDays;
  final int maxDays;

  const AgeBand({
    required this.index,
    required this.label,
    required this.shortLabel,
    required this.emoji,
    required this.minDays,
    required this.maxDays,
  });

  bool containsDays(int days) => days >= minDays && days <= maxDays;
}

const List<AgeBand> ageBands = [
  AgeBand(index: 0,  label: '0-1 Weeks',    shortLabel: '0-1w',   emoji: '🌱', minDays: 0,   maxDays: 6),
  AgeBand(index: 1,  label: '1-2 Weeks',    shortLabel: '1-2w',   emoji: '🌱', minDays: 7,   maxDays: 13),
  AgeBand(index: 2,  label: '2-3 Weeks',    shortLabel: '2-3w',   emoji: '🌱', minDays: 14,  maxDays: 20),
  AgeBand(index: 3,  label: '3-4 Weeks',    shortLabel: '3-4w',   emoji: '🌱', minDays: 21,  maxDays: 27),
  AgeBand(index: 4,  label: '4-6 Weeks',    shortLabel: '4-6w',   emoji: '🍼', minDays: 28,  maxDays: 41),
  AgeBand(index: 5,  label: '6-8 Weeks',    shortLabel: '6-8w',   emoji: '🍼', minDays: 42,  maxDays: 55),
  AgeBand(index: 6,  label: '2-3 Months',   shortLabel: '2-3m',   emoji: '🧸', minDays: 56,  maxDays: 89),
  AgeBand(index: 7,  label: '3-4 Months',   shortLabel: '3-4m',   emoji: '🧸', minDays: 90,  maxDays: 119),
  AgeBand(index: 8,  label: '4-5 Months',   shortLabel: '4-5m',   emoji: '🌟', minDays: 120, maxDays: 149),
  AgeBand(index: 9,  label: '5-6 Months',   shortLabel: '5-6m',   emoji: '🌟', minDays: 150, maxDays: 179),
  AgeBand(index: 10, label: '6-9 Months',   shortLabel: '6-9m',   emoji: '🎀', minDays: 180, maxDays: 272),
  AgeBand(index: 11, label: '9-12 Months',  shortLabel: '9-12m',  emoji: '🎀', minDays: 273, maxDays: 364),
  AgeBand(index: 12, label: '1-1.5 Years',  shortLabel: '1-1.5y', emoji: '🚶', minDays: 365, maxDays: 547),
  AgeBand(index: 13, label: '1.5-2 Years',  shortLabel: '1.5-2y', emoji: '🚶', minDays: 548, maxDays: 729),
  AgeBand(index: 14, label: '2-2.5 Years',  shortLabel: '2-2.5y', emoji: '🏃', minDays: 730, maxDays: 912),
  AgeBand(index: 15, label: '2.5-3 Years',  shortLabel: '2.5-3y', emoji: '🏃', minDays: 913, maxDays: 1094),
  AgeBand(index: 16, label: '3-4 Years',    shortLabel: '3-4y',   emoji: '🎨', minDays: 1095, maxDays: 1459),
  AgeBand(index: 17, label: '4-5 Years',    shortLabel: '4-5y',   emoji: '🎨', minDays: 1460, maxDays: 1824),
  AgeBand(index: 18, label: '5-6 Years',    shortLabel: '5-6y',   emoji: '📚', minDays: 1825, maxDays: 2189),
];

/// Returns the age band index for a baby of [ageInMonths].
/// Uses days-based lookup for precision — avoids month rounding errors.
int ageBandFromMonths(int months) {
  // Convert months to approximate days (30 days/month)
  // For exact matching, prefer ageBandFromDays when birthDate is available
  final days = months * 30;
  for (final band in ageBands) {
    if (band.containsDays(days)) return band.index;
  }
  return ageBands.length - 1;
}

/// Returns the age band index for a baby born [days] ago.
/// More precise than ageBandFromMonths.
int ageBandFromDays(int days) {
  for (final band in ageBands) {
    if (band.containsDays(days)) return band.index;
  }
  return ageBands.length - 1;
}

// ── Rich content models ───────────────────────────────────────────────────────

class MilestoneActivity {
  final String title;
  final String description;
  final String emoji;
  final List<String> steps;
  final String? filter;

  const MilestoneActivity({
    required this.title,
    required this.description,
    required this.emoji,
    required this.steps,
    this.filter,
  });
}

class MilestoneSign {
  final String title;
  final String description;
  final bool isPositive;

  const MilestoneSign({
    required this.title,
    required this.description,
    required this.isPositive,
  });
}

class MilestoneWarning {
  final String title;
  final String description;
  final String emoji;

  const MilestoneWarning({
    required this.title,
    required this.description,
    required this.emoji,
  });
}

class CommonConcern {
  final String question;
  final String answer;

  const CommonConcern({required this.question, required this.answer});
}

// ── Milestone item (individual checklist entry) ───────────────────────────────

class MilestoneItem {
  final String id;
  final String title;
  final String description;
  final MilestoneCategory category;
  final MilestoneStatus status;
  final String? achievedDate;
  final String ageRange;
  final List<MilestoneActivity> activities;
  final List<MilestoneSign> signsToLookFor;
  final List<MilestoneSign> watchSigns;
  final List<MilestoneWarning> warnings;
  final String? activitySectionTitle;
  final List<String> activityFilters;
  final String? parentingTip;

  const MilestoneItem({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.status,
    this.achievedDate,
    this.ageRange = '',
    this.activities = const [],
    this.signsToLookFor = const [],
    this.watchSigns = const [],
    this.warnings = const [],
    this.activitySectionTitle,
    this.activityFilters = const [],
    this.parentingTip,
  });

  MilestoneItem copyWith({
    MilestoneStatus? status,
    String? achievedDate,
    String? description,
    String? ageRange,
    List<MilestoneActivity>? activities,
    List<MilestoneSign>? signsToLookFor,
    List<MilestoneSign>? watchSigns,
    List<MilestoneWarning>? warnings,
    String? activitySectionTitle,
    List<String>? activityFilters,
    String? parentingTip,
  }) {
    return MilestoneItem(
      id: id,
      title: title,
      description: description ?? this.description,
      category: category,
      status: status ?? this.status,
      achievedDate: achievedDate ?? this.achievedDate,
      ageRange: ageRange ?? this.ageRange,
      activities: activities ?? this.activities,
      signsToLookFor: signsToLookFor ?? this.signsToLookFor,
      watchSigns: watchSigns ?? this.watchSigns,
      warnings: warnings ?? this.warnings,
      activitySectionTitle: activitySectionTitle ?? this.activitySectionTitle,
      activityFilters: activityFilters ?? this.activityFilters,
      parentingTip: parentingTip ?? this.parentingTip,
    );
  }
}

// ── Category guidance (the 7-section page) ───────────────────────────────────

class CategoryGuidance {
  final MilestoneCategory category;
  final int ageBandIndex;

  // Section 1 — About
  final String aboutText;

  // Section 2 — Common milestones (checklist)
  final List<MilestoneItem> milestones;

  // Section 3 — Activities
  final List<MilestoneActivity> activities;

  // Section 4 — Signs to look for
  final List<MilestoneSign> signsToLookFor;

  // Section 5 — When to worry
  final List<MilestoneWarning> whenToWorry;

  // Section 6 — Common concerns
  final List<CommonConcern> commonConcerns;

  // Section 7 — Parent tips
  final List<String> parentTips;

  const CategoryGuidance({
    required this.category,
    required this.ageBandIndex,
    required this.aboutText,
    required this.milestones,
    this.activities = const [],
    this.signsToLookFor = const [],
    this.whenToWorry = const [],
    this.commonConcerns = const [],
    this.parentTips = const [],
  });

  int get totalMilestones => milestones.length;
  int get achieved => milestones.where((m) => m.status == MilestoneStatus.achieved).length;
  int get inProgress => milestones.where((m) => m.status == MilestoneStatus.inProgress).length;
  int get notStarted => milestones.where((m) => m.status == MilestoneStatus.notStarted).length;
  double get progressPercent => totalMilestones == 0 ? 0 : achieved / totalMilestones;

  CategoryGuidance withUpdatedMilestone(String id, MilestoneStatus status) {
    final updated = milestones.map((m) {
      if (m.id != id) return m;
      return m.copyWith(
        status: status,
        achievedDate: status == MilestoneStatus.achieved ? _todayString() : null,
      );
    }).toList();
    return CategoryGuidance(
      category: category,
      ageBandIndex: ageBandIndex,
      aboutText: aboutText,
      milestones: updated,
      activities: activities,
      signsToLookFor: signsToLookFor,
      whenToWorry: whenToWorry,
      commonConcerns: commonConcerns,
      parentTips: parentTips,
    );
  }

  static String _todayString() {
    final now = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

// ── Backward-compat alias ─────────────────────────────────────────────────────
// MilestoneCategoryProgress is kept so the provider and home screen ring still compile.

class MilestoneCategoryProgress {
  final MilestoneCategory category;
  final int total;
  final int achieved;
  final int inProgress;
  final List<MilestoneItem> items;

  const MilestoneCategoryProgress({
    required this.category,
    required this.total,
    required this.achieved,
    required this.inProgress,
    required this.items,
  });

  int get notStarted => total - achieved - inProgress;
  double get progressPercent => total == 0 ? 0 : achieved / total;

  factory MilestoneCategoryProgress.fromGuidance(CategoryGuidance g) {
    return MilestoneCategoryProgress(
      category: g.category,
      total: g.totalMilestones,
      achieved: g.achieved,
      inProgress: g.inProgress,
      items: g.milestones,
    );
  }
}

// ── Sample data (6-9 months, used as fallback) ────────────────────────────────

final sampleMilestones = <MilestoneCategoryProgress>[
  MilestoneCategoryProgress(
    category: MilestoneCategory.grossMotor, total: 4, achieved: 2, inProgress: 1,
    items: [
      MilestoneItem(id: 'gm1', title: 'Rolls over in both directions', description: 'Rolls from tummy to back and back to tummy.', category: MilestoneCategory.grossMotor, status: MilestoneStatus.achieved, ageRange: '6-9 Months'),
      MilestoneItem(id: 'gm2', title: 'Sits without support', description: 'Sits steadily without using hands.', category: MilestoneCategory.grossMotor, status: MilestoneStatus.achieved, ageRange: '6-9 Months'),
      MilestoneItem(id: 'gm3', title: 'Crawls on hands and knees', description: 'Moves forward or backward on all fours.', category: MilestoneCategory.grossMotor, status: MilestoneStatus.inProgress, ageRange: '6-9 Months'),
      MilestoneItem(id: 'gm4', title: 'Pulls up to stand', description: 'Uses furniture to pull to standing.', category: MilestoneCategory.grossMotor, status: MilestoneStatus.notStarted, ageRange: '9-12 Months'),
    ],
  ),
  MilestoneCategoryProgress(
    category: MilestoneCategory.language, total: 3, achieved: 2, inProgress: 0,
    items: [
      MilestoneItem(id: 'la1', title: 'Babbles with consonants', description: 'Makes "ba", "da", "ma" sounds.', category: MilestoneCategory.language, status: MilestoneStatus.achieved, ageRange: '6-9 Months'),
      MilestoneItem(id: 'la2', title: 'Responds to name', description: 'Turns when name is called.', category: MilestoneCategory.language, status: MilestoneStatus.achieved, ageRange: '6-9 Months'),
      MilestoneItem(id: 'la3', title: 'Says mama/dada', description: 'Uses mama/dada with meaning.', category: MilestoneCategory.language, status: MilestoneStatus.notStarted, ageRange: '9-12 Months'),
    ],
  ),
];
