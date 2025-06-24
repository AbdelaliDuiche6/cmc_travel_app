import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

class EditTripPage extends StatefulWidget {
  final Map<String, dynamic> trip;
  
  const EditTripPage({super.key, required this.trip});

  @override
  State<EditTripPage> createState() => _EditTripPageState();
}

class _EditTripPageState extends State<EditTripPage> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  final String _bucketName = 'trip-images';
  final String _programBucketName = 'trip-files';

  String? _type;
  DateTime? _date;
  File? _image;
  File? _programFile;
  bool _isUploading = false;
  bool _imageChanged = false;
  bool _programChanged = false;

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _seatsController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize form fields with trip data
    _titleController.text = widget.trip['title'] ?? '';
    _descController.text = widget.trip['description'] ?? '';
    _type = widget.trip['type'];
    _priceController.text = widget.trip['price_per_person']?.toString() ?? '';
    _seatsController.text = widget.trip['nbr_places']?.toString() ?? '';
    
    if (widget.trip['date'] != null) {
      _date = DateTime.parse(widget.trip['date']);
      _dateController.text = DateFormat('yyyy-MM-dd').format(_date!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _seatsController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _date = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _imageChanged = true;
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
          _programChanged = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting PDF: ${e.toString()}')),
      );
    }
  }

  Future<String?> _uploadImage() async {
    if (_image == null) return null;

    try {
      final fileExtension = path.extension(_image!.path);
      final fileName = 'trip_${DateTime.now().millisecondsSinceEpoch}$fileExtension';

      await _supabase.storage
          .from(_bucketName)
          .upload(
            fileName,
            _image!,
            fileOptions: FileOptions(cacheControl: '3600', upsert: false),
          );

      return _supabase.storage.from(_bucketName).getPublicUrl(fileName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: ${e.toString()}')),
      );
      return null;
    }
  }

  Future<String?> _uploadPDF() async {
    if (_programFile == null) return null;

    try {
      final fileName = 'program_${DateTime.now().millisecondsSinceEpoch}.pdf';

      await _supabase.storage
          .from(_programBucketName)
          .upload(
            fileName,
            _programFile!,
            fileOptions: FileOptions(cacheControl: '3600', upsert: false),
          );

      return _supabase.storage.from(_programBucketName).getPublicUrl(fileName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF upload failed: ${e.toString()}')),
      );
      return null;
    }
  }

  Future<void> _submitChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
    });

    try {
      String? imageUrl;
      if (_imageChanged && _image != null) {
        imageUrl = await _uploadImage();
      } else {
        imageUrl = widget.trip['image_url'];
      }

      String? programUrl;
      if (_programChanged && _programFile != null) {
        programUrl = await _uploadPDF();
      } else {
        programUrl = widget.trip['program_url'];
      }

      final updateData = {
        'title': _titleController.text,
        'description': _descController.text,
        'type': _type,
        'date': _date?.toIso8601String(),
        'price_per_person': double.parse(_priceController.text),
        'nbr_places': int.parse(_seatsController.text),
        'free_places': int.parse(_seatsController.text) - 
                      (widget.trip['nbr_places'] - (widget.trip['free_places'] ?? 0)),
        'status': 'en_cours', // Reset status to pending when resubmitting
        if (imageUrl != null) 'image_url': imageUrl,
        if (programUrl != null) 'program_url': programUrl,
      };

      await _supabase
          .from('Voyage')
          .update(updateData)
          .eq('id', widget.trip['id']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Trip updated and resubmitted for approval!")),
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: ${e.toString()}')),
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
    final isRejected = widget.trip['status']?.toLowerCase() == 'rejected';
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(35),
      borderSide: const BorderSide(width: 2.0, color: Colors.black),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Trip"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isRejected)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "This trip was rejected by admin. Please make necessary changes and resubmit.",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black45, width: 2.0),
                        borderRadius: BorderRadius.circular(20),
                        image: _image != null
                            ? DecorationImage(
                                image: FileImage(_image!),
                                fit: BoxFit.cover,
                              )
                            : widget.trip['image_url'] != null
                                ? DecorationImage(
                                    image: NetworkImage(widget.trip['image_url']),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                      ),
                      child: _image == null && widget.trip['image_url'] == null
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
                  validator: (value) =>
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
                  validator: (value) =>
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
                  items: ['City', 'Event', 'Sport']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  validator: (value) =>
                      value == null ? 'Please select a type' : null,
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
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
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
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
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
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                ListTile(
                  title: Text(
                    _programFile != null
                        ? path.basename(_programFile!.path)
                        : widget.trip['program_url'] != null
                            ? path.basename(widget.trip['program_url'])
                            : 'Select PDF Program',
                  ),
                  trailing: const Icon(Icons.attach_file),
                  onTap: _pickPDF,
                ),
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _submitChanges,
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
                        : const Text("Save Changes", style: TextStyle(fontSize: 16)),
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