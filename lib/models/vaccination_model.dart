enum VaccineStatus { given, due, upcoming, overdue }

extension VaccineStatusExt on VaccineStatus {
  String get label {
    switch (this) {
      case VaccineStatus.given:    return 'Given';
      case VaccineStatus.due:      return 'Due Now';
      case VaccineStatus.upcoming: return 'Upcoming';
      case VaccineStatus.overdue:  return 'Overdue';
    }
  }

  String get emoji {
    switch (this) {
      case VaccineStatus.given:    return '✅';
      case VaccineStatus.due:      return '📅';
      case VaccineStatus.upcoming: return '🔜';
      case VaccineStatus.overdue:  return '⚠️';
    }
  }
}

class VaccineRecord {
  final String id;
  final String babyId;
  final String vaccineName;
  final String disease;
  final DateTime dueDate;
  final DateTime? givenDate;
  final String? notes;
  final int doseNumber;

  const VaccineRecord({
    required this.id,
    required this.babyId,
    required this.vaccineName,
    required this.disease,
    required this.dueDate,
    this.givenDate,
    this.notes,
    this.doseNumber = 1,
  });

  VaccineStatus get status {
    if (givenDate != null) return VaccineStatus.given;
    final now = DateTime.now();
    final diff = dueDate.difference(now).inDays;
    if (diff < 0) return VaccineStatus.overdue;
    if (diff <= 7) return VaccineStatus.due;
    return VaccineStatus.upcoming;
  }

  VaccineRecord copyWith({DateTime? givenDate, String? notes}) {
    return VaccineRecord(
      id: id,
      babyId: babyId,
      vaccineName: vaccineName,
      disease: disease,
      dueDate: dueDate,
      givenDate: givenDate ?? this.givenDate,
      notes: notes ?? this.notes,
      doseNumber: doseNumber,
    );
  }
}

