import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fms_app/services/tank_service.dart';
import 'package:fms_app/models/tank.dart';

class TanksScreen extends StatefulWidget {
  const TanksScreen({super.key});

  @override
  State<TanksScreen> createState() => _TanksScreenState();
}

class _TanksScreenState extends State<TanksScreen> {
  final TankService tankService = TankService();
  List<Tank> tanks = [];
  bool isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchTanks();
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      if (mounted) {
        _fetchTanks();
      }
    });
  }

  Future<void> _fetchTanks() async {
    try {
      final fetchedTanks = await tankService.fetchTanks();
      if (mounted) {
        setState(() {
          tanks = fetchedTanks;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      // Handle error
    }
  }

  @override
  void dispose() {
    // Cancel the timer to prevent memory leaks
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الخزانات'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tanks.isEmpty
          ? const Center(child: Text('No tanks available'))
          : ListView.builder(
        itemCount: tanks.length,
        itemBuilder: (context, index) {
          final tank = tanks[index];
          final double fillPercentage = tank.level / tank.capacity;

          return Card(
            margin: const EdgeInsets.all(12.0),
            child: Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tank.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      Container(
                        height: 30,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Container(
                        height: 30,
                        width: (MediaQuery.of(context).size.width * fillPercentage - 40).clamp(0.0, MediaQuery.of(context).size.width),
                        decoration: BoxDecoration(
                          color: fillPercentage > 0.5
                              ? Colors.green
                              : fillPercentage > 0.2
                              ? Colors.orange
                              : Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'المستوى: ${tank.level}/${tank.capacity} (${(fillPercentage * 100).toStringAsFixed(1)}%)',
                    style: TextStyle(
                      fontSize: 16,
                      color: fillPercentage > 0.5
                          ? Colors.green
                          : fillPercentage > 0.2
                          ? Colors.orange
                          : Colors.red,
                    ),
                  ),
                  if (tank.fuelType != null)
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text('نوع الوقود'),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 3),
                         decoration: BoxDecoration(
                           color: Colors.amber,
                           borderRadius: BorderRadius.circular(6),
                         ),
                         child: Text('${tank.fuelType}'),
                       ),
                     ],
                   )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
