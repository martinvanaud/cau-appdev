import 'package:flutter/material.dart';

// Entities
import 'package:medi_minder/entity/medication.dart';

// Enums
import 'package:medi_minder/enums/dosage.dart';
import 'package:medi_minder/enums/medication.dart';

// Pages
import 'home.dart';

class AddMedicationPage extends StatefulWidget {
  const AddMedicationPage({super.key});

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  final greyLight = 0xFFF4F4F5;
  DosageTiming? _dosageTime;
  MedicationType? _medicationType;
  String _medicineName = '';
  String _dosage = '';
  bool _isMedicationShortTerm = false;
  DateTime? _selectedDate;

  Widget _getDosageTimeButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: DosageTiming.values.map((dosageTime) {
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
            child: Text(_getDosageTimeText(dosageTime), style: TextStyle(fontSize: 20,fontWeight: _dosageTime == dosageTime ? FontWeight.bold : FontWeight.normal))),
          );
        }).toList(),
      ),
    );
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
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
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

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 100),
    ).then((selectedDate) {
      setState(() {
        _selectedDate = selectedDate!;
      });
    });
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
      floatingActionButtonLocation:
        FloatingActionButtonLocation.centerFloat,
        resizeToAvoidBottomInset: false,
      floatingActionButton: Container(
        height: 50,
        margin: const EdgeInsets.all(10),
        child: ElevatedButton(
            onPressed: () {
              setState(() {
                if (_formKey.currentState!.validate() && _dosageTime != null && _medicationType != null) {
                  _formKey.currentState!.save();
                  Medication medication = Medication(
                    name: _medicineName,
                    type: _medicationType!,
                    dosages: [],
                    duration: 0,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddMedicationSchedulePage(),
                      settings: RouteSettings(
                        arguments: medication,
                      ),
                    )
                  );
                }
              });
            },
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo),
            ),
            child: const Center(child: Text('Next', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          ),
      ),
      body: Form(
        key:_formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('1 of 2', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const Text('Add Medication', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _getMedicationTypeButtons(),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                  hintText: 'e.g. Aspirin',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Medication name is required.';
                  }
                  return null;
                },
                onSaved: (name) {
                  setState(() {
                    _medicineName = name!;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Single dose intake',
                  hintText: 'e.g. 1 tablet',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Dosage is required.';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Dosage must be a number.';
                  }
                  return null;
                },
                onSaved: (dosage) {
                  setState(() {
                    _dosage = dosage!;
                  });
                },
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              _getDosageTimeButtons(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Short term intake?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Switch(
                    value: _isMedicationShortTerm,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Color(greyLight),
                    onChanged: (bool value) {
                      setState(() {
                        _isMedicationShortTerm = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 16
              ),
              _isMedicationShortTerm ?
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Take Medicine untill', style: TextStyle(fontSize: 20)),
                  MaterialButton(
                    onPressed: _showDatePicker,
                    child: Text(_selectedDate == null ? 'Select a Date' : '${_selectedDate?.year}-${_selectedDate?.month}-${_selectedDate?.day}', style: const TextStyle(fontSize: 20)),
                  ),
                ],
              )
              :
              const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

class AddMedicationSchedulePage extends StatefulWidget {
  const AddMedicationSchedulePage({super.key});

  @override
  State<AddMedicationSchedulePage> createState() => _AddMedicationSchedulePageState();
}

class _AddMedicationSchedulePageState extends State<AddMedicationSchedulePage> {
  final greyLight = 0xFFF4F4F5;
  final List<int> _reminderTimes = [5, 10, 30, 60, 90, 120, 180, 240];
  TimeOfDay _timeOfDay = TimeOfDay.now();
  bool _addReminder = false;
  bool _isComplete = false;
  int _reminderTime = 0;

  Widget _showDosageIntakes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Dose 1', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              showTimePicker(
                context: context,
                initialTime: _timeOfDay,
                initialEntryMode: TimePickerEntryMode.dial,
              ).then((time) {
                if (time != null) {
                  setState(() {
                    _timeOfDay = time;
                  });
                }
              });
            },
            child: Text('${_timeOfDay.hour.toString().padLeft(2, '0')}:${_timeOfDay.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _getReminderOptions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _reminderTimes.map((reminderTime) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
            onPressed: () {
              setState(() {
                _reminderTime = reminderTime;
              });
            },
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(_reminderTime == reminderTime ? Colors.black : Colors.grey),
              backgroundColor: MaterialStateProperty.all<Color>(_reminderTime == reminderTime ? Color(greyLight) : Colors.white),
            ),
            child: Text('$reminderTime min', style: TextStyle(fontSize: 20, fontWeight: _reminderTime == reminderTime ? FontWeight.bold : FontWeight.normal))),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Medication medication = ModalRoute.of(context)?.settings.arguments as Medication;

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage())),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        )
      ),
      floatingActionButtonLocation:
        FloatingActionButtonLocation.centerFloat,
        resizeToAvoidBottomInset: false,
      floatingActionButton: Container(
        height: 50,
        margin: const EdgeInsets.all(10),
        child: !_isComplete ?
          ElevatedButton(
            onPressed: (){},
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.grey),
              backgroundColor:  MaterialStateProperty.all(Color(greyLight)),
            ),
            child: const Center(child: Text("Add medication times", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          )
          :
          ElevatedButton(
            onPressed: () {},
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo),
            ),
            child: const Center(child: Text('Next', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('2 of 2', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const Text('Schedule', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 4,
                      height: 60,
                      child: Container(
                        color: Color(greyLight),
                      ),
                    ),
                    Image.asset(
                      'assets/medication/${medication.type.name}.png',
                      height: 100,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(medication.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('${medication.type.name}, medication.dosageTiming', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16
                ),
                _showDosageIntakes(),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add',
                  iconSize: 25,
                  style: ButtonStyle(
                    backgroundColor:  MaterialStateProperty.all(Color(greyLight)),
                  ),
                  onPressed: () {},
                ),
                const SizedBox(
                  height: 16
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Reminders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Switch(
                      value: _addReminder,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Color(greyLight),
                      onChanged: (bool value) {
                        setState(() {
                          _addReminder = value;
                        });
                      },
                    ),
                  ],
                ),
                _addReminder ? _getReminderOptions() : const SizedBox.shrink(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}