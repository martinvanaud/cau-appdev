import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:medi_minder/entity/profile.dart';

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
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

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
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text(
                      'Error: ${snapshot.error}'); // Handle error scenario
                } else {
                  // Data is available, use snapshot.data
                  Profile? userProfile = snapshot.data;
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: HomeHeader(
                            name: userProfile?.username ??
                                'User'), // Use null-aware operator
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: MedicationPlanProgress(percentage: 73),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
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
          onPressed: () async {
            User? user = _auth.currentUser;
            if (user != null) {
              // Here we have the UID, which we can use as the document ID
              String uid = user.uid;

              // Reference to the user's document in the 'medication' collection
              DocumentReference userDoc =
                  _firestore.collection('users').doc(uid);

              // Now, create a sub-collection under the user's document for medications
              CollectionReference userMedications =
                  userDoc.collection('medications');

              // Set the initial data for the user's document
              await userMedications.add({
                'type': 'cachet',
                'name': 'Madragol',
                'dosages': [
                  {
                    'numberOfItems': 3,
                    'timeOfDay': {'hour': "8", 'minute': "30"},
                    'timing': 'afterMeal',
                  }
                ],
                'duration': 3,
                'notificationsEnabled': false,
              });
            }
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
  @override
  Widget build(BuildContext context) {
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
                  CircleProgressPainter(percentage: widget.percentage),
              child: Container(
                width: 80,
                height: 75 + 50,
                child: Center(
                    child: Text(
                  '${widget.percentage}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.green,
                  ),
                )),
              ),
            ),
          ),
          const Positioned(
            left: 20,
            top: 10,
            child: Text(
              'Your plan is\nalmost done!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Colors.black,
              ),
            ),
          ),
          const Positioned(
            left: 20,
            bottom: 10,
            child: Text(
              '13% than week ago',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CircleProgressPainter extends CustomPainter {
  int percentage;

  CircleProgressPainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    Paint greyPaint = Paint()
      ..strokeWidth = 11
      ..color = Colors.green.shade100
      ..style = PaintingStyle.stroke;

    Paint progressPaint = Paint()
      ..strokeWidth = 11
      ..color = Colors.green
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
          return ListView.builder(
            itemCount: medications.length,
            itemBuilder: (context, index) {
              Medication medication = medications[index];
              return Dismissible(
                key: Key(medication.id),
                onDismissed: (direction) {
                  _medicationProvider.removeUserMedication(user.uid, medication.id);
                },
                background: Container(
                  color: Colors.white,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(left: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.check, color: Colors.black),
                  ),
                ),
                secondaryBackground: Container(
                  color: Colors.white,
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(right: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.check, color: Colors.black),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: MedicationCard(
                    imagePath: 'assets/medication/${medication.type.name}.png',
                    title: medication.name,
                      subtitle: ''
                          '${medication.dosages[0].numberOfItems} ${(medication.dosages[0].numberOfItems > 1 ? '${medication.type.name}s' : medication.type.name)} '
                          '${(medication.dosages[0].timing.name == 'whenever' ? '' : medication.dosages[0].timing.name == 'afterMeal' ? "after meals " : "before meals")}'
                          'for ${medication.duration} ${(medication.duration > 1 ? "days" : "day")}',
                  ),
                ),
              );

              // return Dismissible(
              //   key: Key(medication.id),
              //   onDismissed: (direction) {
              //     _medicationProvider.removeUserMedication(user.uid, medication.id);
              //   },
              //   background: Container(color: Colors.red),
              //   child: Padding(
              //     padding: const EdgeInsets.only(bottom: 8.0),
              //     child: MedicationCard(
              //       imagePath: 'assets/medication/${medication.type.name}.png',
              //       title: medication.name,
              //       subtitle: ''
              //         '${medication.dosages[0].numberOfItems} ${(medication.dosages[0].numberOfItems > 1 ? '${medication.type.name}s' : medication.type.name)} '
              //         '${(medication.dosages[0].timing.name == 'whenever' ? '' : medication.dosages[0].timing.name == 'afterMeal' ? "after meals " : "before meals ")}'
              //         'for ${medication.duration} ${(medication.duration > 1 ? "days" : "day")}',
              //     ),
              //   ),
              // );
            },
          );
        } else {
          return const Text('No medications found');
        }
      },
    );
  }
}

// class MedicationSchedule extends StatelessWidget {
//   MedicationSchedule({super.key});
//
//   final _auth = FirebaseAuth.instance;
//   final MedicationProvider _medicationProvider = MedicationProvider();
//
//   @override
//   Widget build(BuildContext context) {
//     User? user = _auth.currentUser;
//     if (user == null) {
//       return const Text('User not authenticated');
//     }
//
//     return StreamBuilder<List<Medication>>(
//       stream: _medicationProvider.getUserMedicationsStream(user.uid),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const CircularProgressIndicator();
//         } else if (snapshot.hasError) {
//           return Text('Error: ${snapshot.error}');
//         } else if (snapshot.hasData) {
//           List<Medication> medications = snapshot.data!;
//           return ListView.builder(
//             itemCount: medications.length,
//             itemBuilder: (context, index) {
//               Medication medication = medications[index];
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 8.0), // Adjust the padding as needed
//                 child: MedicationCard(
//                   imagePath: 'assets/medication/${medication.type.name}.png',
//                   title: medication.name,
//                   subtitle: ''
//                       '${medication.dosages[0].numberOfItems} ${(medication.dosages[0].numberOfItems > 1 ? '${medication.type.name}s' : medication.type.name)} '
//                       '${(medication.dosages[0].timing.name == 'whenever' ? '' : medication.dosages[0].timing.name == 'afterMeal' ? "after meals " : "before meals ")}'
//                       'for ${medication.duration} ${(medication.duration > 1 ? "days" : "day")}',
//                 ),
//               );
//             },
//           );
//         } else {
//           return const Text('No medications found');
//         }
//       },
//     );
//   }
// }
