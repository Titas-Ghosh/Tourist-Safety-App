import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({Key? key}) : super(key: key);

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  List<Map<String, String>> _complaints = [];

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    final prefs = await SharedPreferences.getInstance();
    final complaintData = prefs.getStringList('complaints') ?? [];

    setState(() {
      _complaints =
          complaintData.map((c) => Map<String, String>.from(jsonDecode(c))).toList();
    });
  }

  Future<void> _addComplaint(Map<String, String> complaint) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _complaints.add(complaint);
    });
    final encoded = _complaints.map((c) => jsonEncode(c)).toList();
    await prefs.setStringList('complaints', encoded);
  }

  void _showAddComplaintDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String category = "General";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Submit Complaint"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: "Title"),
                    ),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: "Description"),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: category,
                      items: const [
                        DropdownMenuItem(value: "General", child: Text("General")),
                        DropdownMenuItem(value: "Safety", child: Text("Safety")),
                        DropdownMenuItem(value: "Harassment", child: Text("Harassment")),
                        DropdownMenuItem(value: "Other", child: Text("Other")),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => category = value);
                        }
                      },
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
                  child: const Text("Submit"),
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty) {
                      _addComplaint({
                        "title": titleController.text,
                        "description": descriptionController.text,
                        "category": category,
                        "date": DateTime.now().toIso8601String(),
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
        title: const Text("Complaints"),
        backgroundColor: Colors.redAccent,
      ),
      body: _complaints.isEmpty
          ? const Center(child: Text("No complaints submitted yet."))
          : ListView.builder(
              itemCount: _complaints.length,
              itemBuilder: (context, index) {
                final complaint = _complaints[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: const Icon(Icons.report_problem, color: Colors.red),
                    title: Text(complaint["title"] ?? ""),
                    subtitle: Text(
                      "📅 ${complaint["date"]?.split('T')[0]}\n"
                      "📂 ${complaint["category"]}\n"
                      "${complaint["description"]}",
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddComplaintDialog,
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
