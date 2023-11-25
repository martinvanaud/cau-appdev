import 'package:medi_minder/enums/mood.dart';
import 'package:medi_minder/enums/symptoms.dart';

class JournalEntry {
  final String date;
  final Symptoms symptoms;
  final String feelings;
  final Mood mood;

  JournalEntry({
    required this.date,
    required this.symptoms,
    required this.feelings,
    required this.mood,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'symptoms': symptoms.toString().split('.').last,
      'feelings': feelings,
      'mood': mood.toString().split('.').last,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      date: json['date'],
      symptoms: enumFromString(Symptoms.values, json['symptoms']),
      feelings: json['feelings'],
      mood: enumFromString(Mood.values, json['mood']),
    );
  }
}

T enumFromString<T>(List<T> values, String value) {
  final formattedValues = value.split(',').map((v) => v.trim().toLowerCase()).toList();

  return values.firstWhere(
        (type) {
      final typeName = type.toString().split('.').last.toLowerCase();
      return formattedValues.any((formattedValue) => typeName == formattedValue);
    },
    orElse: () {
      throw Exception('No matching element found for value: $value');
    },
  );
}




