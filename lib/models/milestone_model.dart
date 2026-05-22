enum MilestoneStatus { notStarted, inProgress, achieved }

enum MilestoneCategory {
  grossMotor,
  fineMotor,
  language,
  cognitive,
  social,
  feedingSleep,
}

String _readString(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is String) return value;
    if (value != null) return value.toString();
  }
  return fallback;
}

bool _readBool(
  Map<String, dynamic> json,
  List<String> keys, {
  bool fallback = false,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
  }
  return fallback;
}

List<String> _readStringList(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
  }
  return const [];
}

List<Map<String, dynamic>> _readMapList(
  Map<String, dynamic> json,
  List<String> keys,
) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
  }
  return const [];
}

MilestoneStatus milestoneStatusFromJson(String? value) {
  switch ((value ?? '').trim().toLowerCase()) {
    case 'achieved':
    case 'done':
    case 'completed':
      return MilestoneStatus.achieved;
    case 'inprogress':
    case 'in_progress':
    case 'in progress':
      return MilestoneStatus.inProgress;
    case 'notstarted':
    case 'not_started':
    case 'not started':
    default:
      return MilestoneStatus.notStarted;
  }
}

String milestoneStatusToJson(MilestoneStatus status) {
  switch (status) {
    case MilestoneStatus.achieved:
      return 'achieved';
    case MilestoneStatus.inProgress:
      return 'in_progress';
    case MilestoneStatus.notStarted:
      return 'not_started';
  }
}

MilestoneCategory milestoneCategoryFromJson(String? value) {
  final normalized = (value ?? '').trim().toLowerCase().replaceAll(
    RegExp(r'[^a-z0-9]'),
    '',
  );
  switch (normalized) {
    case 'grossmotor':
      return MilestoneCategory.grossMotor;
    case 'finemotor':
      return MilestoneCategory.fineMotor;
    case 'language':
      return MilestoneCategory.language;
    case 'cognitive':
      return MilestoneCategory.cognitive;
    case 'social':
    case 'socialemotional':
      return MilestoneCategory.social;
    case 'feedingsleep':
    case 'feedingandsleep':
      return MilestoneCategory.feedingSleep;
    default:
      return MilestoneCategory.grossMotor;
  }
}

extension MilestoneCategoryExt on MilestoneCategory {
  String get label {
    switch (this) {
      case MilestoneCategory.grossMotor:
        return 'Gross Motor';
      case MilestoneCategory.fineMotor:
        return 'Fine Motor';
      case MilestoneCategory.language:
        return 'Language';
      case MilestoneCategory.cognitive:
        return 'Cognitive';
      case MilestoneCategory.social:
        return 'Social';
      case MilestoneCategory.feedingSleep:
        return 'Feeding & Sleep';
    }
  }

  String get emoji {
    switch (this) {
      case MilestoneCategory.grossMotor:
        return '🏃';
      case MilestoneCategory.fineMotor:
        return '✋';
      case MilestoneCategory.language:
        return '💬';
      case MilestoneCategory.cognitive:
        return '🧠';
      case MilestoneCategory.social:
        return '💗';
      case MilestoneCategory.feedingSleep:
        return '🍼';
    }
  }

  String get description {
    switch (this) {
      case MilestoneCategory.grossMotor:
        return 'Physical development and movement milestones.';
      case MilestoneCategory.fineMotor:
        return 'Hand, finger and eye-hand coordination.';
      case MilestoneCategory.language:
        return 'Communication, speech and understanding.';
      case MilestoneCategory.cognitive:
        return 'Thinking, learning and problem-solving.';
      case MilestoneCategory.social:
        return 'Social bonding and emotional growth.';
      case MilestoneCategory.feedingSleep:
        return 'Feeding patterns, sleep routines and self-regulation.';
    }
  }
}

// ── Age band ──────────────────────────────────────────────────────────────────

