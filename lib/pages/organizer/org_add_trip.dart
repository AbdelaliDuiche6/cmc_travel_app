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
  DateTime? _startDate;
  DateTime? _endDate;
  File? _image;
  String? _programUrl;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _placesController = TextEditingController();

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _startDateController.text = _formatDate(picked);
        } else {
          _endDate = picked;
          _endDateController.text = _formatDate(picked);
        }
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
      _programUrl = "https://example/program.pdf";
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Program downloaded")));
  }

  void _publish() {
    if (_formKey.currentState!.validate()) {
      print("Publishing Trip:");
      print("Title: ${_titleController.text}");
      print("Desc: ${_descController.text}");
      print("Type: $_type");
      print("Start Date: $_startDate");
      print("End Date: $_endDate");
      print("Price: ${_priceController.text}");
      print("Seats: ${_seatsController.text}");
      print("Status: $_status");
      print("Image: ${_image?.path}");
      print("Program URL: $_programUrl");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Trip Published (simulated)")));
    }
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(35),
      borderSide: BorderSide(width: 2.0, color: Colors.black),
    );

    return Scaffold(
      appBar: AppBar(title: Text("Create Trip")),
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
                              ? Icon(Icons.camera_alt_outlined, size: 40)
                              : null,
                    ),
                  ),
                ),

                // Center(
                //   child: ElevatedButton.icon(
                //     onPressed: _pickImage,
                //     icon: Icon(Icons.camera_alt, color: Colors.black),
                //     label: Text(
                //       "Add Photo",
                //       style: TextStyle(color: Colors.black),
                //     ),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.white,
                //       side: BorderSide(color: Colors.grey),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(8),
                //       ),
                //     ),
                //   ),
                // ),
                SizedBox(height: 20),

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
                SizedBox(height: 12),

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
                SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Type",
                    border: border,
                    enabledBorder: border,
                  ),
                  value: _type,
                  onChanged: (value) {
                    setState(() {
                      _type = value;
                    });
                  },
                  items:
                      ['Adventure', 'Relax', 'Cultural']
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
                SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Start Date",
                          border: border,
                          enabledBorder: border,
                        ),
                        onTap: () => _pickDate(isStart: true),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _endDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "End Date",
                          border: border,
                          enabledBorder: border,
                        ),
                        onTap: () => _pickDate(isStart: false),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

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
                    SizedBox(width: 12),
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
                SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Status",
                    border: border,
                    enabledBorder: border,
                  ),
                  value: _status,
                  onChanged: (value) {
                    setState(() {
                      _status = value;
                    });
                  },
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
                SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _downloadProgram,
                    child: Text("Download Program"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _publish,
                    child: Text("Publish"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
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
