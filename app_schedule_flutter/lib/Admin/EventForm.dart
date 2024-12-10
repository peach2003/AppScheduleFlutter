import 'package:flutter/material.dart';

class EventForm extends StatefulWidget {
  final Map<String, dynamic>? event;
  final Function(String?, Map<String, dynamic>) onSave;

  EventForm({this.event, required this.onSave});

  @override
  _EventFormState createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _content;
  String? _image;
  String? _link;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _title = widget.event!['title'];
      _content = widget.event!['content'];
      _image = widget.event!['image'];
      _link = widget.event!['link'];
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final eventData = {
        "title": _title,
        "content": _content,
        "image": _image,
        "link": _link,
        "created_at": DateTime.now().toIso8601String(),
      };
      widget.onSave(widget.event?['key'], eventData);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  widget.event == null ? "Add New Event" : "Edit Event",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildTextField(
                label: "Title",
                initialValue: _title,
                icon: Icons.title,
                onSaved: (value) => _title = value,
                validator: (value) =>
                value == null || value.isEmpty ? "Title is required" : null,
              ),
              _buildTextField(
                label: "Content",
                initialValue: _content,
                icon: Icons.description,
                onSaved: (value) => _content = value,
                validator: (value) =>
                value == null || value.isEmpty ? "Content is required" : null,
              ),
              _buildTextField(
                label: "Image URL",
                initialValue: _image,
                icon: Icons.image,
                onSaved: (value) => _image = value,
              ),
              _buildTextField(
                label: "Link",
                initialValue: _link,
                icon: Icons.link,
                onSaved: (value) => _link = value,
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Save",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String? initialValue,
    required IconData icon,
    required void Function(String?) onSaved,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          filled: true,
          fillColor: Colors.blue.shade50,
        ),
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}