enum MilestoneStatus { achieved, inProgress, notStarted }

enum MilestoneCategory {
  grossMotor,
  fineMotor,
  language,
  socialEmotional,
  cognitive,
}

extension MilestoneCategoryExt on MilestoneCategory {
  String get label {
    switch (this) {
      case MilestoneCategory.grossMotor:
        return 'Gross Motor';
      case MilestoneCategory.fineMotor:
        return 'Fine Motor';
      case MilestoneCategory.language:
        return 'Language & Communication';
      case MilestoneCategory.socialEmotional:
        return 'Social & Emotional';
      case MilestoneCategory.cognitive:
        return 'Cognitive';
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
      case MilestoneCategory.socialEmotional:
        return '💗';
      case MilestoneCategory.cognitive:
        return '🧠';
    }
  }
}

class MilestoneItem {
  final String id;
  final String title;
  final MilestoneCategory category;
  final MilestoneStatus status;
  final String? achievedDate;

  const MilestoneItem({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    this.achievedDate,
  });
}

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
}

// Sample milestone data for 7–9 months
final sampleMilestones = [
  MilestoneCategoryProgress(
    category: MilestoneCategory.grossMotor,
    total: 4,
    achieved: 3,
    inProgress: 1,
    items: [
      MilestoneItem(id: 'gm1', title: 'Sits without support', category: MilestoneCategory.grossMotor, status: MilestoneStatus.achieved),
      MilestoneItem(id: 'gm2', title: 'Rolls both ways', category: MilestoneCategory.grossMotor, status: MilestoneStatus.achieved),
      MilestoneItem(id: 'gm3', title: 'Starts crawling', category: MilestoneCategory.grossMotor, status: MilestoneStatus.achieved),
      MilestoneItem(id: 'gm4', title: 'Pulls to stand', category: MilestoneCategory.grossMotor, status: MilestoneStatus.inProgress),
    ],
  ),
  MilestoneCategoryProgress(
    category: MilestoneCategory.fineMotor,
    total: 3,
    achieved: 2,
    inProgress: 1,
    items: [
      MilestoneItem(id: 'fm1', title: 'Transfers objects hand to hand', category: MilestoneCategory.fineMotor, status: MilestoneStatus.achieved),
      MilestoneItem(id: 'fm2', title: 'Bangs objects together', category: MilestoneCategory.fineMotor, status: MilestoneStatus.achieved),
      MilestoneItem(id: 'fm3', title: 'Pincer grasp developing', category: MilestoneCategory.fineMotor, status: MilestoneStatus.inProgress),
    ],
  ),
  MilestoneCategoryProgress(
    category: MilestoneCategory.language,
    total: 4,
    achieved: 3,
    inProgress: 0,
    items: [
      MilestoneItem(id: 'la1', title: 'Babbles with consonants', category: MilestoneCategory.language, status: MilestoneStatus.achieved),
      MilestoneItem(id: 'la2', title: 'Responds to name', category: MilestoneCategory.language, status: MilestoneStatus.achieved),
      MilestoneItem(id: 'la3', title: 'Imitates sounds', category: MilestoneCategory.language, status: MilestoneStatus.achieved),
      MilestoneItem(id: 'la4', title: 'Says mama/dada', category: MilestoneCategory.language, status: MilestoneStatus.notStarted),
    ],
  ),
  MilestoneCategoryProgress(
    category: MilestoneCategory.socialEmotional,
    total: 3,
    achieved: 2,
    inProgress: 1,
    items: [
      MilestoneItem(id: 'se1', title: 'Shows stranger anxiety', category: MilestoneCategory.socialEmotional, status: MilestoneStatus.achieved),
      MilestoneItem(id: 'se2', title: 'Plays peek-a-boo', category: MilestoneCategory.socialEmotional, status: MilestoneStatus.achieved),
      MilestoneItem(id: 'se3', title: 'Waves bye-bye', category: MilestoneCategory.socialEmotional, status: MilestoneStatus.inProgress),
    ],
  ),
  MilestoneCategoryProgress(
    category: MilestoneCategory.cognitive,
    total: 3,
    achieved: 2,
    inProgress: 1,
    items: [
      MilestoneItem(id: 'co1', title: 'Looks for hidden objects', category: MilestoneCategory.cognitive, status: MilestoneStatus.achieved),
      MilestoneItem(id: 'co2', title: 'Explores objects with hands/mouth', category: MilestoneCategory.cognitive, status: MilestoneStatus.achieved),
      MilestoneItem(id: 'co3', title: 'Understands cause and effect', category: MilestoneCategory.cognitive, status: MilestoneStatus.inProgress),
    ],
  ),
];
