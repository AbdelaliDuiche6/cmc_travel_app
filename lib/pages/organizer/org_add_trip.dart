import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class AddTripPage extends StatefulWidget {
  const AddTripPage({super.key});

  @override
  State<AddTripPage> createState() => _AddTripPageState();
}

class _AddTripPageState extends State<AddTripPage>
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary:  Color.fromARGB(255, 26, 142, 234),
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
      // Animation pour l'image
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

      return _supabase.storage
          .from(_bucketName)
          .getPublicUrl(fileName);
    } catch (e) {
      _showErrorSnackBar('Failed to download\'image: ${e.toString()}');
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

      return _supabase.storage
          .from(_programBucketName)
          .getPublicUrl(fileName);
    } catch (e) {
      _showErrorSnackBar('PDF download fails: ${e.toString()}');
      return null;
    }
  }

  Future<void> _publish() async {
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
      if (_image != null) {
        imageUrl = await _uploadImage();
        if (imageUrl == null) return;
      }

      String? programUrl;
      if (_programFile != null) {
        programUrl = await _uploadPDF();
        if (programUrl == null) return;
      }

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _showErrorSnackBar('Authentication required');
        return;
      }

      await _supabase.from('Voyage').insert({
        'title': _titleController.text,
        'description': _descController.text,
        'type': _type!,
        'date': _date!.toIso8601String(),
        'price_per_person': double.parse(_priceController.text),
        'nbr_places': int.parse(_seatsController.text),
        'free_places': int.parse(_seatsController.text),
        'status': 'en_cours',
        'image_url': imageUrl,
        'program_url': programUrl,
        'organizer_id': userId,
      });

      _showSuccessSnackBar("Successfully published trip!");

      // Clear the form
      _formKey.currentState!.reset();
      setState(() {
        _image = null;
        _programFile = null;
        _date = null;
        _type = null;
        _titleController.clear();
        _descController.clear();
        _priceController.clear();
        _seatsController.clear();
        _dateController.clear();
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorSnackBar('Publication failure: ${e.toString()}');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Create Trip",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor:  Color.fromARGB(255, 26, 142, 234),
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
                    // Image picker avec animation
                    _buildAnimatedFormField(
                      index: 0,
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
                                gradient: _image != null 
                                  ? null 
                                  : const LinearGradient(
                                      colors: [ Color.fromARGB(255, 12, 7, 93),  Color.fromARGB(255, 26, 142, 234)],
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
                                    : null,
                              ),
                              child: _image == null
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

                    // Form fields avec animations
                    _buildAnimatedFormField(
                      index: 1,
                      child: _buildModernTextField(
                        controller: _titleController,
                        label: "Title",
                        icon: Icons.title,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Requis' : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildAnimatedFormField(
                      index: 2,
                      child: _buildModernTextField(
                        controller: _descController,
                        label: "Description",
                        icon: Icons.description,
                        maxLines: 3,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Requis' : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildAnimatedFormField(
                      index: 3,
                      child: _buildModernDropdown(),
                    ),
                    const SizedBox(height: 20),

                    _buildAnimatedFormField(
                      index: 4,
                      child: _buildModernTextField(
                        controller: _dateController,
                        label: "Date",
                        icon: Icons.calendar_today,
                        readOnly: true,
                        onTap: _pickDate,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Requis';
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
                      index: 5,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildModernTextField(
                              controller: _priceController,
                              label: "Prix (DH)",
                              icon: Icons.monetization_on,
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Requis' : null,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildModernTextField(
                              controller: _seatsController,
                              label: "Places",
                              icon: Icons.airline_seat_recline_normal,
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Requis' : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildAnimatedFormField(
                      index: 6,
                      child: _buildPDFSelector(),
                    ),
                    const SizedBox(height: 40),

                    _buildAnimatedFormField(
                      index: 7,
                      child: _buildPublishButton(),
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
          _programFile == null
              ? 'Select PDF program'
              : path.basename(_programFile!.path),
          style: TextStyle(
            fontSize: 16,
            color: _programFile == null ? Colors.grey[600] : Colors.black87,
            fontWeight: _programFile == null ? FontWeight.normal : FontWeight.w500,
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

  Widget _buildPublishButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 0, 0, 0),  Color.fromARGB(255, 54, 54, 55)],
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
        onPressed: _isUploading ? null : _publish,
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
                    "Publication in progress...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : const Text(
                "Publish the trip",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}