class BabyModel {
  final String id;
  final String name;
  final DateTime? birthDate;   // nullable — pregnant users don't have this yet
  final double? heightCm;
  final double? weightKg;
  final String? photoUrl;
  final String gender;
  final DateTime? dueDate;     // for pregnant users

  const BabyModel({
    required this.id,
    this.name = 'My Baby',
    this.birthDate,
    this.heightCm,
    this.weightKg,
    this.photoUrl,
    this.gender = 'girl',
    this.dueDate,
  });

  bool get isBorn => birthDate != null;
  bool get isExpected => dueDate != null && !isBorn;

  /// Returns age as a human-readable string e.g. "8 Months 12 Days"
  /// For unborn babies returns weeks until due date.
  String get ageString {
    if (!isBorn) {
      if (dueDate != null) {
        final daysLeft = dueDate!.difference(DateTime.now()).inDays;
        if (daysLeft <= 0) return 'Due any day now!';
        final weeksLeft = (daysLeft / 7).ceil();
        return '$weeksLeft weeks to go';
      }
      return 'Coming soon';
    }
    final now = DateTime.now();
    final totalDays = now.difference(birthDate!).inDays;
    if (totalDays < 30) return '$totalDays Days';
    if (totalDays < 365) {
      final months = totalDays ~/ 30;
      final days = totalDays % 30;
      if (days == 0) return '$months Months';
      return '$months Months $days Days';
    }
    final years = totalDays ~/ 365;
    final months = (totalDays % 365) ~/ 30;
    if (months == 0) return '$years Years';
    return '$years Years $months Months';
  }

  /// Returns age in total months (0 if not born yet)
  int get ageInMonths {
    if (!isBorn) return 0;
    return (DateTime.now().difference(birthDate!).inDays / 30).floor();
  }

  /// Pregnancy week (1–40) for unborn babies
  int? get pregnancyWeek {
    if (dueDate == null) return null;
    final conceptionApprox = dueDate!.subtract(const Duration(days: 280));
    final weeks = DateTime.now().difference(conceptionApprox).inDays ~/ 7;
    return weeks.clamp(1, 42);
  }

  BabyModel copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    double? heightCm,
    double? weightKg,
    String? photoUrl,
    String? gender,
    DateTime? dueDate,
  }) {
    return BabyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      photoUrl: photoUrl ?? this.photoUrl,
      gender: gender ?? this.gender,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}

// Sample data for UI development
final sampleBaby = BabyModel(
  id: '1',
  name: 'Aarohi',
  birthDate: DateTime(2024, 8, 12),
  heightCm: 67,
  weightKg: 7.6,
  gender: 'girl',
);

// Sample pregnant user
final samplePregnantBaby = BabyModel(
  id: '2',
  name: 'Baby',
  dueDate: DateTime.now().add(const Duration(days: 56)),
  gender: 'girl',
);
