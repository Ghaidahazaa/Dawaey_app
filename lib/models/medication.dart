
class Medication {
  final String name; // اسم الدواء
  final String dosage; // جرعة الدواء
  final int dosesPerDay; // عدد الجرعات في اليوم
  final DateTime firstDoseTime; // وقت الجرعة الأولى
  final String frequency; // تكرار الجرعة (يومي، أسبوعي، شهري)
  final List<int> selectedDays; // الأيام المحددة (للتكرار الأسبوعي أو الشهري)
  final int durationInDays; // مدة العلاج بالأيام
  final bool isPermanent; // هل العلاج دائم أم مؤقت
  final int? intervalHours; // الفاصل الزمني بين الجرعات

  Medication({
    required this.name,
    required this.dosage,
    required this.dosesPerDay,
    required this.firstDoseTime,
    required this.frequency,
    required this.selectedDays,
    required this.durationInDays,
    required this.isPermanent,
    this.intervalHours,
  });

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      name: map['name'],
      dosage: map['dosage'],
      dosesPerDay: map['dosesPerDay'],
      firstDoseTime: DateTime.parse(map['firstDoseTime']),
      frequency: map['frequency'],
      selectedDays: (map['selectedDays'] as String)
          .split(',')
          .map(int.parse)
          .toList(),
      durationInDays: map['durationInDays'],
      isPermanent: map['isPermanent'] == 1,
      intervalHours: map['intervalHours'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'dosesPerDay': dosesPerDay,
      'firstDoseTime': firstDoseTime.toIso8601String(),
      'frequency': frequency,
      'selectedDays': selectedDays.join(','),
      'durationInDays': durationInDays,
      'isPermanent': isPermanent ? 1 : 0,
      'intervalHours': intervalHours ?? 0,
    };
  }
}
