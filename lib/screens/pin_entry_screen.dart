import 'package:flutter/material.dart';

class PinEntryScreen extends StatefulWidget {
  final Function(String) onPinEntered;
  const PinEntryScreen({required this.onPinEntered, super.key});

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  final _controller = TextEditingController();

  void _submitPin() {
    if (_controller.text.isNotEmpty) {
      widget.onPinEntered(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter PIN")),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: InputDecoration(labelText: "PIN"),
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _submitPin, child: Text("Submit"))
          ],
        ),
      ),
    );
  }
}
