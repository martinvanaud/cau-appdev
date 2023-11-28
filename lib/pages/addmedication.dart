import 'package:flutter/material.dart';
import '../enums/dosage.dart';
import '../enums/medication.dart';

class AddMedicationPage extends StatefulWidget {
  const AddMedicationPage({super.key});

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  DosageTiming? _dosageTime;
  MedicationType? _medicationType;
  final bool _isComplete = true;

  final greyLight = 0xFFF4F4F5;

  List<Widget> _getDosageTimeButtons() {
    return DosageTiming.values.map((dosageTime) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
        onPressed: () {
          setState(() {
            _dosageTime = dosageTime;
          });
        },
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(_dosageTime == dosageTime ? Colors.black : Colors.grey),
          backgroundColor: MaterialStateProperty.all<Color>(_dosageTime == dosageTime ? Color(greyLight) : Colors.white),
        ),
        child: Text(_getDosageTimeText(dosageTime), style: const TextStyle(fontSize: 20))),
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

  List<Widget> _getMedicationTypeButtons() {
    return MedicationType.values.map((medicationType) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Color(greyLight),
            borderRadius: BorderRadius.circular(100.0),
          ),
          child: IconButton(
            icon: Image.asset(
              'assets/medication/${medicationType.name}.png',
              height: 60
            ),
            onPressed: () {
              setState(() {
                _medicationType = medicationType;
              });
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(_medicationType == medicationType ? const Color(0xFFD9D9D9) : Color(greyLight)),
            ),
          ),
        ),
      );
    }).toList();
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
                Text('1 of 2', style: TextStyle(fontSize: 16, color: Colors.grey)),
                Text('Add Medication', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _getMedicationTypeButtons(),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _getDosageTimeButtons(),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: !_isComplete ?
              ElevatedButton(
                onPressed: (){},
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                  backgroundColor:  MaterialStateProperty.all(Color(greyLight)),
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