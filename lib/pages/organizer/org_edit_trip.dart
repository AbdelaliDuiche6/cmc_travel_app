import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class EditTripPage extends StatefulWidget {
  final Map<String, dynamic> trip;

  const EditTripPage({Key? key, required this.trip}) : super(key: key);

  @override
  _EditTripPageState createState() => _EditTripPageState();
}

class _EditTripPageState extends State<EditTripPage> {
  final _formKey = GlobalKey<FormState>();
  final String _bucketName = 'trip-images';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  DateTime? _selectedDate;
  File? _image;
  String? _programPath;
  String? _type;
  String? _status;
  bool _isUploading = false;

  final List<String> _types = [
    'City/site tour',
    'Event/Festival',
    'Sports/Cultural activity',
  ];

  final List<String> _statuses = [
    'Published',
    'Available',
    'Closed',
    'Pending',
    'rejected',
    'accepted',
    'en_cours',
  ];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.trip['title'] ?? '';
    _descriptionController.text = widget.trip['description'] ?? '';
    _type = widget.trip['type'];
    _status = widget.trip['status'];
    _priceController.text = widget.trip['price_per_person']?.toString() ?? '';
    _seatsController.text = widget.trip['seats']?.toString() ?? '';
    _programPath = widget.trip['program'];

    _selectedDate = DateTime.tryParse(widget.trip['date'] ?? '');
    _dateController.text = _selectedDate != null
        ? _selectedDate!.toIso8601String().split('T').first
        : '';

    final imgPath = widget.trip['img'];
    if (imgPath != null && File(imgPath).existsSync()) {
      _image = File(imgPath);
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
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        _programPath = result.files.single.path;
      });
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

  Future<void> _updateTrip() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final imageUrl = await _uploadImage();
      if (imageUrl == null && _image != null) return;

      await Supabase.instance.client.from('Voyage').update({
        'image_url': imageUrl,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'type': _type,
        'date': _selectedDate?.toIso8601String().split('T').first,
        'price_per_person': double.tryParse(_priceController.text),
        'nbr_places': int.tryParse(_seatsController.text),
        'status': _status,
        'program_url': _programPath,
      }).eq('id', widget.trip['id']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip updated successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating trip: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_image == null) return widget.trip['image_url'];

    try {
      final fileExtension = path.extension(_image!.path);
      final fileName = 'trip_${DateTime.now().millisecondsSinceEpoch}$fileExtension';

      await Supabase.instance.client.storage
          .from(_bucketName)
          .upload(fileName, _image!);

      final imageUrl = Supabase.instance.client.storage
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
                      image: _getImageProvider() != null
                          ? DecorationImage(
                              image: _getImageProvider()!,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _getImageProvider() == null
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
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: InputDecoration(
                  labelText: 'Type',
                  border: border,
                  enabledBorder: border,
                ),
                items: _types
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() => _type = value),
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
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: border,
                  enabledBorder: border,
                ),
                items: _statuses
                    .map((status) =>
                        DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) => setState(() => _status = value),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  _programPath == null
                      ? 'Select PDF Program'
                      : _programPath!.split('/').last,
                ),
                trailing: const Icon(Icons.attach_file),
                onTap: _pickPDF,
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
                  child: _isUploading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
