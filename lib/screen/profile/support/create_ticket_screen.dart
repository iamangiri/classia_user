import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../service/apiservice/support_service.dart';
import '../../../utills/themes/light_app_theme.dart';


class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({Key? key}) : super(key: key);

  @override
  _CreateTicketScreenState createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _supportService = SupportService();

  bool _isLoading = false;
  String _selectedCategory = 'General';
  String _selectedPriority = 'MEDIUM';

  final List<String> _categories = [
    'General',
    'Account Issues',
    'Payment Problems',
    'Technical Support',
    'Feature Request',
    'Bug Report',
  ];

  final List<Map<String, dynamic>> _priorities = [
    {'label': 'Low', 'value': 'LOW', 'color': Colors.green},
    {'label': 'Medium', 'value': 'MEDIUM', 'color': Colors.orange},
    {'label': 'High', 'value': 'HIGH', 'color': Colors.red},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Support Ticket", style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        centerTitle: true,
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: 24),
            _buildTicketForm(),
            SizedBox(height: 24),
            _buildSubmitButton(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: FaIcon(FontAwesomeIcons.ticketAlt, size: 32, color: Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            "Describe Your Issue",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "We'll get back to you as soon as possible",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketForm() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Category"),
            SizedBox(height: 8),
            _buildCategoryDropdown(),
            SizedBox(height: 24),
            _buildSectionTitle("Priority Level"),
            SizedBox(height: 8),
            _buildPrioritySelector(),
            SizedBox(height: 24),
            _buildSectionTitle("Issue Title"),
            SizedBox(height: 8),
            _buildTitleField(),
            SizedBox(height: 24),
            _buildSectionTitle("Description"),
            SizedBox(height: 8),
            _buildDescriptionField(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.lightTheme.primaryColor,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: FaIcon(FontAwesomeIcons.chevronDown, size: 16, color: Colors.grey[600]),
          items: _categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Row(
                children: [
                  _getCategoryIcon(category),
                  SizedBox(width: 12),
                  Text(category),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Row(
      children: _priorities.map((priority) {
        final isSelected = _selectedPriority == priority['value'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedPriority = priority['value'];
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? priority['color'].withOpacity(0.1)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? priority['color'] : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: priority['color'],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    priority['label'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? priority['color'] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _getCategoryIcon(String category) {
    IconData icon;
    Color color;

    switch (category) {
      case 'Account Issues':
        icon = FontAwesomeIcons.user;
        color = Colors.blue;
        break;
      case 'Payment Problems':
        icon = FontAwesomeIcons.creditCard;
        color = Colors.green;
        break;
      case 'Technical Support':
        icon = FontAwesomeIcons.cog;
        color = Colors.orange;
        break;
      case 'Feature Request':
        icon = FontAwesomeIcons.lightbulb;
        color = Colors.purple;
        break;
      case 'Bug Report':
        icon = FontAwesomeIcons.bug;
        color = Colors.red;
        break;
      default:
        icon = FontAwesomeIcons.questionCircle;
        color = Colors.grey;
    }

    return FaIcon(icon, size: 16, color: color);
  }

  Widget _buildTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: _titleController,
        decoration: InputDecoration(
          hintText: "Brief summary of your issue...",
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
          prefixIcon: Padding(
            padding: EdgeInsets.all(16),
            child: FaIcon(FontAwesomeIcons.edit, size: 16, color: Colors.grey[500]),
          ),
        ),
        maxLength: 100,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter a title for your ticket';
          }
          if (value.trim().length < 5) {
            return 'Title must be at least 5 characters long';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: _descriptionController,
        decoration: InputDecoration(
          hintText: "Describe your issue in detail...",
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
          alignLabelWithHint: true,
        ),
        maxLines: 8,
        maxLength: 1000,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please describe your issue';
          }
          if (value.trim().length < 20) {
            return 'Description must be at least 20 characters long';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitTicket,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.lightTheme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
          child: _isLoading
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text(
                "Creating Ticket...",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(FontAwesomeIcons.paperPlane, color: Colors.white, size: 18),
              SizedBox(width: 12),
              Text(
                "Submit Ticket",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _supportService.createSupportTicket(
        title: _selectedCategory,
        message: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
      );

      if (success) {
        _showSuccessDialog();
      } else {
        _showErrorDialog("Failed to create ticket. Please try again.");
      }
    } catch (e) {
      _showErrorDialog("An error occurred. Please check your connection and try again.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: FaIcon(FontAwesomeIcons.check, color: Colors.green, size: 32),
            ),
            SizedBox(height: 16),
            Text(
              "Ticket Created Successfully!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              "We've received your support ticket and will respond as soon as possible.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              "OK",
              style: TextStyle(
                color: AppTheme.lightTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            FaIcon(FontAwesomeIcons.exclamationTriangle, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text("Error"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
}