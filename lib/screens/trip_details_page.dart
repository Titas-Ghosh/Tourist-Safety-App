import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TripDetailsPage extends StatefulWidget {
  const TripDetailsPage({Key? key}) : super(key: key);

  @override
  State<TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  List<Map<String, String>> _trips = [];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final tripData = prefs.getStringList('trips') ?? [];

    setState(() {
      _trips = tripData.map((t) => Map<String, String>.from(jsonDecode(t))).toList();
    });
  }

  Future<void> _addTrip(Map<String, String> trip) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _trips.add(trip);
    });
    final encodedTrips = _trips.map((t) => jsonEncode(t)).toList();
    await prefs.setStringList('trips', encodedTrips);
  }

  void _showAddTripDialog() {
    final destinationController = TextEditingController();
    final purposeController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add Trip"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: destinationController,
                      decoration: const InputDecoration(labelText: "Destination"),
                    ),
                    TextField(
                      controller: purposeController,
                      decoration: const InputDecoration(labelText: "Purpose"),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() => startDate = picked);
                              }
                            },
                            child: Text(startDate == null
                                ? "Pick Start Date"
                                : "Start: ${startDate!.toLocal()}".split(' ')[0]),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() => endDate = picked);
                              }
                            },
                            child: Text(endDate == null
                                ? "Pick End Date"
                                : "End: ${endDate!.toLocal()}".split(' ')[0]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: const Text("Save"),
                  onPressed: () {
                    if (destinationController.text.isNotEmpty &&
                        startDate != null &&
                        endDate != null) {
                      _addTrip({
                        "destination": destinationController.text,
                        "purpose": purposeController.text,
                        "startDate": startDate!.toIso8601String(),
                        "endDate": endDate!.toIso8601String(),
                      });
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trip Details"),
        backgroundColor: Colors.redAccent,
      ),
      body: _trips.isEmpty
          ? const Center(child: Text("No trips added yet."))
          : ListView.builder(
              itemCount: _trips.length,
              itemBuilder: (context, index) {
                final trip = _trips[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: const Icon(Icons.flight_takeoff, color: Colors.blue),
                    title: Text(trip["destination"] ?? ""),
                    subtitle: Text(
                      "📅 ${trip["startDate"]?.split('T')[0]} → ${trip["endDate"]?.split('T')[0]}\n🎯 ${trip["purpose"] ?? "-"}",
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTripDialog,
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
