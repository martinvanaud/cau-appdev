import 'package:flutter/material.dart';
import 'package:medi_minder/enums/dosage.dart';

class Dosage {
  final int numberOfItems;
  final TimeOfDay? timeOfDay;
  final DosageTiming timing;

  Dosage({
    required this.numberOfItems,
    this.timeOfDay,
    required this.timing,
  });
}