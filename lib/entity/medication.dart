import 'package:medi_minder/entity/dosage.dart';
import 'package:medi_minder/enums/medication.dart';

class Medication {
  final String id;
  final MedicationType type;
  final String name;
  final List<Dosage> dosages;
  final int duration;
  final bool notificationsEnabled;

  Medication({
    required this.id,
    required this.type,
    required this.name,
    required this.dosages,
    required this.duration,
    this.notificationsEnabled = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.toString(),
      'name': name,
      'dosages': dosages.map((dosage) => dosage.toMap()).toList(),
      'duration': duration,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  static Medication fromMap(Map<String, dynamic> map, String documentId) {
    return Medication(
      id: documentId,
      type: MedicationType.values.firstWhere((e) => e.toString() == 'MedicationType.${map['type']}'),
      name: map['name'],
      dosages: (map['dosages'] as List<dynamic>).map((dosageMap) => Dosage.fromMap(dosageMap)).toList(),
      duration: map['duration'],
      notificationsEnabled: map['notificationsEnabled'],
    );
  }
}
