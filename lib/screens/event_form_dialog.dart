// event_form_dialog.dart

import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class EventFormDialog extends StatefulWidget {
  final Event? event;
  final Function() onSubmit;

  const EventFormDialog({Key? key, this.event, required this.onSubmit}) : super(key: key);

  @override
  _EventFormDialogState createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _locationController;
  late TextEditingController _entranceFeeController;
  late EventService eventService;

  @override
  void initState() {
    super.initState();
    final request = Provider.of<CookieRequest>(context, listen: false);
    eventService = EventService(request);

    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController = TextEditingController(text: widget.event?.description ?? '');
    _dateController = TextEditingController(text: widget.event?.date.toIso8601String().split('T')[0] ?? '');
    _timeController = TextEditingController(text: widget.event?.time ?? '');
    _locationController = TextEditingController(text: widget.event?.location ?? '');
    _entranceFeeController = TextEditingController(text: widget.event?.entranceFee?.toString() ?? '');
  }

  Future<void> _pickTime() async {
    TimeOfDay initialTime;
    if (_timeController.text.isNotEmpty) {
      final parts = _timeController.text.split(':');
      if (parts.length == 2) {
        initialTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 12,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      } else {
        initialTime = TimeOfDay.now();
      }
    } else {
      initialTime = TimeOfDay.now();
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        _timeController.text = _formatTimeOfDay(picked);
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    // Convert TimeOfDay to 'HH:MM' format
    final int hour = time.hour;
    final int minute = time.minute;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Parse date and time
      DateTime parsedDate = DateTime.parse(_dateController.text);
      String formattedTime = _timeController.text;

      Event event = Event(
        id: widget.event?.id ?? 0,
        title: _titleController.text,
        description: _descriptionController.text,
        date: parsedDate,
        time: formattedTime,
        location: _locationController.text,
        entranceFee: _entranceFeeController.text.isNotEmpty
            ? double.parse(_entranceFeeController.text)
            : null,
      );

      try {
        if (widget.event == null) {
          await eventService.createEvent(event);
        } else {
          event.id = widget.event!.id;
          await eventService.updateEvent(event);
        }
        widget.onSubmit();
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _entranceFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.event == null ? 'Create New Event' : 'Edit Event'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  return (value == null || value.isEmpty) ? 'Please enter title' : null;
                },
              ),
              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              // Date Field with DatePicker
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: widget.event?.date ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dateController.text = pickedDate.toIso8601String().split('T')[0];
                    });
                  }
                },
                validator: (value) {
                  return (value == null || value.isEmpty) ? 'Please enter date' : null;
                },
              ),
              // Time Field with TimePicker
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Time (HH:MM)'),
                readOnly: true,
                onTap: _pickTime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter time';
                  }
                  // Validasi format waktu
                  final timeRegex = RegExp(r'^\d{2}:\d{2}$');
                  if (!timeRegex.hasMatch(value)) {
                    return 'Format waktu harus HH:MM';
                  }
                  return null;
                },
              ),
              // Location Field
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              // Entrance Fee Field
              TextFormField(
                controller: _entranceFeeController,
                decoration: const InputDecoration(labelText: 'Entrance Fee'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (double.tryParse(value) == null) {
                      return 'Entrance fee harus berupa angka';
                    }
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _submitForm, child: const Text('Submit')),
      ],
    );
  }
}