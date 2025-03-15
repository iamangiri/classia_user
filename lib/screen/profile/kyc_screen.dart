import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class KYCVerificationScreen extends StatefulWidget {
  @override
  _KYCVerificationScreenState createState() => _KYCVerificationScreenState();
}

class _KYCVerificationScreenState extends State<KYCVerificationScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  XFile? _bankDocument;

  // Controllers for Aadhaar step
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _aadhaarOtpController = TextEditingController();

  // Controllers for PAN step
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _panOtpController = TextEditingController();

  // Controllers for Bank Info step
  final TextEditingController _accountHolderController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Flags to show OTP field after sending OTP
  bool _isAadhaarOtpSent = false;
  bool _isPanOtpSent = false;

  @override
  void dispose() {
    _pageController.dispose();
    _aadhaarController.dispose();
    _aadhaarOtpController.dispose();
    _panController.dispose();
    _panOtpController.dispose();
    _accountHolderController.dispose();
    _ifscController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _bankDocument = pickedFile);
    }
  }

  Widget _buildProgressIndicator() {
    return SizedBox(
      height: 100,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStepIcon(0, Icons.fingerprint),
              _buildStepIcon(1, Icons.credit_card),
              _buildStepIcon(2, Icons.account_balance),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
          ),
        ],
      ),
    );
  }
  Widget _buildStepIcon(int stepIndex, IconData icon) {
    bool isActiveOrCompleted = _currentStep >= stepIndex;
    Color backgroundColor = isActiveOrCompleted ? Color(0xFFFFD700) : Colors.grey[800]!;
    Color iconColor = isActiveOrCompleted ? Colors.black : Colors.white;

    return CircleAvatar(
      radius: 20,
      backgroundColor: backgroundColor,
      child: Icon(icon, color: iconColor),
    );
  }


  Widget _buildStepContent() {
    return PageView(
      controller: _pageController,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildAadhaarStep(),
        _buildPanStep(),
        _buildBankInfoStep(),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, {IconData? prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white70),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.white70) : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey[850],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.white70),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Color(0xFFFFD700)),
      ),
    );
  }

  Widget _buildAadhaarStep() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _aadhaarController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
              decoration: _inputDecoration('Aadhaar Number', prefixIcon: Icons.credit_card),
              validator: (value) => value?.length != 12 ? 'Invalid Aadhaar number' : null,
            ),
            const SizedBox(height: 20),
            if (!_isAadhaarOtpSent)
              ElevatedButton.icon(
                icon: Icon(Icons.send, color: Colors.black),
                label: Text('Send OTP', style: TextStyle(color: Colors.black)),
                onPressed: () => _sendOtp('aadhaar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFD700),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            if (_isAadhaarOtpSent) ...[
              const SizedBox(height: 20),
              TextFormField(
                controller: _aadhaarOtpController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                decoration: _inputDecoration('Enter OTP', prefixIcon: Icons.lock),
                validator: (value) => value?.length != 6 ? 'Invalid OTP' : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPanStep() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _panController,
              style: TextStyle(color: Colors.white),
              decoration: _inputDecoration('PAN Number', prefixIcon: Icons.credit_card),
              validator: (value) => value?.length != 10 ? 'Invalid PAN number' : null,
            ),
            const SizedBox(height: 20),
            if (!_isPanOtpSent)
              ElevatedButton.icon(
                icon: Icon(Icons.send, color: Colors.black),
                label: Text('Send OTP', style: TextStyle(color: Colors.black)),
                onPressed: () => _sendOtp('pan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFD700),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            if (_isPanOtpSent) ...[
              const SizedBox(height: 20),
              TextFormField(
                controller: _panOtpController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                decoration: _inputDecoration('Enter OTP', prefixIcon: Icons.lock),
                validator: (value) => value?.length != 6 ? 'Invalid OTP' : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBankInfoStep() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _accountHolderController,
                style: TextStyle(color: Colors.white),
                decoration: _inputDecoration('Account Holder Name', prefixIcon: Icons.person),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _ifscController,
                style: TextStyle(color: Colors.white),
                decoration: _inputDecoration('IFSC Code',
                    prefixIcon: Icons.code,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search, color: Colors.white70),
                      onPressed: _fetchBankDetails,
                    )),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _bankNameController,
                style: TextStyle(color: Colors.white),
                decoration: _inputDecoration('Bank Name', prefixIcon: Icons.account_balance),
                readOnly: true,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _branchController,
                style: TextStyle(color: Colors.white),
                decoration: _inputDecoration('Branch', prefixIcon: Icons.location_city),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                decoration: _inputDecoration('Account Number', prefixIcon: Icons.numbers),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _pickDocument,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFFFD700)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.upload_file, size: 40, color: Color(0xFFFFD700)),
                      Text(
                        _bankDocument?.name ?? 'Upload Bank Passbook/Cheque',
                        style: TextStyle(color: Color(0xFFFFD700)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendOtp(String type) {
    if (_formKey.currentState?.validate() ?? false) {
      if (type == 'aadhaar') {
        setState(() {
          _isAadhaarOtpSent = true;
        });
      } else if (type == 'pan') {
        setState(() {
          _isPanOtpSent = true;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP sent to your registered mobile number')),
      );
    }
  }

  void _fetchBankDetails() {
    // Simulate an IFSC lookup API
    if (_ifscController.text.length == 11) {
      setState(() {
        _bankNameController.text = 'Sample Bank';
        _branchController.text = 'Mumbai';
      });
    }
  }

  void _handleContinue() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_currentStep == 0) {
      if (!_isAadhaarOtpSent) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Please send OTP for Aadhaar")));
        return;
      }
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (!_isPanOtpSent) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Please send OTP for PAN")));
        return;
      }
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      if (_accountHolderController.text.isNotEmpty &&
          _ifscController.text.isNotEmpty &&
          _accountNumberController.text.isNotEmpty &&
          _bankNameController.text.isNotEmpty &&
          _branchController.text.isNotEmpty &&
          _bankDocument != null) {
        _submitKyc();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill all bank details and upload passbook")),
        );
      }
    }
  }

  void _submitKyc() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('KYC Submitted'),
        content: Text('Your KYC details have been submitted for verification.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'KYC Verification',
          style: TextStyle(color: Colors.white),
        ),
        leading: _currentStep > 0
            ? IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _pageController.previousPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            setState(() {
              _currentStep--;
            });
          },
        )
            : null,
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(child: _buildStepContent()),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _handleContinue,
            child: Text(
              _currentStep == 2 ? 'SUBMIT KYC' : 'CONTINUE',
              style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFD700),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
