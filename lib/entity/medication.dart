import 'package:medi_minder/entity/dosage.dart';
import 'package:medi_minder/enums/medication.dart';

class Medication {
  final MedicationType type;
  final String name;
  final List<Dosage> dosages;
  final int duration;
  final bool notificationsEnabled;

  Medication({
    required this.type,
    required this.name,
    required this.dosages,
    required this.duration,
    this.notificationsEnabled = false,
  });
}