class AgeBand {
  final int index;
  final String label; // e.g. "0-1 Weeks"
  final String shortLabel; // e.g. "0-1w"
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
  AgeBand(
    index: 0,
    label: '0-1 Weeks',
    shortLabel: '0-1w',
    emoji: '🌱',
    minDays: 0,
    maxDays: 6,
  ),
  AgeBand(
    index: 1,
    label: '1-2 Weeks',
    shortLabel: '1-2w',
    emoji: '🌱',
    minDays: 7,
    maxDays: 13,
  ),
  AgeBand(
    index: 2,
    label: '2-3 Weeks',
    shortLabel: '2-3w',
    emoji: '🌱',
    minDays: 14,
    maxDays: 20,
  ),
  AgeBand(
    index: 3,
    label: '3-4 Weeks',
    shortLabel: '3-4w',
    emoji: '🌱',
    minDays: 21,
    maxDays: 27,
  ),
  AgeBand(
    index: 4,
    label: '4-6 Weeks',
    shortLabel: '4-6w',
    emoji: '🍼',
    minDays: 28,
    maxDays: 41,
  ),
  AgeBand(
    index: 5,
    label: '6-8 Weeks',
    shortLabel: '6-8w',
    emoji: '🍼',
    minDays: 42,
    maxDays: 55,
  ),
  AgeBand(
    index: 6,
    label: '2-3 Months',
    shortLabel: '2-3m',
    emoji: '🧸',
    minDays: 56,
    maxDays: 89,
  ),
  AgeBand(
    index: 7,
    label: '3-4 Months',
    shortLabel: '3-4m',
    emoji: '🧸',
    minDays: 90,
    maxDays: 119,
  ),
  AgeBand(
    index: 8,
    label: '4-5 Months',
    shortLabel: '4-5m',
    emoji: '🌟',
    minDays: 120,
    maxDays: 149,
  ),
  AgeBand(
    index: 9,
    label: '5-6 Months',
    shortLabel: '5-6m',
    emoji: '🌟',
    minDays: 150,
    maxDays: 179,
  ),
  AgeBand(
    index: 10,
    label: '6-9 Months',
    shortLabel: '6-9m',
    emoji: '🎀',
    minDays: 180,
    maxDays: 272,
  ),
  AgeBand(
    index: 11,
    label: '9-12 Months',
    shortLabel: '9-12m',
    emoji: '🎀',
    minDays: 273,
    maxDays: 364,
  ),
  AgeBand(
    index: 12,
    label: '1-1.5 Years',
    shortLabel: '1-1.5y',
    emoji: '🚶',
    minDays: 365,
    maxDays: 547,
  ),
  AgeBand(
    index: 13,
    label: '1.5-2 Years',
    shortLabel: '1.5-2y',
    emoji: '🚶',
    minDays: 548,
    maxDays: 729,
  ),
  AgeBand(
    index: 14,
    label: '2-2.5 Years',
    shortLabel: '2-2.5y',
    emoji: '🏃',
    minDays: 730,
    maxDays: 912,
  ),
  AgeBand(
    index: 15,
    label: '2.5-3 Years',
    shortLabel: '2.5-3y',
    emoji: '🏃',
    minDays: 913,
    maxDays: 1094,
  ),
  AgeBand(
    index: 16,
    label: '3-4 Years',
    shortLabel: '3-4y',
    emoji: '🎨',
    minDays: 1095,
    maxDays: 1459,
  ),
  AgeBand(
    index: 17,
    label: '4-5 Years',
    shortLabel: '4-5y',
    emoji: '🎨',
    minDays: 1460,
    maxDays: 1824,
  ),
  AgeBand(
    index: 18,
    label: '5-6 Years',
    shortLabel: '5-6y',
    emoji: '📚',
    minDays: 1825,
    maxDays: 2189,
  ),
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

  factory MilestoneActivity.fromJson(Map<String, dynamic> j) =>
      MilestoneActivity(
        title: _readString(j, ['title']),
        description: _readString(j, ['description']),
        emoji: _readString(j, ['emoji'], fallback: '💡'),
        steps: _readStringList(j, ['steps']),
        filter: _readString(j, ['filter'], fallback: '').isEmpty
            ? null
            : _readString(j, ['filter']),
      );

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'emoji': emoji,
    'steps': steps,
    if (filter != null) 'filter': filter,
  };
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

  factory MilestoneSign.fromJson(Map<String, dynamic> j) => MilestoneSign(
    title: _readString(j, ['title']),
    description: _readString(j, ['description']),
    isPositive: _readBool(j, ['isPositive', 'is_positive'], fallback: true),
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'is_positive': isPositive,
  };
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

  factory MilestoneWarning.fromJson(Map<String, dynamic> j) => MilestoneWarning(
    title: _readString(j, ['title']),
    description: _readString(j, ['description']),
    emoji: _readString(j, ['emoji'], fallback: '⚠️'),
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'emoji': emoji,
  };
}

