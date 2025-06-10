import 'package:cmc_travel_app/models/Trip.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class AddTripPage extends StatefulWidget {
  const AddTripPage({super.key});

  @override
  State<AddTripPage> createState() => _AddTripPageState();
}

class _AddTripPageState extends State<AddTripPage> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  final String _bucketName = 'trip-images';

  String? _type;
  // Removed _status variable since it will be automatically set
  DateTime? _date;
  File? _image;
  String? _programUrl;
  bool _isUploading = false;

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _seatsController = TextEditingController();
  final _dateController = TextEditingController();

  final List<DateTime> schoolHolidays = [
    DateTime(2025, 5, 24),
    DateTime(2025, 1, 1),
    DateTime(2025, 4, 20),
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
    DateTime now = DateTime.now();
    DateTime initial = now;

    while (!_isWeekend(initial) && !_isHoliday(initial)) {
      initial = initial.add(const Duration(days: 1));
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
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

  Future<String?> _uploadImage() async {
    if (_image == null) return null;

    try {
      final fileExtension = path.extension(_image!.path);
      final fileName =
          'trip_${DateTime.now().millisecondsSinceEpoch}$fileExtension';

      await _supabase.storage
          .from(_bucketName)
          .upload(
            fileName,
            _image!,
            fileOptions: FileOptions(cacheControl: '3600', upsert: false),
          );

      final imageUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: ${e.toString()}')),
      );
      return null;
    }
  }

  void _downloadProgram() {
    setState(() {
      _programUrl = "https://example.com/program.pdf";
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Program downloaded")));
  }

  Future<void> _publish() async {
  if (!_formKey.currentState!.validate()) return;

  if (_date == null || (!_isWeekend(_date!) && !_isHoliday(_date!))) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Date must be weekend or holiday')),
    );
    return;
  }

  setState(() {
    _isUploading = true;
  });

  try {
    String? imageUrl;
    if (_image != null) {
      imageUrl = await _uploadImage();
      if (imageUrl == null) return;
    }

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication required')),
      );
      return;
    }

    await _supabase.from('Voyage').insert({
      'title': _titleController.text,
      'description': _descController.text,
      'type': _type!,
      'date': _date!.toIso8601String(),
      'price_per_person': double.parse(_priceController.text),
      'nbr_places': int.parse(_seatsController.text),
      'status': 'en_cours', // Automatically set to 'en_cours'
      'image_url': imageUrl,
      'program_url': _programUrl,
      'organizer_id': userId,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Trip published successfully!")),
    );

    // Clear the form
    _formKey.currentState!.reset();
    setState(() {
      _image = null;
      _date = null;
      _type = null;
      // Removed _status = null since we're not using it anymore
      _programUrl = null;
      _titleController.clear();
      _descController.clear();
      _priceController.clear();
      _seatsController.clear();
      _dateController.clear();
    });

    // Navigate back to home page
    if (mounted) {
      Navigator.pop(context);
    }

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Publishing failed: ${e.toString()}')),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isUploading = false;
      });
    }
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
                    if (value == null || value.isEmpty) return 'Required';
                    if (_date == null ||
                        (!_isWeekend(_date!) && !_isHoliday(_date!))) {
                      return 'Must be weekend or holiday';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
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
                // Removed the Status dropdown section completely
                const SizedBox(height: 20),
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _publish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                      ), // Adjust padding if needed
                    ),
                    child:
                        _isUploading
                            ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            )
                            : const Text("Publish"),
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