import 'package:flutter/material.dart';
import '../../screenutills/create_folio_screen.dart';


class ManageFolioScreen extends StatefulWidget {
  @override
  _ManageFolioScreenState createState() => _ManageFolioScreenState();
}

class _ManageFolioScreenState extends State<ManageFolioScreen> {
  List<String> folioNumbers = ['FOLIO123', 'FOLIO456'];
  final TextEditingController _folioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Manage Folios', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            _buildSectionHeader('Your Investment Folios'),
        SizedBox(height: 20),

        Expanded(
          child: folioNumbers.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            itemCount: folioNumbers.length,
            itemBuilder: (context, index) => _buildFolioCard(folioNumbers[index]),
          ),
        ),

          SizedBox(height: 20),
          _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.tealAccent,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFolioCard(String folioNumber) {
    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.tealAccent.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Icon(Icons.folder_shared, color: Colors.tealAccent),
        title: Text(folioNumber,
            style: TextStyle(color: Colors.white, fontSize: 16)),
        subtitle: Text('Invested: ₹25,000 • NAV: ₹24.56',
            style: TextStyle(color: Colors.grey[400])),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[500]),
        onTap: () => _showFolioDetails(folioNumber),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off, size: 60, color: Colors.grey[700]),
          SizedBox(height: 20),
          Text('No Folios Found',
              style: TextStyle(color: Colors.grey[500], fontSize: 18)),
          SizedBox(height: 10),
          Text('Start by creating a new folio',
              style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: Icon(Icons.add_circle_outline, color: Colors.black),
            label: Text('Add Existing Folio',
                style: TextStyle(color: Colors.black)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _showAddFolioDialog,
          ),
        ),
        SizedBox(height: 12),
        TextButton(
          child: Text('Create New Folio',
              style: TextStyle(color: Colors.tealAccent)),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateFolioScreen()),
          ),
        ),
      ],
    );
  }



  void _showAddFolioDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Add Existing Folio',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: _folioController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter Folio Number',
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Add', style: TextStyle(color: Colors.tealAccent)),
            onPressed: () {
              if (_folioController.text.isNotEmpty) {
                setState(() {
                  folioNumbers.add(_folioController.text);
                  _folioController.clear();
                });
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }


  void _showFolioDetails(String folioNumber) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                color: Colors.grey[700],
                margin: EdgeInsets.only(bottom: 16),
              ),
            ),
            ListTile(
              leading: Icon(Icons.info, color: Colors.tealAccent),
              title: Text('Folio Details',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            _buildDetailItem('Folio Number', folioNumber),
            _buildDetailItem('Investment Date', '12 Aug 2023'),
            _buildDetailItem('Current Value', '₹26,450'),
            _buildDetailItem('Total Units', '1,076.45'),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                child: Text('Close', style: TextStyle(color: Colors.tealAccent)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[500])),
          Text(value, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}