class CommonConcern {
  final String question;
  final String answer;

  const CommonConcern({required this.question, required this.answer});

  factory CommonConcern.fromJson(Map<String, dynamic> j) => CommonConcern(
    question: _readString(j, ['question']),
    answer: _readString(j, ['answer']),
  );

  Map<String, dynamic> toJson() => {'question': question, 'answer': answer};
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

  factory MilestoneItem.fromJson(
    Map<String, dynamic> j, [
    MilestoneCategory? category,
  ]) {
    final cat =
        category ??
        milestoneCategoryFromJson(
          _readString(j, ['category'], fallback: 'grossMotor'),
        );
    final achievedDate = _readString(j, [
      'achievedDate',
      'achieved_date',
    ], fallback: '');
    final activitySectionTitle = _readString(j, [
      'activitySectionTitle',
      'activity_section_title',
    ], fallback: '');
    final parentingTip = _readString(j, [
      'parentingTip',
      'parenting_tip',
    ], fallback: '');

    return MilestoneItem(
      id: _readString(j, ['id']),
      title: _readString(j, ['title']),
      description: _readString(j, ['description']),
      category: cat,
      status: milestoneStatusFromJson(
        _readString(j, [
          'status',
        ], fallback: milestoneStatusToJson(MilestoneStatus.notStarted)),
      ),
      achievedDate: achievedDate.isEmpty ? null : achievedDate,
      ageRange: _readString(j, ['ageRange', 'age_range']),
      activities: _readMapList(j, [
        'activities',
      ]).map(MilestoneActivity.fromJson).toList(),
      signsToLookFor: _readMapList(j, [
        'signsToLookFor',
        'signs_to_look_for',
      ]).map(MilestoneSign.fromJson).toList(),
      watchSigns: _readMapList(j, ['watchSigns', 'watch_signs'])
          .map(
            (sign) => MilestoneSign.fromJson({
              ...sign,
              'is_positive': sign['is_positive'] ?? sign['isPositive'] ?? false,
            }),
          )
          .toList(),
      warnings: _readMapList(j, [
        'warnings',
        'whenToWorry',
        'when_to_worry',
      ]).map(MilestoneWarning.fromJson).toList(),
      activitySectionTitle: activitySectionTitle.isEmpty
          ? null
          : activitySectionTitle,
      activityFilters: _readStringList(j, [
        'activityFilters',
        'activity_filters',
      ]),
      parentingTip: parentingTip.isEmpty ? null : parentingTip,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category.name,
    'status': milestoneStatusToJson(status),
    if (achievedDate != null) 'achieved_date': achievedDate,
    'age_range': ageRange,
    if (activities.isNotEmpty)
      'activities': activities.map((activity) => activity.toJson()).toList(),
    if (signsToLookFor.isNotEmpty)
      'signs_to_look_for': signsToLookFor.map((sign) => sign.toJson()).toList(),
    if (watchSigns.isNotEmpty)
      'watch_signs': watchSigns.map((sign) => sign.toJson()).toList(),
    if (warnings.isNotEmpty)
      'warnings': warnings.map((warning) => warning.toJson()).toList(),
    if (activitySectionTitle != null)
      'activity_section_title': activitySectionTitle,
    if (activityFilters.isNotEmpty) 'activity_filters': activityFilters,
    if (parentingTip != null) 'parenting_tip': parentingTip,
  };
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
  int get achieved =>
      milestones.where((m) => m.status == MilestoneStatus.achieved).length;
  int get inProgress =>
      milestones.where((m) => m.status == MilestoneStatus.inProgress).length;
  int get notStarted =>
      milestones.where((m) => m.status == MilestoneStatus.notStarted).length;
  double get progressPercent =>
      totalMilestones == 0 ? 0 : achieved / totalMilestones;

  CategoryGuidance withUpdatedMilestone(String id, MilestoneStatus status) {
    final updated = milestones.map((m) {
      if (m.id != id) return m;
      return m.copyWith(
        status: status,
        achievedDate: status == MilestoneStatus.achieved
            ? _todayString()
            : null,
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
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  // ── Serialisation ─────────────────────────────────────────────────────────

  factory CategoryGuidance.fromJson(Map<String, dynamic> j) {
    final cat = milestoneCategoryFromJson(
      _readString(j, ['category'], fallback: 'grossMotor'),
    );
    return CategoryGuidance(
      category: cat,
      ageBandIndex: (j['band_index'] as num?)?.toInt() ?? 0,
      aboutText: _readString(j, ['about_text', 'aboutText']),
      milestones: _readMapList(j, [
        'milestones',
      ]).map((m) => MilestoneItem.fromJson(m, cat)).toList(),
      activities: _readMapList(j, [
        'activities',
      ]).map(MilestoneActivity.fromJson).toList(),
      signsToLookFor: _readMapList(j, [
        'signs_to_look_for',
        'signsToLookFor',
      ]).map(MilestoneSign.fromJson).toList(),
      whenToWorry: _readMapList(j, [
        'when_to_worry',
        'whenToWorry',
      ]).map(MilestoneWarning.fromJson).toList(),
      commonConcerns: _readMapList(j, [
        'common_concerns',
        'commonConcerns',
      ]).map(CommonConcern.fromJson).toList(),
      parentTips: _readStringList(j, ['parent_tips', 'parentTips']),
    );
  }

  Map<String, dynamic> toJson() => {
    'band_index': ageBandIndex,
    'category': category.name,
    'about_text': aboutText,
    'milestones': milestones.map((m) => m.toJson()).toList(),
    'activities': activities.map((a) => a.toJson()).toList(),
    'signs_to_look_for': signsToLookFor.map((s) => s.toJson()).toList(),
    'when_to_worry': whenToWorry.map((w) => w.toJson()).toList(),
    'common_concerns': commonConcerns.map((c) => c.toJson()).toList(),
    'parent_tips': parentTips,
  };
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
    category: MilestoneCategory.grossMotor,
    total: 4,
    achieved: 2,
    inProgress: 1,
    items: [
      MilestoneItem(
        id: 'gm1',
        title: 'Rolls over in both directions',
        description: 'Rolls from tummy to back and back to tummy.',
        category: MilestoneCategory.grossMotor,
        status: MilestoneStatus.achieved,
        ageRange: '6-9 Months',
      ),
      MilestoneItem(
        id: 'gm2',
        title: 'Sits without support',
        description: 'Sits steadily without using hands.',
        category: MilestoneCategory.grossMotor,
        status: MilestoneStatus.achieved,
        ageRange: '6-9 Months',
      ),
      MilestoneItem(
        id: 'gm3',
        title: 'Crawls on hands and knees',
        description: 'Moves forward or backward on all fours.',
        category: MilestoneCategory.grossMotor,
        status: MilestoneStatus.inProgress,
        ageRange: '6-9 Months',
      ),
      MilestoneItem(
        id: 'gm4',
        title: 'Pulls up to stand',
        description: 'Uses furniture to pull to standing.',
        category: MilestoneCategory.grossMotor,
        status: MilestoneStatus.notStarted,
        ageRange: '9-12 Months',
      ),
    ],
  ),
  MilestoneCategoryProgress(
    category: MilestoneCategory.language,
    total: 3,
    achieved: 2,
    inProgress: 0,
    items: [
      MilestoneItem(
        id: 'la1',
        title: 'Babbles with consonants',
        description: 'Makes "ba", "da", "ma" sounds.',
        category: MilestoneCategory.language,
        status: MilestoneStatus.achieved,
        ageRange: '6-9 Months',
      ),
      MilestoneItem(
        id: 'la2',
        title: 'Responds to name',
        description: 'Turns when name is called.',
        category: MilestoneCategory.language,
        status: MilestoneStatus.achieved,
        ageRange: '6-9 Months',
      ),
      MilestoneItem(
        id: 'la3',
        title: 'Says mama/dada',
        description: 'Uses mama/dada with meaning.',
        category: MilestoneCategory.language,
        status: MilestoneStatus.notStarted,
        ageRange: '9-12 Months',
      ),
    ],
  ),
];
