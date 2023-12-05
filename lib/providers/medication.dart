import 'package:flutter/material.dart';

import 'package:medi_minder/enums/dosage.dart';
import 'package:medi_minder/enums/medication.dart';

import 'package:medi_minder/entity/dosage.dart';
import 'package:medi_minder/entity/medication.dart';

class MedicationProvider with ChangeNotifier {
  List<Medication> _medications = [];

  MedicationProvider() {
    initializeMedications();
  }

  List<Medication> get medications => _medications;

  void initializeMedications() {
    _medications = [
      Medication(
        type: MedicationType.pill,
        name: 'Aspirin',
        duration: 7,
        dosages: [
          Dosage(numberOfItems: 1, timeOfDay: const TimeOfDay(hour: 8, minute: 00) , timing: DosageTiming.afterMeal),
        ],
        notificationsEnabled: true,
      ),
      Medication(
        type: MedicationType.cachet,
        name: 'Comlivit',
        duration: 7,
        dosages: [
          Dosage(numberOfItems: 1, timeOfDay: const TimeOfDay(hour: 8, minute: 00) , timing: DosageTiming.afterMeal),
        ],
        notificationsEnabled: true,
      ),
      Medication(
        type: MedicationType.ampoule,
        name: '5-HTP',
        duration: 2,
        dosages: [
          Dosage(numberOfItems: 1, timeOfDay: const TimeOfDay(hour: 8, minute: 30) , timing: DosageTiming.whenever),
        ],
        notificationsEnabled: true,
      ),
    ];
  }

  void addMedication(Medication medication) {
    _medications.add(medication);
    notifyListeners();
  }

  void removeMedication(Medication medication) {
    _medications.remove(medication);
    notifyListeners();
  }
}