import 'package:flutter/material.dart';

import 'package:medi_minder/entity/profile.dart';
import 'package:medi_minder/pages/addmedication.dart';

// Provider
import 'package:medi_minder/providers/medication.dart';

// Collection
import 'package:collection/collection.dart';

// Date Handling
import 'package:intl/intl.dart';

// Math computing
import 'dart:math' as math;

// Medication
import 'package:medi_minder/entity/medication.dart';

// Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stream<Profile?> getUserProfileFuture;

  @override
  void initState() {
    super.initState();
    getUserProfileFuture =
        getUserProfileStream(); // Assign the future in initState
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: StreamBuilder<Profile?>(
              stream: getUserProfileStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text(
                      'Error: ${snapshot.error}'); // Handle error scenario
                } else {
                  // Data is available, use snapshot.data
                  Profile? userProfile = snapshot.data;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: HomeHeader(
                            name: userProfile?.username ??
                                'User'), // Use null-aware operator
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: MedicationPlanProgress(percentage: 5),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: GetVaccinated(),
                      ),
                      Expanded(
                        child: MedicationSchedule(),
                      ),
                    ],
                  );
                }
              }),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 15.0, right: 10.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddMedicationPage()));
          },
          backgroundColor: Colors.blue.shade800,
          shape: const CircleBorder(),
          elevation: 0,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 35.0,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

class HomeHeader extends StatelessWidget {
  final String name;

  const HomeHeader({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Hello, $name!",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14.0,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                DateFormat('EEEE').format(DateTime.now()),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26.0,
                ),
              ),
            ],
          ),
          const Icon(Icons.more_vert),
        ],
      ),
    );
  }
}

class MedicationPlanProgress extends StatefulWidget {
  final int percentage;

  const MedicationPlanProgress({super.key, required this.percentage});

  @override
  State<MedicationPlanProgress> createState() => _MedicationPlanProgressState();
}

class _MedicationPlanProgressState extends State<MedicationPlanProgress> {
  Color _getColorForPercentage(int percentage) {
    if (percentage <= 0) {
      return Colors.red;
    } else if (percentage <= 25) {
      return Colors.orange;
    } else if (percentage <= 50) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }

  Color _getColorForPercentageBackground(int percentage) {
    if (percentage <= 0) {
      return Colors.red.shade100;
    } else if (percentage <= 25) {
      return Colors.orange.shade100;
    } else if (percentage <= 50) {
      return Colors.yellow.shade100;
    } else {
      return Colors.green.shade100;
    }
  }

  String _getMessageForPercentage(int percentage) {
    if (percentage <= 0) {
      return 'Your plan hasn\'t started yet.\nAdd some medication.';
    } else if (percentage < 20) {
      return 'Keep going, your plan is progressing day by day';
    }  else if (percentage < 100) {
      return 'Your plan is\nalmost done!';
    } else {
      return 'Congratulations!\nYou\'ve completed your plan.';
    }
  }

  @override
  Widget build(BuildContext context) {
    Color progressColor = _getColorForPercentage(widget.percentage);
    Color progressColorBackground = _getColorForPercentageBackground(widget.percentage);
    String progressMessage = _getMessageForPercentage(widget.percentage);

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 150,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 20,
            top: 10,
            child: CustomPaint(
              foregroundPainter:
                  CircleProgressPainter(percentage: widget.percentage, color: progressColor, backgroundColor: progressColorBackground),
              child: Container(
                width: 80,
                height: 75 + 50,
                child: Center(
                    child: Text(
                  '${widget.percentage}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: progressColor,
                  ),
                )),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 30,
            width: MediaQuery.of(context).size.width * 0.55, // 80% of the screen width
            child: Text(
              progressMessage,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
              softWrap: true, // Wrap the text onto multiple lines
              overflow: TextOverflow.clip, // Clip the overflowing text
            ),
          ),
        ],
      ),
    );
  }
}

class CircleProgressPainter extends CustomPainter {
  int percentage;
  Color color;
  Color backgroundColor;

  CircleProgressPainter({required this.percentage, required this.color, required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint greyPaint = Paint()
      ..strokeWidth = 11
      ..color = backgroundColor
      ..style = PaintingStyle.stroke;

    Paint progressPaint = Paint()
      ..strokeWidth = 11
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = math.min(size.width / 2, size.height / 2);

    canvas.drawCircle(center, radius, greyPaint);
    double angle = 2 * math.pi * (percentage / 100);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        math.pi * 1.5, angle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class GetVaccinated extends StatelessWidget {
  const GetVaccinated({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          child: Image.asset(
            'assets/get-vaccinated.png',
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }
}

class MedicationCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  const MedicationCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              imagePath,
              width: 60,
              height: 60,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MedicationSchedule extends StatelessWidget {
  MedicationSchedule({super.key});

  final _auth = FirebaseAuth.instance;
  final MedicationProvider _medicationProvider = MedicationProvider();

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    if (user == null) {
      return const Text('User not authenticated');
    }

    return StreamBuilder<List<Medication>>(
      stream: _medicationProvider.getUserMedicationsStream(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          List<Medication> medications = snapshot.data!;
          List<Widget> medicationListItems = _buildMedicationListWithHeaders(medications);

          return ListView(
            children: medicationListItems,
          );
        } else {
          return const Text('No medications found');
        }
      },
    );
  }
}

int timeOfDayToMinutes(TimeOfDay tod) => tod.hour * 60 + tod.minute;

List<Widget> _buildMedicationListWithHeaders(List<Medication> medications) {
  // Sort medications by time first
  medications.sort((a, b) => timeOfDayToMinutes(a.dosages[0].timeOfDay).compareTo(timeOfDayToMinutes(b.dosages[0].timeOfDay)));

  // Group medications by timeOfDay
  var groupedByTime = groupBy(medications, (Medication m) => m.dosages[0].timeOfDay);

  List<Widget> listItems = [];
  groupedByTime.forEach((timeOfDay, medsAtSameTime) {
    // Add time header
    listItems.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      ),
    );

    // Add medication cards
    listItems.addAll(medsAtSameTime.map((medication) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: MedicationCard(
          imagePath: 'assets/medication/${medication.type.name}.png',
          title: medication.name,
          subtitle: ''
              '${medication.dosages[0].numberOfItems} ${(medication.dosages[0].numberOfItems > 1 ? '${medication.type.name}s' : medication.type.name)} '
              '${(medication.dosages[0].timing.name == 'whenever' ? '' : medication.dosages[0].timing.name == 'afterMeal' ? "after meals " : "before meals ")}'
              '${(medication.duration <= 0 ? "today" : medication.duration > 1 ? "for ${medication.duration} days" : "for ${medication.duration} day")}',
        ),
      );
    }).toList());
  });

  return listItems;
}
