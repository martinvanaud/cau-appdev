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
  return values.firstWhere((type) => type.toString().split('.').last == value);
}
