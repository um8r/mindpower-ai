import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/theme/app_theme.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({Key? key}) : super(key: key);

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedService = "Aura Cleansing";
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 15, minute: 0);

  List<dynamic> _availableTherapists = [];
  Map<String, dynamic>? _selectedTherapist;
  bool _isLoadingTherapists = true;

  final List<String> _servicesList = [
    "Aura Cleansing",
    "Mind Power & Alpha Therapy",
    "Consultation with Expert",
    "Psychological Counseling",
    "Remote Psychological Healing",
  ];

  @override
  void initState() {
    super.initState();
    _fetchRegisteredTherapists();
  }

  Future<void> _fetchRegisteredTherapists() async {
    try {
      final response = await http.get(Uri.parse("http://127.0.0.1:8080/api/v1/therapists"));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _availableTherapists = data['therapists'] ?? [];
          if (_availableTherapists.isNotEmpty) {
            _selectedTherapist = _availableTherapists[0];
          }
          _isLoadingTherapists = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching therapists: $e");
      if (!mounted) return;
      setState(() {
        _isLoadingTherapists = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitAppointment() async {
    if (_selectedTherapist == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Baraye meharbani pehle koi therapist select karein!")),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      String name = _nameController.text.trim();
      String email = _emailController.text.trim();
      String notes = _notesController.text.trim();
      String doctorName = _selectedTherapist!['full_name'] ?? 'Doctor';
      String doctorEmail = _selectedTherapist!['email'] ?? '';
      String dateStr = "${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day} at ${_selectedTime.format(context)}";

      try {
        final response = await http.post(
          Uri.parse("http://127.0.0.1:8080/api/v1/appointments/book"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "patient_email": email,
            "patient_name": name,
            "therapist_email": doctorEmail,
            "therapist_name": doctorName,
            "appointment_date": dateStr,
            "notes": "$_selectedService: $notes"
          }),
        );

        if (!mounted) return;
        if (response.statusCode == 200) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppTheme.primaryTeal, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    "Appointment Requested!",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
                  ),
                ],
              ),
              content: Text(
                "Aap ki appointment request ($doctorName ke sath $_selectedService) kamyabi ke sath submit ho chuki hai!\n\n"
                "• Doctor ke dashboard par request bhej di gayi hai.",
                style: TextStyle(fontSize: 13, color: AppTheme.getTextMuted(context)),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text("OK", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to book appointment. Please try again.")),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Book an Appointment",
          style: TextStyle(color: AppTheme.getDeepSlate(context), fontWeight: FontWeight.bold),
        ),
        elevation: 0.5,
      ),
      body: _isLoadingTherapists
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Schedule Your Healing Session",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Select your preferred registered doctor and fill out the details below.",
                      style: TextStyle(fontSize: 12, color: AppTheme.getTextMuted(context)),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Select Available Therapist / Doctor",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.getDeepSlate(context)),
                    ),
                    const SizedBox(height: 8),
                    _availableTherapists.isEmpty
                        ? Text("No registered therapists available right now.", style: TextStyle(color: AppTheme.getTextMuted(context)))
                        : Column(
                            children: _availableTherapists.map((therapist) {
                              final bool isSelected = _selectedTherapist?['email'] == therapist['email'];
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTherapist = therapist;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primaryTeal.withOpacity(0.1)
                                        : Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected ? AppTheme.primaryTeal : Colors.grey.withOpacity(0.3),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 24,
                                        backgroundColor: AppTheme.primaryTeal,
                                        child: Icon(Icons.person_rounded, color: Colors.white, size: 26),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              therapist['full_name'] ?? 'Doctor',
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              therapist['specialization'] ?? 'Mind Science Expert',
                                              style: TextStyle(fontSize: 11, color: AppTheme.getTextMuted(context)),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              therapist['fee'] ?? 'PKR 5,000 / Session',
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Radio<String>(
                                        value: therapist['email'],
                                        groupValue: _selectedTherapist?['email'],
                                        activeColor: AppTheme.primaryTeal,
                                        onChanged: (val) {
                                          setState(() {
                                            _selectedTherapist = therapist;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                    const SizedBox(height: 16),
                    Text(
                      "Select Healing Service",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.getDeepSlate(context)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedService,
                          isExpanded: true,
                          dropdownColor: Theme.of(context).cardColor,
                          style: TextStyle(color: AppTheme.getDeepSlate(context), fontSize: 14),
                          items: _servicesList.map((String service) {
                            return DropdownMenuItem<String>(
                              value: service,
                              child: Text(service, style: TextStyle(fontSize: 14, color: AppTheme.getDeepSlate(context))),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedService = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Your Full Name",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.getDeepSlate(context)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(color: AppTheme.getDeepSlate(context)),
                      decoration: InputDecoration(
                        hintText: "Enter your name",
                        hintStyle: TextStyle(color: AppTheme.getTextMuted(context)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      validator: (value) => value!.isEmpty ? "Please enter your name" : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Phone Number / WhatsApp",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.getDeepSlate(context)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: AppTheme.getDeepSlate(context)),
                      decoration: InputDecoration(
                        hintText: "e.g. +92 3103338452",
                        hintStyle: TextStyle(color: AppTheme.getTextMuted(context)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      validator: (value) => value!.isEmpty ? "Please enter your phone number" : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Email Address",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.getDeepSlate(context)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: AppTheme.getDeepSlate(context)),
                      decoration: InputDecoration(
                        hintText: "e.g. user@gmail.com",
                        hintStyle: TextStyle(color: AppTheme.getTextMuted(context)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      validator: (value) => value!.isEmpty ? "Please enter your email" : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Preferred Date",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.getDeepSlate(context)),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () => _selectDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}",
                                        style: TextStyle(fontSize: 13, color: AppTheme.getDeepSlate(context)),
                                      ),
                                      const Icon(Icons.calendar_today_rounded, size: 16, color: AppTheme.primaryTeal),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Preferred Time",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.getDeepSlate(context)),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () => _selectTime(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _selectedTime.format(context),
                                        style: TextStyle(fontSize: 13, color: AppTheme.getDeepSlate(context)),
                                      ),
                                      const Icon(Icons.access_time_rounded, size: 16, color: AppTheme.primaryTeal),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Additional Notes",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.getDeepSlate(context)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      style: TextStyle(color: AppTheme.getDeepSlate(context)),
                      decoration: InputDecoration(
                        hintText: "Briefly describe what you want help with...",
                        hintStyle: TextStyle(color: AppTheme.getTextMuted(context)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitAppointment,
                        icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                        label: const Text(
                          "Confirm & Submit Appointment",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}