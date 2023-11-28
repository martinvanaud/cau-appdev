import 'package:medi_minder/enums/dosage.dart';
import 'package:medi_minder/entity/schedule.dart';

class Dosage {
  final int numberOfItems;
  final Schedule timeOfDay;
  final DosageTiming timing;

  Dosage({
    required this.numberOfItems,
    required this.timeOfDay,
    required this.timing,
  });
}