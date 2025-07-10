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

class _EditTripPageState extends State<EditTripPage>
    with TickerProviderStateMixin {
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

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final List<DateTime> schoolHolidays = [
    DateTime(2025, 5, 24),
    DateTime(2025, 1, 1),
    DateTime(2025, 4, 20),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeFormFields();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  void _initializeFormFields() {
    // Initialize form fields with trip data
    _titleController.text = widget.trip['title'] ?? '';
    _descController.text = widget.trip['description'] ?? '';
    _type = widget.trip['type'];
    _priceController.text = widget.trip['price_per_person']?.toString() ?? '';
    _seatsController.text = widget.trip['nbr_places']?.toString() ?? '';
    
    if (widget.trip['date'] != null) {
      _date = DateTime.parse(widget.trip['date']);
      _dateController.text = _formatDate(_date!);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _seatsController.dispose();
    _dateController.dispose();
    super.dispose();
  }

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

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      selectableDayPredicate: (date) => _isWeekend(date) || _isHoliday(date),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 26, 142, 234),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _date = picked;
        _dateController.text = _formatDate(picked);
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
      // Animation for image
      _scaleController.reset();
      _scaleController.forward();
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
        
        _showSuccessSnackBar('PDF selected: ${result.files.single.name}');
      } else {
        _showErrorSnackBar('No PDF files selected');
      }
    } catch (e) {
      _showErrorSnackBar('PDF selection error: ${e.toString()}');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
      _showErrorSnackBar('Failed to upload image: ${e.toString()}');
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
      _showErrorSnackBar('PDF upload failed: ${e.toString()}');
      return null;
    }
  }

  Future<void> _submitChanges() async {
    if (!_formKey.currentState!.validate()) return;

    if (_date == null || (!_isWeekend(_date!) && !_isHoliday(_date!))) {
      _showErrorSnackBar('The date must be a weekend or public holiday');
      return;
    }

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

      _showSuccessSnackBar("Trip updated and resubmitted for approval!");

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showErrorSnackBar('Update failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Widget _buildAnimatedFormField({
    required Widget child,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0, 
            _slideAnimation.value.dy * (index * 10)
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          labelStyle: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildModernDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        dropdownColor: Colors.white,
        decoration: InputDecoration(
          labelText: "Type",
          prefixIcon: const Icon(Icons.category, color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          labelStyle: TextStyle(color: Colors.grey[600]),
        ),
        value: _type,
        onChanged: (value) => setState(() => _type = value),
        items: [
          'City',
          'Event',
          'Sport',
        ].map(
          (type) => DropdownMenuItem(
            value: type,
            child: Text(
              type,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ).toList(),
        validator: (value) => value == null ? 'Please select a type' : null,
      ),
    );
  }

  Widget _buildPDFSelector() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.picture_as_pdf,
            color: Colors.black,
          ),
        ),
        title: Text(
          _programFile != null
              ? path.basename(_programFile!.path)
              : widget.trip['program_url'] != null
                  ? path.basename(widget.trip['program_url'])
                  : 'Select PDF program',
          style: TextStyle(
            fontSize: 16,
            color: (_programFile != null || widget.trip['program_url'] != null) 
                ? Colors.black87 
                : Colors.grey[600],
            fontWeight: (_programFile != null || widget.trip['program_url'] != null) 
                ? FontWeight.w500 
                : FontWeight.normal,
          ),
        ),
        trailing: const Icon(
          Icons.upload_file,
          color: Colors.black,
        ),
        onTap: _pickPDF,
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 0, 0, 0), Color.fromARGB(255, 54, 54, 55)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isUploading ? null : _submitChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: _isUploading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Updating...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : const Text(
                "Save Changes",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRejected = widget.trip['status']?.toLowerCase() == 'rejected';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Edit Trip",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 26, 142, 234),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF8F9FA),
                Color(0xFFE9ECEF),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rejection notice
                    if (isRejected)
                      _buildAnimatedFormField(
                        index: 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            border: Border.all(color: Colors.red, width: 2),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning, color: Colors.red, size: 24),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "This trip was rejected by admin. Please make necessary changes and resubmit.",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Image picker with animation
                    _buildAnimatedFormField(
                      index: isRejected ? 1 : 0,
                      child: Center(
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 200,
                              width: 200,
                              decoration: BoxDecoration(
                                gradient: (_image != null || widget.trip['image_url'] != null) 
                                  ? null 
                                  : const LinearGradient(
                                      colors: [Color.fromARGB(255, 12, 7, 93), Color.fromARGB(255, 26, 142, 234)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(255, 26, 142, 234).withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
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
                              child: (_image == null && widget.trip['image_url'] == null)
                                  ? const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.camera_alt_outlined,
                                          size: 50,
                                          color: Colors.white,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Add image',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        color: Colors.black.withOpacity(0.3),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Form fields with animations
                    _buildAnimatedFormField(
                      index: isRejected ? 2 : 1,
                      child: _buildModernTextField(
                        controller: _titleController,
                        label: "Title",
                        icon: Icons.title,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildAnimatedFormField(
                      index: isRejected ? 3 : 2,
                      child: _buildModernTextField(
                        controller: _descController,
                        label: "Description",
                        icon: Icons.description,
                        maxLines: 3,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildAnimatedFormField(
                      index: isRejected ? 4 : 3,
                      child: _buildModernDropdown(),
                    ),
                    const SizedBox(height: 20),

                    _buildAnimatedFormField(
                      index: isRejected ? 5 : 4,
                      child: _buildModernTextField(
                        controller: _dateController,
                        label: "Date",
                        icon: Icons.calendar_today,
                        readOnly: true,
                        onTap: _pickDate,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (_date == null ||
                              (!_isWeekend(_date!) && !_isHoliday(_date!))) {
                            return 'Must be a weekend or public holiday';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildAnimatedFormField(
                      index: isRejected ? 6 : 5,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildModernTextField(
                              controller: _priceController,
                              label: "Price (DH)",
                              icon: Icons.monetization_on,
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildModernTextField(
                              controller: _seatsController,
                              label: "Seats",
                              icon: Icons.airline_seat_recline_normal,
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildAnimatedFormField(
                      index: isRejected ? 7 : 6,
                      child: _buildPDFSelector(),
                    ),
                    const SizedBox(height: 40),

                    _buildAnimatedFormField(
                      index: isRejected ? 8 : 7,
                      child: _buildUpdateButton(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}