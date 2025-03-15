import 'package:flutter/material.dart';

class AddBankScreen extends StatefulWidget {
  @override
  _AddBankScreenState createState() => _AddBankScreenState();
}

class _AddBankScreenState extends State<AddBankScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _accountHolderController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();

  @override
  void dispose() {
    _bankNameController.dispose();
    _branchController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  void _submitBankData() {
    if (_formKey.currentState?.validate() ?? false) {
      // Replace this with your actual submission logic
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Bank details submitted successfully")));
      Navigator.pop(context);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.grey[850],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white70),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFFFD700)),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Add Bank", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _bankNameController,
                decoration: _inputDecoration("Bank Name"),
                validator: (value) =>
                value == null || value.isEmpty ? "Enter Bank Name" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _branchController,
                decoration: _inputDecoration("Branch"),
                validator: (value) =>
                value == null || value.isEmpty ? "Enter Branch" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _accountHolderController,
                decoration: _inputDecoration("Account Holder Name"),
                validator: (value) => value == null || value.isEmpty
                    ? "Enter Account Holder Name"
                    : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Account Number"),
                validator: (value) =>
                value == null || value.isEmpty ? "Enter Account Number" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _ifscController,
                decoration: _inputDecoration("IFSC Code"),
                validator: (value) =>
                value == null || value.isEmpty ? "Enter IFSC Code" : null,
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _submitBankData,
                  child: Text("Submit Bank Data",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFD700),
                    padding:
                    EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
