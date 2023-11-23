import 'package:flutter/material.dart';
import 'enums/dosage.dart';

class AddMedicationPage extends StatelessWidget {
  AddMedicationPage({super.key});
  DosageTiming? _dosageTime;
  final bool _isComplete = true;

  List<Widget> _getDosageTimeButtons() {
    return DosageTiming.values.map((dosageTime) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
        onPressed: () {
          _dosageTime = dosageTime;
        },
        child: Text(_getDosageTimeText(dosageTime), style: const TextStyle(fontSize: 20)),
        ),
      );
    }).toList();
  }

  String _getDosageTimeText(DosageTiming dosageTime) {
    switch (dosageTime) {
      case DosageTiming.beforeMeal:
        return 'Before Meals';
      case DosageTiming.duringMeal:
        return 'During Meals';
      case DosageTiming.afterMeal:
        return 'After Meals';
      case DosageTiming.whenever:
        return 'Whenever';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        )
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('1 of 2', style: TextStyle(fontSize: 16)),
                Text('Add Medication', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () => {},
                    child: const Text('', style: TextStyle(fontSize: 20)),
                ),
                ElevatedButton(
                    onPressed:  () => {},
                    child: const Text('', style: TextStyle(fontSize: 20)),
                ),
                ElevatedButton(
                    onPressed: () => {},
                    child: const Text('', style: TextStyle(fontSize: 20)),
                ),
                ElevatedButton(
                    onPressed:  () => {},
                    child: const Text('', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Single dose, e.g. 1 tablet',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _getDosageTimeButtons(),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: !_isComplete ?
              ElevatedButton(
                onPressed: (){},
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                  backgroundColor:  MaterialStateProperty.all(const Color(0xFFF4F4F5)),
                ),
                child: const Text("Fill in the fields"),
                )
              :
              ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo),
                ),
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}