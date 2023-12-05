import 'package:flutter/material.dart';
import 'package:medi_minder/enums/dosage.dart';

class Dosage {
  final int numberOfItems;
  TimeOfDay timeOfDay;
  final DosageTiming timing;

  Dosage({
    required this.numberOfItems,
    required this.timeOfDay,
    required this.timing,
  });
}