// Indian vaccination schedule — generates records based on baby birth date
List<VaccineRecord> generateVaccinationSchedule(String babyId, DateTime birthDate) {
  DateTime due(int days) => birthDate.add(Duration(days: days));
  DateTime dueWeeks(int weeks) => birthDate.add(Duration(days: weeks * 7));
  DateTime dueMonths(int months) {
    var d = DateTime(birthDate.year, birthDate.month + months, birthDate.day);
    return d;
  }

  return [
    // At birth
    VaccineRecord(id: 'bcg', babyId: babyId, vaccineName: 'BCG', disease: 'Tuberculosis', dueDate: due(0), doseNumber: 1),
    VaccineRecord(id: 'opv0', babyId: babyId, vaccineName: 'OPV 0', disease: 'Polio', dueDate: due(0), doseNumber: 1),
    VaccineRecord(id: 'hepb1', babyId: babyId, vaccineName: 'Hepatitis B', disease: 'Hepatitis B', dueDate: due(0), doseNumber: 1),

    // 6 weeks
    VaccineRecord(id: 'dtpw1', babyId: babyId, vaccineName: 'DTwP 1', disease: 'Diphtheria, Tetanus, Pertussis', dueDate: dueWeeks(6), doseNumber: 1),
    VaccineRecord(id: 'ipv1', babyId: babyId, vaccineName: 'IPV 1', disease: 'Polio (Injectable)', dueDate: dueWeeks(6), doseNumber: 1),
    VaccineRecord(id: 'hib1', babyId: babyId, vaccineName: 'Hib 1', disease: 'Haemophilus influenzae type b', dueDate: dueWeeks(6), doseNumber: 1),
    VaccineRecord(id: 'pcv1', babyId: babyId, vaccineName: 'PCV 1', disease: 'Pneumococcal disease', dueDate: dueWeeks(6), doseNumber: 1),
    VaccineRecord(id: 'rv1', babyId: babyId, vaccineName: 'Rotavirus 1', disease: 'Rotavirus diarrhoea', dueDate: dueWeeks(6), doseNumber: 1),
    VaccineRecord(id: 'hepb2', babyId: babyId, vaccineName: 'Hepatitis B 2', disease: 'Hepatitis B', dueDate: dueWeeks(6), doseNumber: 2),

    // 10 weeks
    VaccineRecord(id: 'dtpw2', babyId: babyId, vaccineName: 'DTwP 2', disease: 'Diphtheria, Tetanus, Pertussis', dueDate: dueWeeks(10), doseNumber: 2),
    VaccineRecord(id: 'ipv2', babyId: babyId, vaccineName: 'IPV 2', disease: 'Polio (Injectable)', dueDate: dueWeeks(10), doseNumber: 2),
    VaccineRecord(id: 'hib2', babyId: babyId, vaccineName: 'Hib 2', disease: 'Haemophilus influenzae type b', dueDate: dueWeeks(10), doseNumber: 2),
    VaccineRecord(id: 'rv2', babyId: babyId, vaccineName: 'Rotavirus 2', disease: 'Rotavirus diarrhoea', dueDate: dueWeeks(10), doseNumber: 2),

    // 14 weeks
    VaccineRecord(id: 'dtpw3', babyId: babyId, vaccineName: 'DTwP 3', disease: 'Diphtheria, Tetanus, Pertussis', dueDate: dueWeeks(14), doseNumber: 3),
    VaccineRecord(id: 'ipv3', babyId: babyId, vaccineName: 'IPV 3', disease: 'Polio (Injectable)', dueDate: dueWeeks(14), doseNumber: 3),
    VaccineRecord(id: 'hib3', babyId: babyId, vaccineName: 'Hib 3', disease: 'Haemophilus influenzae type b', dueDate: dueWeeks(14), doseNumber: 3),
    VaccineRecord(id: 'pcv2', babyId: babyId, vaccineName: 'PCV 2', disease: 'Pneumococcal disease', dueDate: dueWeeks(14), doseNumber: 2),
    VaccineRecord(id: 'rv3', babyId: babyId, vaccineName: 'Rotavirus 3', disease: 'Rotavirus diarrhoea', dueDate: dueWeeks(14), doseNumber: 3),

    // 6 months
    VaccineRecord(id: 'hepb3', babyId: babyId, vaccineName: 'Hepatitis B 3', disease: 'Hepatitis B', dueDate: dueMonths(6), doseNumber: 3),
    VaccineRecord(id: 'opv1', babyId: babyId, vaccineName: 'OPV 1', disease: 'Polio (Oral)', dueDate: dueMonths(6), doseNumber: 2),
    VaccineRecord(id: 'flu1', babyId: babyId, vaccineName: 'Influenza 1', disease: 'Influenza (Flu)', dueDate: dueMonths(6), doseNumber: 1),

    // 9 months
    VaccineRecord(id: 'mmr1', babyId: babyId, vaccineName: 'MMR 1', disease: 'Measles, Mumps, Rubella', dueDate: dueMonths(9), doseNumber: 1),
    VaccineRecord(id: 'opv2', babyId: babyId, vaccineName: 'OPV 2', disease: 'Polio (Oral)', dueDate: dueMonths(9), doseNumber: 3),

    // 12 months
    VaccineRecord(id: 'hepA1', babyId: babyId, vaccineName: 'Hepatitis A 1', disease: 'Hepatitis A', dueDate: dueMonths(12), doseNumber: 1),
    VaccineRecord(id: 'varicella1', babyId: babyId, vaccineName: 'Varicella 1', disease: 'Chickenpox', dueDate: dueMonths(12), doseNumber: 1),
    VaccineRecord(id: 'pcvb', babyId: babyId, vaccineName: 'PCV Booster', disease: 'Pneumococcal disease', dueDate: dueMonths(12), doseNumber: 3),

    // 15 months
    VaccineRecord(id: 'mmr2', babyId: babyId, vaccineName: 'MMR 2', disease: 'Measles, Mumps, Rubella', dueDate: dueMonths(15), doseNumber: 2),
    VaccineRecord(id: 'varicella2', babyId: babyId, vaccineName: 'Varicella 2', disease: 'Chickenpox', dueDate: dueMonths(15), doseNumber: 2),

    // 18 months
    VaccineRecord(id: 'dtpwb1', babyId: babyId, vaccineName: 'DTwP Booster 1', disease: 'Diphtheria, Tetanus, Pertussis', dueDate: dueMonths(18), doseNumber: 4),
    VaccineRecord(id: 'hibb', babyId: babyId, vaccineName: 'Hib Booster', disease: 'Haemophilus influenzae type b', dueDate: dueMonths(18), doseNumber: 4),
    VaccineRecord(id: 'ipvb', babyId: babyId, vaccineName: 'IPV Booster', disease: 'Polio (Injectable)', dueDate: dueMonths(18), doseNumber: 4),
    VaccineRecord(id: 'hepA2', babyId: babyId, vaccineName: 'Hepatitis A 2', disease: 'Hepatitis A', dueDate: dueMonths(18), doseNumber: 2),

    // 2 years
    VaccineRecord(id: 'opv3', babyId: babyId, vaccineName: 'OPV 3', disease: 'Polio (Oral)', dueDate: dueMonths(24), doseNumber: 4),
    VaccineRecord(id: 'typhoid1', babyId: babyId, vaccineName: 'Typhoid', disease: 'Typhoid fever', dueDate: dueMonths(24), doseNumber: 1),
  ];
}
