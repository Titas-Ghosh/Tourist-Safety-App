import 'package:flutter/material.dart';

class UserTypeSelectionScreen extends StatefulWidget {
  @override
  _UserTypeSelectionScreenState createState() =>
      _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends State<UserTypeSelectionScreen> {
  String selectedUserType = 'Indian Citizen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity, // ✅ ensures full screen coverage
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF6600), // Orange
              Color(0xFFFFFFFF), // White
              Color(0xFF00B050), // Green
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 80),

              // Title
              Text(
                'अतिथि रक्षक',
                style: TextStyle(
                  fontFamily: 'HindiFont',
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 120),

              // White Card
              Container(
                margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Select User Type',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 40),

                    // User Type Options
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedUserType = 'Indian Citizen';
                              });
                            },
                            child: userTypeCard(
                              title: 'Indian Citizen',
                              selected: selectedUserType == 'Indian Citizen',
                              icon: Icons.person,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedUserType = 'Foreign Tourist';
                              });
                            },
                            child: userTypeCard(
                              title: 'Foreign Tourist',
                              selected: selectedUserType == 'Foreign Tourist',
                              icon: Icons.person,
                              withBadge: true,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 60),

                    // Proceed Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/language-selection',
                            arguments: selectedUserType,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Text(
                          'Proceed',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Bottom Black Bar
                    Container(
                      width: 130,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget userTypeCard({
    required String title,
    required bool selected,
    required IconData icon,
    bool withBadge = false,
  }) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        border: Border.all(
          color: selected ? Colors.blue : Colors.grey.shade300,
          width: selected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: selected ? Colors.blue.shade50 : Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              if (withBadge)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 15,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Container(
                      margin: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
