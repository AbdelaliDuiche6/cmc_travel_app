import 'package:cmc_travel_app/models/Trip.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddTripPage extends StatefulWidget {
  const AddTripPage({super.key});

  @override
  State<AddTripPage> createState() => _AddTripPageState();
}

class _AddTripPageState extends State<AddTripPage> {
  final _formKey = GlobalKey<FormState>();

  String? _type;
  String? _status;
  DateTime? _date;
  File? _image;
  String? _programUrl;

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _seatsController = TextEditingController();
  final _dateController = TextEditingController();

  // Hardcoded list of school holidays (example)
  final List<DateTime> schoolHolidays = [
    DateTime(2025, 5, 24),
    DateTime(2025, 1, 1),
    DateTime(2025, 4, 20),
    // Add your holiday dates here
  ];

  bool _isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  bool _isHoliday(DateTime date) {
    return schoolHolidays.any(
      (holiday) =>
          holiday.year == date.year &&
          holiday.month == date.month &&
          holiday.day == date.day,
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      selectableDayPredicate: (date) => _isWeekend(date) || _isHoliday(date),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  void _downloadProgram() {
    setState(() {
      _programUrl = "https://example.com/program.pdf"; // Placeholder
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Program downloaded")));
  }

  void _publish() {
    if (_formKey.currentState!.validate()) {
      print("Selected date: $_date");
      print("Is weekend? ${_date != null ? _isWeekend(_date!) : 'null date'}");
      print("Is holiday? ${_date != null ? _isHoliday(_date!) : 'null date'}");

      if (_date == null || (!_isWeekend(_date!) && !_isHoliday(_date!))) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Selected date must be a weekend or a school holiday',
            ),
          ),
        );
        return; // Stop publishing
      }

      final String organizerId = "current-user-id-123"; // Simulated user ID

      final trip = Trip(
        title: _titleController.text,
        description: _descController.text,
        type: _type!,
        date: _date!,
        price: _priceController.text,
        seats: _seatsController.text,
        status: _status!,
        image: _image,
        programUrl: _programUrl,
        organizerId: organizerId,
      );

      print("Trip Published: ${trip.title}");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Trip Published (simulated)")),
      );

      // TODO: Submit trip data to backend
    }
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(35),
      borderSide: const BorderSide(width: 2.0, color: Colors.black),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Create Trip")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Picker
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black45, width: 2.0),
                        borderRadius: BorderRadius.circular(20),
                        image:
                            _image != null
                                ? DecorationImage(
                                  image: FileImage(_image!),
                                  fit: BoxFit.cover,
                                )
                                : null,
                      ),
                      child:
                          _image == null
                              ? const Icon(Icons.camera_alt_outlined, size: 40)
                              : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: "Title",
                    border: border,
                    enabledBorder: border,
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // Description
                TextFormField(
                  controller: _descController,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: border,
                    enabledBorder: border,
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // Type Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Type",
                    border: border,
                    enabledBorder: border,
                  ),
                  value: _type,
                  onChanged: (value) => setState(() => _type = value),
                  items:
                      [
                            'City/site tour',
                            'Event/Festival',
                            'Sports/Cultural activity',
                          ]
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                  validator:
                      (value) => value == null ? 'Please select a type' : null,
                ),

                const SizedBox(height: 12),

                // Start Date
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Date",
                    border: border,
                    enabledBorder: border,
                  ),
                  onTap: _pickDate,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (_date == null ||
                        (!_isWeekend(_date!) && !_isHoliday(_date!))) {
                      return 'Date must be a weekend or school holiday';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Price and Seats
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: "Price",
                          border: border,
                          enabledBorder: border,
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _seatsController,
                        decoration: InputDecoration(
                          labelText: "Seats",
                          border: border,
                          enabledBorder: border,
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Status Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Status",
                    border: border,
                    enabledBorder: border,
                  ),
                  value: _status,
                  onChanged: (value) => setState(() => _status = value),
                  items:
                      ['Published', 'In Progress', 'Finished']
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                  validator:
                      (value) =>
                          value == null ? 'Please select a status' : null,
                ),
                const SizedBox(height: 20),

                // Download Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _downloadProgram,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Download Program"),
                  ),
                ),
                const SizedBox(height: 20),

                // Publish Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _publish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Publish"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
