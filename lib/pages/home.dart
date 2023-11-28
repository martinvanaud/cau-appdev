import 'package:flutter/material.dart';
import 'package:medi_minder/entity/schedule.dart';
import 'package:medi_minder/pages/addmedication.dart';

// Provider
import 'package:provider/provider.dart';
import 'package:medi_minder/providers/medication.dart';

// Collection
import 'package:collection/collection.dart';

// Date Handling
import 'package:intl/intl.dart';

// Math computing
import 'dart:math' as math;

// Medication
import 'package:medi_minder/entity/medication.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final String name = "Sasha"; // Name variable

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: HomeHeader(name: name),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: MedicationPlanProgress(percentage: 73),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: GetVaccinated(),
                    ),
                  ],
                ),
              ),
            ),
            MedicationSchedule(), // No changes needed here
          ],
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
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
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
  final String duration;

  const MedicationCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.duration,
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
                      "$subtitle for $duration days",
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
  const MedicationSchedule({super.key});

  @override
  Widget build(BuildContext context) {
    List<Medication> medications =
        context.watch<MedicationProvider>().medications;

    var groupedMedications = groupBy<Medication, Schedule>(
      medications,
      (med) => med.dosages.map((dosage) => dosage.timeOfDay).reduce((a, b) =>
          a.hour == b.hour
              ? (a.minute < b.minute ? a : b)
              : (a.hour < b.hour ? a : b)),
    );

    List<Widget> scheduleWidgets = [];
    groupedMedications.forEach((schedule, meds) {
      meds.sort((a, b) => a.duration.compareTo(b.duration));

      scheduleWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            '${schedule.hour.toString().padLeft(2, '0')}:${schedule.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      );

      scheduleWidgets.addAll(
        meds.map(
          (med) => Padding(
            padding: const EdgeInsets.only(bottom: 20.0, left: 16, right: 16),
            child: MedicationCard(
              imagePath: ('assets/medication/${med.type.name}.png'),
              title: med.name,
              subtitle: '${med.dosages[0].numberOfItems.toString()} ${med.type.name}',
              duration: med.duration.toString(),
            ),
          ),
        ),
      );
    });

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return scheduleWidgets[index];
        },
        childCount: scheduleWidgets.length,
      ),
    );
  }
}
