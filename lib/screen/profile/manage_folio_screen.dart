import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:classia_amc/service/apiservice/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManageFolioScreen extends StatefulWidget {
  const ManageFolioScreen({Key? key}) : super(key: key);

  @override
  _ManageFolioScreenState createState() => _ManageFolioScreenState();
}

class _ManageFolioScreenState extends State<ManageFolioScreen> {
  final TextEditingController _folioController = TextEditingController();
  bool _isLoading = false;
  bool _isListLoading = false;

  List<String> _folioNumbers = [];
  int _page = 1;
  int _limit = 10;
  int _total = 0;
  bool _hasMore = true;

  late UserService _userService;

  @override
  void initState() {
    super.initState();
    _initializeUserService();
    _fetchFolioList();
  }

  Future<void> _initializeUserService() async {
    setState(() {
      _userService = UserService(token: '${UserConstants.TOKEN}');
    });
  }

  @override
  void dispose() {
    _folioController.dispose();
    super.dispose();
  }

  Future<void> _addFolioNumber() async {
    if (_folioController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid folio number'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _userService.addFolioNumber(_folioController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Folio number added successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      _folioController.clear();
// Refresh list
      setState(() {
        _page = 1;
        _folioNumbers.clear();
        _hasMore = true;
      });
      await _fetchFolioList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchFolioList() async {
    if (!_hasMore || _isListLoading) return;
    setState(() => _isListLoading = true);
    try {
      final response = await _userService.getFolioList(_page, _limit);
      setState(() {
        _folioNumbers.addAll(List<String>.from(response['folioNumbers']));
        _total = response['pagination']['total'];
        _hasMore = _folioNumbers.length < _total;
        if (_hasMore) _page++;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isListLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label, String hint,
      {IconData? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
      hintStyle: TextStyle(
          color: AppColors.secondaryText.withOpacity(0.7), fontSize: 14.sp),
      prefixIcon: prefixIcon != null
          ? Padding(
              padding: EdgeInsets.only(left: 12.w, right: 8.w),
              child:
                  Icon(prefixIcon, color: AppColors.secondaryText, size: 20.sp),
            )
          : null,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.r),
        borderSide: BorderSide(color: AppColors.primaryGold, width: 2.w),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.r),
        borderSide: BorderSide(color: AppColors.primaryGold, width: 2.w),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.r),
        borderSide: BorderSide(color: AppColors.error, width: 2.w),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.r),
        borderSide: BorderSide(color: AppColors.error, width: 2.w),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      errorStyle:
          TextStyle(color: AppColors.error, fontSize: 12.sp, height: 0.5),
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
    return Card(
      color: AppColors.cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Icon(Icons.folder_shared,
            color: AppColors.primaryGold, size: 24.sp),
        title: Text(
          folioNumber,
          style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500),
        ),
        trailing: Icon(Icons.chevron_right,
            color: AppColors.secondaryText, size: 24.sp),
        onTap: () => _showFolioDetails(folioNumber),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            color: AppColors.secondaryText,
            size: 120.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Folios Found',
            style: TextStyle(color: AppColors.primaryText, fontSize: 18.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start by adding an existing folio',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: 342.w,
            height: 56.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                elevation: 2,
              ),
              onPressed: _showAddFolioDialog,
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryGold, const Color(0xFFFFA500)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    'Add Existing Folio',
                    style: TextStyle(
                      color: AppColors.buttonText,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFolioDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Text(
          'Add Existing Folio',
          style: TextStyle(color: AppColors.primaryText, fontSize: 18.sp),
        ),
        content: TextField(
          controller: _folioController,
          style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
          decoration: _inputDecoration('Folio Number', 'Enter folio number',
              prefixIcon: Icons.numbers),
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
                    _addFolioNumber();
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
              leading:
                  Icon(Icons.info, color: AppColors.primaryGold, size: 24.sp),
              title: Text(
                'Folio Details',
                style: TextStyle(color: AppColors.primaryText, fontSize: 18.sp),
              ),
            ),
            _buildDetailItem('Folio Number', folioNumber),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                child: Text(
                  'Close',
                  style:
                      TextStyle(color: AppColors.primaryGold, fontSize: 16.sp),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(title: 'Manage Folios'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: _buildSectionHeader('Your Investment Folios'),
          ),
          Expanded(
            child: _folioNumbers.isEmpty && !_isListLoading
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _folioNumbers.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _folioNumbers.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: _isListLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primaryGold),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _fetchFolioList,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryGold,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.r)),
                                  ),
                                  child: Text(
                                    'Load More',
                                    style: TextStyle(
                                      color: AppColors.buttonText,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                        );
                      }
                      return _buildFolioCard(_folioNumbers[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
