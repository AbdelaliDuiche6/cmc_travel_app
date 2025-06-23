import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class EditTripPage extends StatefulWidget {
  final Map<String, dynamic> trip;

  const EditTripPage({super.key, required this.trip});

  @override
  _EditTripPageState createState() => _EditTripPageState();
}

class _EditTripPageState extends State<EditTripPage> {
  final _formKey = GlobalKey<FormState>();
  final String _bucketName = 'trip-images';
  final String _programBucketName = 'trip-files';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  DateTime? _selectedDate;
  File? _image;
  File? _programFile;
  String? _type;
  bool _isUploading = false;
  String? _currentPdfName;

  final List<String> _types = [
    'City',
    'Event',
    'Sport',
  ];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.trip['title'] ?? '';
    _descriptionController.text = widget.trip['description'] ?? '';
    _type = widget.trip['type'];
    _priceController.text = widget.trip['price_per_person']?.toString() ?? '';
    _seatsController.text = widget.trip['nbr_places']?.toString() ?? '';
    _selectedDate = DateTime.tryParse(widget.trip['date'] ?? '');
    _dateController.text =
        _selectedDate != null
            ? _selectedDate!.toIso8601String().split('T').first
            : '';
    
    // Extract PDF name from URL if exists
    if (widget.trip['program_url'] != null) {
      String url = widget.trip['program_url'];
      _currentPdfName = url.split('/').last.split('?').first; // Remove query parameters
    }
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

  Future<void> _pickPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _programFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting PDF: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_image == null) return widget.trip['image_url'];

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final fileExtension = path.extension(_image!.path);
      final fileName =
          'trip_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      final userFolder = user.id;

      await Supabase.instance.client.storage
          .from(_bucketName)
          .upload(
            '$userFolder/$fileName',
            _image!,
            fileOptions: FileOptions(cacheControl: '3600', upsert: false),
          );

      return Supabase.instance.client.storage
          .from(_bucketName)
          .getPublicUrl('$userFolder/$fileName');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: ${e.toString()}')),
      );
      return null;
    }
  }

  Future<String?> _uploadPDF() async {
    if (_programFile == null) return widget.trip['program_url'];

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final fileName = 'program_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final userFolder = user.id;

      await Supabase.instance.client.storage
          .from(_programBucketName)
          .upload(
            '$userFolder/$fileName',
            _programFile!,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: false,
              contentType: 'application/pdf',
            ),
          );

      return Supabase.instance.client.storage
          .from(_programBucketName)
          .getPublicUrl('$userFolder/$fileName');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF upload failed: ${e.toString()}')),
      );
      return null;
    }
  }

  Future<void> _updateTrip() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
    });

    try {
      String? imageUrl = await _uploadImage();
      String? programUrl = await _uploadPDF();

      await Supabase.instance.client
          .from('Voyage')
          .update({
            'image_url': imageUrl,
            'title': _titleController.text,
            'description': _descriptionController.text,
            'type': _type,
            'date': _selectedDate?.toIso8601String(),
            'price_per_person': double.tryParse(_priceController.text),
            'nbr_places': int.tryParse(_seatsController.text),
            'program_url': programUrl,
          })
          .eq('id', widget.trip['id']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip updated successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating trip: $e')));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  ImageProvider? _getImageProvider() {
    if (_image != null) {
      return FileImage(_image!);
    } else if (widget.trip['image_url'] != null) {
      return NetworkImage(widget.trip['image_url']);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(35),
      borderSide: const BorderSide(width: 2.0, color: Colors.black),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Trip')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
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
                          _getImageProvider() != null
                              ? DecorationImage(
                                image: _getImageProvider()!,
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        _getImageProvider() == null
                            ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt_outlined, size: 40),
                                SizedBox(height: 8),
                                Text('Tap to select image'),
                              ],
                            )
                            : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: border,
                  enabledBorder: border,
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: border,
                  enabledBorder: border,
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: InputDecoration(
                  labelText: 'Type',
                  border: border,
                  enabledBorder: border,
                ),
                items:
                    _types
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _type = value),
                validator:
                    (value) => value == null ? 'Please select a type' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: border,
                  enabledBorder: border,
                ),
                onTap: _pickDate,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price per Person',
                  border: border,
                  enabledBorder: border,
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _seatsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Seats',
                  border: border,
                  enabledBorder: border,
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // PDF Section - Simplified
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Program PDF',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _programFile != null
                                ? _programFile!.path.split('/').last
                                : _currentPdfName != null
                                    ? _currentPdfName!
                                    : 'No PDF selected',
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _pickPDF,
                        icon: const Icon(Icons.upload_file),
                        label: Text(_programFile != null || _currentPdfName != null
                            ? 'Change PDF'
                            : 'Select PDF'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _updateTrip,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child:
                      _isUploading
                          ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                          : const Text('Save', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}