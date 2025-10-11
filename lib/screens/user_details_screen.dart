import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_screen.dart';

class UserDetailsScreen extends StatefulWidget {
  final String userType;

  UserDetailsScreen({required this.userType});

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _uploadController =
      TextEditingController(text: 'AadharCard.jpeg');
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();   // ✅ New
  final TextEditingController _countryController = TextEditingController(); // ✅ New

  // Dropdown values
  String _selectedGender = 'Male';
  String _selectedIdType = 'Aadhar Card';

  // Colors
  final Color _accentColor = Color(0xFFB08D7A);
  final Color _focusedBorderColor = Color(0xFFB08D7A);

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _idNumberController.dispose();
    _uploadController.dispose();
    _mobileController.dispose();
    _otpController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _saveUserDetailsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fullName', _fullNameController.text.trim());
    await prefs.setString('dob', _dobController.text.trim());
    await prefs.setString('gender', _selectedGender);
    await prefs.setString('idType', _selectedIdType);
    await prefs.setString('idNumber', _idNumberController.text.trim());
    await prefs.setString('mobile', _mobileController.text.trim());
    await prefs.setString('city', _cityController.text.trim());     // ✅ Save
    await prefs.setString('country', _countryController.text.trim()); // ✅ Save
  }

  Future<void> _saveUserDetailsToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'digitalId': user.uid,
        'fullName': _fullNameController.text.trim(),
        'dob': _dobController.text.trim(),
        'gender': _selectedGender,
        'idType': _selectedIdType,
        'idNumber': _idNumberController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'city': _cityController.text.trim(),
        'country': _countryController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'userType': widget.userType,
      });
    }
  }

  InputDecoration _fieldDecoration({String? hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _focusedBorderColor),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF6600),
              Color(0xFFFFFFFF),
              Color(0xFF00B050),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                SizedBox(height: 30),
                Text(
                  'अतिथि रक्षक',
                  style: TextStyle(
                    fontFamily: 'HindiFont',
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 30),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Enter Your Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 18),

                        // Full Name
                        _label('Full Name'),
                        TextFormField(
                          controller: _fullNameController,
                          decoration: _fieldDecoration(
                              hint: 'Full Name (As per Aadhar)'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Please enter full name'
                              : null,
                        ),
                        SizedBox(height: 16),

                        // DOB + Gender
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('Date of Birth'),
                                  TextFormField(
                                    controller: _dobController,
                                    readOnly: true,
                                    onTap: () async {
                                      DateTime? picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime(2006, 1, 5),
                                        firstDate: DateTime(1950),
                                        lastDate: DateTime.now(),
                                      );
                                      if (picked != null) {
                                        _dobController.text =
                                            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                                      }
                                    },
                                    decoration: _fieldDecoration(
                                      hint: '05/01/2006',
                                      suffix: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Icon(Icons.calendar_today,
                                            color: Colors.grey.shade700),
                                      ),
                                    ),
                                    validator: (v) => (v == null || v.isEmpty)
                                        ? 'Please select date of birth'
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('Gender'),
                                  DropdownButtonFormField<String>(
                                    value: _selectedGender,
                                    decoration: _fieldDecoration(),
                                    items: ['Male', 'Female', 'Other']
                                        .map((g) => DropdownMenuItem(
                                            value: g, child: Text(g)))
                                        .toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedGender = val ?? 'Male';
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // Identity type
                        _label('Select Identity Type'),
                        DropdownButtonFormField<String>(
                          value: _selectedIdType,
                          decoration: _fieldDecoration(hint: 'Aadhar Card'),
                          items: [
                            'Aadhar Card',
                            'Passport',
                            'Driving License',
                            'PAN Card'
                          ]
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedIdType = val ?? 'Aadhar Card';
                            });
                          },
                        ),

                        SizedBox(height: 16),

                        // Identity no
                        _label('Identity No'),
                        TextFormField(
                          controller: _idNumberController,
                          decoration: _fieldDecoration(hint: '1234 5678 1234'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Please enter identity number'
                              : null,
                        ),

                        SizedBox(height: 16),

                        // Upload ID
                        _label('Upload ID Proof'),
                        TextFormField(
                          controller: _uploadController,
                          readOnly: true,
                          decoration: _fieldDecoration(
                            hint: 'AadharCard.jpeg',
                            suffix: GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Upload file functionality to be implemented')),
                                );
                              },
                              child: Icon(Icons.add,
                                  size: 20, color: Colors.grey.shade700),
                            ),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Please upload ID proof'
                                  : null,
                        ),

                        SizedBox(height: 16),

                        // City
                        _label('City'),
                        TextFormField(
                          controller: _cityController,
                          decoration: _fieldDecoration(hint: 'Enter City'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Please enter city'
                              : null,
                        ),
                        SizedBox(height: 16),

                        // Country
                        _label('Country'),
                        TextFormField(
                          controller: _countryController,
                          decoration: _fieldDecoration(hint: 'Enter Country'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Please enter country'
                              : null,
                        ),

                        SizedBox(height: 16),

                        // Mobile + OTP
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('Mobile No'),
                                  TextFormField(
                                    controller: _mobileController,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    decoration: _fieldDecoration(
                                        hint: '9876543210'),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty)
                                        return 'Please enter mobile number';
                                      if (v.trim().length != 10)
                                        return 'Mobile number must be 10 digits';
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('OTP'),
                                  TextFormField(
                                    controller: _otpController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(4),
                                    ],
                                    decoration: _fieldDecoration(hint: '1234'),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Enter OTP'
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 28),

                        // Proceed button -> Save & Go to MainScreen
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await _saveUserDetailsLocally();
                                await _saveUserDetailsToFirestore(); // ✅ Save to Firebase
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MainScreen()),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accentColor,
                              foregroundColor: Colors.black,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              'Proceed',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 130,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
