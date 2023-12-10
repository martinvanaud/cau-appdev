import 'package:flutter/material.dart';
import 'package:medi_minder/enums/dosage.dart';

class Dosage {
  final int numberOfItems;
  final TimeOfDay timeOfDay;
  final DosageTiming timing;

  Dosage({
    required this.numberOfItems,
    required this.timeOfDay,
    required this.timing,
  });

  Map<String, dynamic> toMap() {
    return {
      'numberOfItems': numberOfItems,
      'timeOfDay': {
        'hour': timeOfDay.hour.toString(),
        'minute': timeOfDay.minute.toString(),
      },
      'timing': timing.toString(),
    };
  }

  static Dosage fromMap(Map<String, dynamic> map) {
    return Dosage(
      numberOfItems: map['numberOfItems'] is int ? map['numberOfItems'] : int.parse(map['numberOfItems'].toString()),
      timeOfDay: TimeOfDay(
          hour: map['timeOfDay']['hour'],
          minute: map['timeOfDay']['minute']
      ),
      timing: DosageTiming.values.firstWhere((e) => e.toString() == 'DosageTiming.${map['timing']}'),
    );
  }
}
