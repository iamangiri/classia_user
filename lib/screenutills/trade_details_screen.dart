import 'package:flutter/material.dart';
import 'create_folio_screen.dart';

class TradingDetailsScreen extends StatefulWidget {
  final String logo;
  final String name;

  TradingDetailsScreen({required this.logo, required this.name});

  @override
  _TradingDetailsScreenState createState() => _TradingDetailsScreenState();
}

class _TradingDetailsScreenState extends State<TradingDetailsScreen> {
  String _selectedAction = 'Invest';
  final TextEditingController _folioController = TextEditingController();
  bool _hasFolio = true;
  final _formKey = GlobalKey<FormState>();

  // Test with: FOLIO12345 (any non-empty value)
  static const validFolioNumbers = ['FOLIO123', 'FOLIO456'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.logo),
              radius: 18,
            ),
            SizedBox(width: 12),
            Text(widget.name,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Special JOCECY Point Header
            _buildSpecialHeader(),
            SizedBox(height: 20),

            // Fund Details Section
            _buildFundDetailsSection(),
            SizedBox(height: 24),

            // Action Selector
            _buildActionSelector(),
            SizedBox(height: 24),

            // Folio Number Input Section
            _buildFolioInputSection(),
            SizedBox(height: 24),

            // Action Button
            _buildActionButton(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.tealAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.tealAccent),
      ),
      child: Row(
        children: [
          Icon(Icons.star, color: Colors.tealAccent),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'JOCECY Special: Real-time JOCECY points show the fund’s performance, allowing you to invest and withdraw instantly.',
              style: TextStyle(
                color: Colors.tealAccent,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundDetailsSection() {
    return Column(
      children: [
        // First Row of Cards
        Row(
          children: [
            Expanded(child: _buildDetailCard('AUM', '₹12,450 Cr')),
            SizedBox(width: 12),
            Expanded(child: _buildDetailCard('Min. Invest', '₹500')),
            SizedBox(width: 12),
            Expanded(child: _buildDetailCard('Jockey Point', '5.75%')),
          ],
        ),
        SizedBox(height: 12),

        // Second Row of Cards
        Row(
          children: [
            Expanded(child: _buildDetailCard('1Y Return', '18.6%')),
            SizedBox(width: 12),
            Expanded(child: _buildDetailCard('Risk Level', 'Moderate')),
            SizedBox(width: 12),
            Expanded(child: _buildDetailCard('NAV', '₹24.56')),
          ],
        ),
        SizedBox(height: 24),

        // Detailed Fund Information
        _buildFundInfoPanel(),
      ],
    );
  }

  Widget _buildFundInfoPanel() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSectionHeader('Fund Highlights'),
          SizedBox(height: 12),
          _buildInfoItem('Fund Manager', '10+ Years Experience'),
          _buildInfoItem('Sector Allocation', 'Diversified Equity'),
          _buildInfoItem('Exit Load', '1% if redeemed within 1 year'),

          Divider(color: Colors.grey[700]),
          SizedBox(height: 12),

          _buildInfoSectionHeader('Asset Allocation'),
          SizedBox(height: 8),
          _buildAllocationBar('Equity', 78, Colors.tealAccent),
          _buildAllocationBar('Debt', 18, Colors.blueAccent),
          _buildAllocationBar('Cash', 4, Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _buildInfoSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.tealAccent,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildAllocationBar(String label, int percentage, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: Colors.white)),
              Text('$percentage%', style: TextStyle(color: color)),
            ],
          ),
          SizedBox(height: 4),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: Colors.grey[800],
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAction,
          isExpanded: true,
          dropdownColor: Colors.grey[900],
          style: TextStyle(color: Colors.white, fontSize: 16),
          items: ['Invest', 'Withdraw']
              .map((action) => DropdownMenuItem(
            value: action,
            child: Text(action),
          ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedAction = value!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildFolioInputSection() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_hasFolio)
            TextFormField(
              controller: _folioController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Folio Number',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[900],
                suffixIcon: Icon(Icons.search, color: Colors.grey),
              ),
              validator: (value) => validFolioNumbers.contains(value)
                  ? null
                  : 'Invalid folio number',
            ),
          if (!_hasFolio) ...[
            Text('No folio number available',
                style: TextStyle(color: Colors.grey)),
            SizedBox(height: 8),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _hasFolio = !_hasFolio;
                  if (!_hasFolio) _folioController.clear();
                });
              },
              child: Text(
                _hasFolio ? 'Create New Folio' : 'Use Existing Folio',
                style: TextStyle(color: Colors.tealAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _handleAction();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedAction == 'Invest'
              ? Colors.tealAccent
              : Colors.redAccent[400],
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          _hasFolio ? _selectedAction : 'Create Folio',
          style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String value) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12)),
          SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _handleAction() async {
    if (!_hasFolio) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateFolioScreen()),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Confirm ${_selectedAction}',
            style: TextStyle(color: Colors.white)),
        content: Text('You are about to $_selectedAction in ${widget.name}',
            style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Confirm', style: TextStyle(color: Colors.tealAccent)),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green[800],
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('${_selectedAction} Successful!',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }
  }
}