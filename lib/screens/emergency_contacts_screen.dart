import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyContactsScreen extends StatefulWidget {
  @override
  _EmergencyContactsScreenState createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  List<Map<String, String>> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedContacts = prefs.getStringList("emergency_contacts") ?? [];
    setState(() {
      _contacts = savedContacts.map((c) {
        final parts = c.split("|");
        return {"name": parts[0], "phone": parts[1]};
      }).toList();
    });
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final saveList = _contacts.map((c) => "${c['name']}|${c['phone']}").toList();
    await prefs.setStringList("emergency_contacts", saveList);
  }

  void _addContact() {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) return;
    setState(() {
      _contacts.add({"name": _nameController.text, "phone": _phoneController.text});
      _nameController.clear();
      _phoneController.clear();
    });
    _saveContacts();
  }

  void _deleteContact(int index) {
    setState(() {
      _contacts.removeAt(index);
    });
    _saveContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Emergency Contacts"),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Input fields
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: "Name"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: "Phone"),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle, color: Colors.green, size: 32),
                  onPressed: _addContact,
                )
              ],
            ),
            SizedBox(height: 20),

            // List of contacts
            Expanded(
              child: _contacts.isEmpty
                  ? Center(child: Text("No contacts added yet"))
                  : ListView.builder(
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) {
                        final contact = _contacts[index];
                        return Card(
                          child: ListTile(
                            title: Text(contact["name"] ?? ""),
                            subtitle: Text(contact["phone"] ?? ""),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteContact(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
