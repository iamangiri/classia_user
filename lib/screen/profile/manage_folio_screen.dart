import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/custom_app_bar.dart';
import 'package:classia_amc/screenutills/create_folio_screen.dart';

class ManageFolioScreen extends StatefulWidget {
  const ManageFolioScreen({Key? key}) : super(key: key);

  @override
  _ManageFolioScreenState createState() => _ManageFolioScreenState();
}

class _ManageFolioScreenState extends State<ManageFolioScreen> {
  List<String> folioNumbers = ['FOLIO123', 'FOLIO456'];
  final TextEditingController _folioController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _folioController.dispose();
    super.dispose();
  }

  void _addFolio(String folioNumber) async {
    if (folioNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid folio number'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
      folioNumbers.add(folioNumber);
      _folioController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Folio added successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(title: 'Manage Folios'),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Your Investment Folios'),
            SizedBox(height: 20.h),
            Expanded(
              child: folioNumbers.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                itemCount: folioNumbers.length,
                itemBuilder: (context, index) => _buildFolioCard(folioNumbers[index]),
              ),
            ),
            SizedBox(height: 20.h),
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
        color: AppColors.primaryText,
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFolioCard(String folioNumber) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.w),
        leading: Icon(Icons.folder_shared, color: AppColors.primaryGold, size: 24.sp),
        title: Text(
          folioNumber,
          style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
        ),
        subtitle: Text(
          'Invested: ₹25,000 • NAV: ₹24.56',
          style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.secondaryText, size: 24.sp),
        onTap: () => _showFolioDetails(folioNumber),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty_folio.png',
            width: 120.w,
            height: 120.h,
            color: AppColors.secondaryText,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Folios Found',
            style: TextStyle(color: AppColors.primaryText, fontSize: 18.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start by creating a new folio',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            icon: Icon(Icons.add_circle_outline, color: AppColors.buttonText, size: 20.sp),
            label: Text(
              'Create New Folio',
              style: TextStyle(
                color: AppColors.buttonText,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateFolioScreen()),
            ),
          ),
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
            icon: Icon(Icons.add_circle_outline, color: AppColors.buttonText, size: 20.sp),
            label: Text(
              'Add Existing Folio',
              style: TextStyle(
                color: AppColors.buttonText,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              minimumSize: Size(double.infinity, 48.h),
            ),
            onPressed: _isLoading ? null : _showAddFolioDialog,
          ),
        ),
        SizedBox(height: 12.h),
        TextButton(
          child: Text(
            'Create New Folio',
            style: TextStyle(color: AppColors.primaryGold, fontSize: 16.sp),
          ),
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
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Text(
          'Add Existing Folio',
          style: TextStyle(color: AppColors.primaryText, fontSize: 18.sp),
        ),
        content: TextField(
          controller: _folioController,
          style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
          decoration: InputDecoration(
            hintText: 'Enter Folio Number',
            hintStyle: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
            filled: true,
            fillColor: AppColors.cardBackground,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primaryGold),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.error),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.error, fontSize: 14.sp),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(
              'Add',
              style: TextStyle(color: AppColors.primaryGold, fontSize: 14.sp),
            ),
            onPressed: _isLoading
                ? null
                : () {
              final folioNumber = _folioController.text.trim();
              _addFolio(folioNumber);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showFolioDetails(String folioNumber) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                color: AppColors.border,
                margin: EdgeInsets.only(bottom: 16.h),
              ),
            ),
            ListTile(
              leading: Icon(Icons.info, color: AppColors.primaryGold, size: 24.sp),
              title: Text(
                'Folio Details',
                style: TextStyle(color: AppColors.primaryText, fontSize: 18.sp),
              ),
            ),
            _buildDetailItem('Folio Number', folioNumber),
            _buildDetailItem('Investment Date', '12 Aug 2023'),
            _buildDetailItem('Current Value', '₹26,450'),
            _buildDetailItem('Total Units', '1,076.45'),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                child: Text(
                  'Close',
                  style: TextStyle(color: AppColors.primaryGold, fontSize: 16.sp),
                ),
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
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
          ),
          Text(
            value,
            style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}