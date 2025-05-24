import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditTripPage extends StatefulWidget {
  final Map<String, dynamic> trip;

  const EditTripPage({Key? key, required this.trip}) : super(key: key);

  @override
  _EditTripPageState createState() => _EditTripPageState();
}

class _EditTripPageState extends State<EditTripPage> {
  final TextEditingController _imgController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _programController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _imgController.text = widget.trip['img'] ?? '';
    _titleController.text = widget.trip['title'] ?? '';
    _descriptionController.text = widget.trip['description'] ?? '';
    _typeController.text = widget.trip['type'] ?? '';
    _priceController.text = widget.trip['price_per_person']?.toString() ?? '';
    _seatsController.text = widget.trip['seats']?.toString() ?? '';
    _statusController.text = widget.trip['status'] ?? '';
    _programController.text = widget.trip['program'] ?? '';

    _selectedDate = DateTime.tryParse(widget.trip['date']);
    _dateController.text = _selectedDate != null
        ? _selectedDate!.toIso8601String().split('T').first
        : '';
  }

  @override
  void dispose() {
    _imgController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _typeController.dispose();
    _dateController.dispose();
    _priceController.dispose();
    _seatsController.dispose();
    _statusController.dispose();
    _programController.dispose();
    super.dispose();
  }

  Future<void> _updateTrip() async {
    try {
      await Supabase.instance.client.from('Voyage').update({
        'img': _imgController.text,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'type': _typeController.text,
        'date': _selectedDate?.toIso8601String().split('T').first,
        'price_per_person': double.tryParse(_priceController.text),
        'seats': int.tryParse(_seatsController.text),
        'status': _statusController.text,
        'program': _programController.text,
      }).eq('id', widget.trip['id']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip updated successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating trip: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(35),
      borderSide: const BorderSide(width: 2.0, color: Colors.black),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Trip')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Image URL
              TextFormField(
                controller: _imgController,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  border: border,
                  enabledBorder: border,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: border,
                  enabledBorder: border,
                ),
              ),
              const SizedBox(height: 16),

              // Description
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

              // Type
              TextFormField(
                controller: _typeController,
                decoration: InputDecoration(
                  labelText: 'Type',
                  border: border,
                  enabledBorder: border,
                ),
              ),
              const SizedBox(height: 16),

              // Date (read only with picker)
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: border,
                  enabledBorder: border,
                ),
                onTap: () async {
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
                          picked.toIso8601String().split('T').first;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Price per person
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

              // Seats
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

              // Status
              TextFormField(
                controller: _statusController,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: border,
                  enabledBorder: border,
                ),
              ),
              const SizedBox(height: 16),

              // Program
              TextFormField(
                controller: _programController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Program',
                  border: border,
                  enabledBorder: border,
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateTrip,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
