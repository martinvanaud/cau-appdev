import 'package:flutter/material.dart';

enum MealTime {
  nevermind,
  beforeMeals,
  duringMeals,
  afterMeals,
}

class AddMedicationPage extends StatelessWidget {
  AddMedicationPage({super.key});
  MealTime? _mealTime;
  final bool _isComplete = true;

  List<Widget> _getMealTimeButtons() {
    return MealTime.values.map((mealTime) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
        onPressed: () {
          _mealTime = mealTime;
        },
        child: Text(_getMealTimeText(mealTime), style: const TextStyle(fontSize: 20)),
        ),
      );
    }).toList();
  }

  String _getMealTimeText(MealTime mealTime) {
    switch (mealTime) {
      case MealTime.nevermind:
        return 'Nevermind';
      case MealTime.beforeMeals:
        return 'Before Meals';
      case MealTime.duringMeals:
        return 'During Meals';
      case MealTime.afterMeals:
        return 'After Meals';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Add medication'),
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text('Add medication'),
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
              children: _getMealTimeButtons(),
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