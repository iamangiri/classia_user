import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateFolioScreen extends StatefulWidget {
  @override
  _CreateFolioScreenState createState() => _CreateFolioScreenState();
}

class _CreateFolioScreenState extends State<CreateFolioScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Create New Folio',
            style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSectionTitle("Folio Creation Process"),
              SizedBox(height: 20),

              // Personal Details
              _buildInputField(
                label: "Full Name",
                hint: "Enter your full name",
                validator: (value) => value!.isEmpty ? "Required field" : null,
              ),

              _buildInputField(
                label: "Email Address",
                hint: "name@example.com",
                keyboardType: TextInputType.emailAddress,
                validator: (value) => !value!.contains("@") ? "Invalid email" : null,
              ),

              _buildInputField(
                label: "Mobile Number",
                hint: "10-digit phone number",
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => value!.length != 10 ? "Invalid number" : null,
              ),

              // PAN Card Input
              TextFormField(
                controller: _panController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "PAN Number",
                  labelStyle: TextStyle(color: Colors.grey),
                  hintText: "ABCDE1234F",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[900],
                  suffixIcon: Icon(Icons.credit_card, color: Colors.grey),
                ),
                inputFormatters: [
                  UpperCaseTextFormatter(),
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                ],
                validator: (value) => value!.length != 10 ? "Invalid PAN" : null,
              ),
              _buildGuidelineText("• 10-character alphanumeric PAN"),
              SizedBox(height: 20),

              // Bank Details
              _buildInputField(
                label: "Bank Account Number",
                hint: "Enter your account number",
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => value!.isEmpty ? "Required field" : null,
              ),

              _buildInputField(
                label: "IFSC Code",
                hint: "ABCD0123456",
                validator: (value) => value!.length != 11 ? "Invalid IFSC" : null,
              ),

              // Investment Details
              _buildSectionTitle("Investment Information"),
              TextFormField(
                controller: _amountController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Investment Amount (₹)",
                  labelStyle: TextStyle(color: Colors.grey),
                  hintText: "Minimum ₹500",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[900],
                  prefixIcon: Icon(Icons.currency_rupee, color: Colors.grey),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value!.isEmpty) return "Enter amount";
                  if (int.parse(value) < 500) return "Minimum ₹500";
                  return null;
                },
              ),
              _buildGuidelineText("• Minimum investment amount: ₹500"),

              SizedBox(height: 30),
              ElevatedButton.icon(
                icon: Icon(Icons.fingerprint, color: Colors.white),
                label: Text("VERIFY AND CREATE FOLIO",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitFolioRequest();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.grey),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[900],
          ),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildGuidelineText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 12.0),
      child: Text(
        text,
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
      ),
    );
  }

  void _submitFolioRequest() {
    // Handle form submission
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Verification", style: TextStyle(color: Colors.white)),
        content: Text("Processing your folio creation request...",
            style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("OK", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}