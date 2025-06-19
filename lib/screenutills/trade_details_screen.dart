import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/screenutills/create_folio_screen.dart';
import 'package:classia_amc/service/apiservice/wallet_service.dart';
import 'package:classia_amc/service/apiservice/user_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TradingDetailsScreen extends StatefulWidget {
  final String logo;
  final String name;

  const TradingDetailsScreen({Key? key, required this.logo, required this.name})
      : super(key: key);

  @override
  _TradingDetailsScreenState createState() => _TradingDetailsScreenState();
}

class _TradingDetailsScreenState extends State<TradingDetailsScreen> {
  final TextEditingController _folioController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  bool _isFavorite = false;
  List<String> _folioNumbers = [];
  bool _isFolioLoading = true;

  late WalletService _walletService;
  late UserService _userService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _fetchFolioNumbers();
  }

  Future<void> _initializeServices() async {
    setState(() {
      _walletService = WalletService(token: '${UserConstants.TOKEN}');
      _userService = UserService(token: '${UserConstants.TOKEN}');
    });
  }

  Future<void> _fetchFolioNumbers() async {
    setState(() => _isFolioLoading = true);
    try {
      final data = await _userService.getFolioList(1, 10);
      final List<String> folios =
      List<String>.from(data['folioNumbers'] as List<dynamic>);
      setState(() {
        _folioNumbers = folios;
        _isFolioLoading = false;
      });
    } catch (e) {
      setState(() => _isFolioLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _folioController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipOval(
            child: Image.network(
              widget.logo,
              width: 32.r,
              height: 32.r,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 32.r,
                height: 32.r,
                color: Colors.grey[200],
                child: Icon(Icons.image, color: AppColors.error, size: 16.sp),
              ),
            ),
          ),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.name,
              style: TextStyle(
                color: AppColors.primaryGold,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Text(
              'Fund Details',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share,
              color: AppColors.primaryGold,
              size: 24.sp,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Share feature coming soon!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: AppColors.primaryGold,
              size: 24.sp,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isFavorite
                      ? 'Added to favorites'
                      : 'Removed from favorites'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSpecialHeader(),
                  SizedBox(height: 20.h),
                  _buildFolioInputSection(),
                  SizedBox(height: 20.h),
                  _buildFundDetailsSection(),
                  SizedBox(height: 24.h),
                  _buildAboutFund(),
                  SizedBox(height: 24.h),
                  _buildFundManager(),
                  SizedBox(height: 24.h),
                  _buildPerformance(),
                  SizedBox(height: 24.h),
                  _buildFundamentals(),
                  SizedBox(height: 24.h),
                  _buildFinancials(),
                  SizedBox(height: 24.h),
                  _buildAssetAllocation(),
                  SizedBox(height: 24.h),
                  _buildShareholdingPattern(),
                  SizedBox(height: 24.h),
                  _buildFAQs(),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildSpecialHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
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
      child: Row(
        children: [
          Icon(Icons.star, color: AppColors.primaryGold, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'JOCECY Special: Real-time JOCECY points show the fund’s performance.',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolioInputSection() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _amountController,
            style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount',
              hintText: 'Enter amount (e.g., 1000)',
              labelStyle:
              TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
              hintStyle:
              TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
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
              suffixIcon: Icon(Icons.currency_rupee,
                  color: AppColors.secondaryText, size: 20.sp),
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Please enter an amount';
              final amount = int.tryParse(value);
              if (amount == null || amount <= 0)
                return 'Please enter a valid amount';
              return null;
            },
          ),
          SizedBox(height: 16.h),
          if (_folioNumbers.isNotEmpty)
            _isFolioLoading
                ? Center(
              child: CircularProgressIndicator(
                valueColor:
                AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
              ),
            )
                : DropdownButtonFormField<String>(
              value: _folioController.text.isEmpty
                  ? null
                  : _folioController.text,
              style: TextStyle(
                  color: AppColors.primaryText, fontSize: 16.sp),
              decoration: InputDecoration(
                labelText: 'Folio Number',
                hintText: 'Select folio number',
                labelStyle: TextStyle(
                    color: AppColors.primaryText, fontSize: 14.sp),
                hintStyle: TextStyle(
                    color: AppColors.secondaryText, fontSize: 14.sp),
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
              items: _folioNumbers.map((folio) {
                return DropdownMenuItem(
                  value: folio,
                  child: Text(folio,
                      style: TextStyle(
                          color: AppColors.primaryText, fontSize: 16.sp)),
                );
              }).toList(),
              onChanged: (value) {
                _folioController.text = value ?? '';
              },
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please select a folio number';
                return null;
              },
              dropdownColor: AppColors.cardBackground,
              icon: Icon(Icons.arrow_drop_down,
                  color: AppColors.secondaryText, size: 20.sp),
            )
          else
            Column(
              children: [
                Text(
                  'No folio available. Please create a new folio to proceed.',
                  style:
                  TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
                ),
                SizedBox(height: 8.h),
                ElevatedButton(
                  onPressed: () async {
                    final newFolio = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateFolioScreen()),
                    );
                    if (newFolio != null) {
                      setState(() {
                        _folioNumbers.add(newFolio);
                        _folioController.text = newFolio;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('New folio created: $newFolio'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    padding:
                    EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text(
                    'Create Folio',
                    style: TextStyle(
                      color: AppColors.buttonText,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFundDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildDetailCard('AUM', '₹5,000 Cr')),
            SizedBox(width: 12.w),
            Expanded(child: _buildDetailCard('Min. Invest', '₹1,000')),
            SizedBox(width: 12.w),
            Expanded(child: _buildDetailCard('Jockey Point', '6.0%')),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: _buildDetailCard('1Y Return', '12.5%')),
            SizedBox(width: 12.w),
            Expanded(child: _buildDetailCard('Risk Level', 'High')),
          ],
        ),
        SizedBox(height: 24.h),
        _buildFundInfoPanel(),
      ],
    );
  }

  Widget _buildDetailCard(String title, String value) {
    return Container(
      padding: EdgeInsets.all(12.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundInfoPanel() {
    return Container(
      padding: EdgeInsets.all(16.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSectionHeader('Fund Highlights'),
          SizedBox(height: 12.h),
          _buildInfoItem('Fund Manager', 'Rahul Sharma - 12 Years Exp'),
          _buildInfoItem('Sector Allocation', 'Large Cap Equity'),
          _buildInfoItem('Exit Load', '1% if redeemed within 6 months'),
          Divider(color: AppColors.border),
          SizedBox(height: 12.h),
          _buildInfoSectionHeader('Asset Allocation'),
          SizedBox(height: 8.h),
          _buildAllocationBar('Equity', 70, AppColors.primaryGold),
          _buildAllocationBar('Debt', 20, AppColors.accent),
          _buildAllocationBar('Cash', 10, AppColors.success),
        ],
      ),
    );
  }

  Widget _buildInfoSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.primaryText,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
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

  Widget _buildAllocationBar(String label, int percentage, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
              ),
              Text(
                '$percentage%',
                style: TextStyle(color: color, fontSize: 14.sp),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Container(
            height: 6.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.r),
              color: AppColors.border,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6.r,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _handleInvestOrWithdraw('Invest'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text(
                'Invest',
                style: TextStyle(
                  color: AppColors.buttonText,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () => _handleInvestOrWithdraw('Withdraw'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text(
                'Withdraw',
                style: TextStyle(
                  color: AppColors.buttonText,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleInvestOrWithdraw(String action) async {
    if (_folioNumbers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please create a folio first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid amount and select a folio number'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Text(
          'Confirm $action',
          style: TextStyle(color: AppColors.primaryText, fontSize: 18.sp),
        ),
        content: Text(
          'You are about to $action ₹${_amountController.text} in ${widget.name} using folio ${_folioController.text}',
          style: TextStyle(color: AppColors.secondaryText, fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.error, fontSize: 14.sp),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Confirm',
              style: TextStyle(color: AppColors.primaryGold, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      setState(() => _isLoading = true);
      try {
        final amount = int.parse(_amountController.text);
        if (action == 'Invest') {
          await _walletService.deposit(amount);
        } else {
          await _walletService.withdraw(amount);
        }
        setState(() => _isLoading = false);
        await _showSuccessDialog(action);
      } catch (e) {
        setState(() => _isLoading = false);
        await _showErrorDialog(e.toString());
      }
    }
  }

  Future<void> _showSuccessDialog(String action) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.checkCircle,
              color: AppColors.success,
              size: 48.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              '$action Successful!',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Your $action of ₹${_amountController.text} has been processed successfully.',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: AppColors.primaryGold,
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.exclamationCircle,
              color: AppColors.error,
              size: 48.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              'Error',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: AppColors.primaryGold,
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutFund() {
    return _buildSectionContainer(
      title: 'About the Fund',
      child: Text(
        'This fund seeks to generate long-term capital growth by investing primarily in large-cap equity securities.',
        style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
      ),
    );
  }

  Widget _buildFundManager() {
    return _buildSectionContainer(
      title: 'Fund Manager',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rahul Sharma',
            style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4.h),
          Text(
            'Experience: 12 years',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            'Rahul has managed this fund since its inception in 2015 with a proven track record.',
            style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformance() {
    return _buildSectionContainer(
      title: 'Performance',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPerformanceItem('1 Year Return', '12.5%'),
          _buildPerformanceItem('3 Year Return', '35.0%'),
          _buildPerformanceItem('5 Year Return', '60.0%'),
          _buildPerformanceItem('Since Inception', '120.0%'),
          SizedBox(height: 12.h),
          Text(
            'Benchmark: Nifty 50',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
          ),
          _buildPerformanceItem('Benchmark 1Y Return', '10.0%'),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp)),
          Text(value,
              style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFundamentals() {
    return _buildSectionContainer(
      title: 'Fundamentals',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFundamentalItem('Expense Ratio', '1.5%'),
          _buildFundamentalItem('Turnover Ratio', '40%'),
          _buildFundamentalItem('Alpha', '3.0'),
          _buildFundamentalItem('Beta', '1.2'),
          _buildFundamentalItem('Sharpe Ratio', '1.5'),
        ],
      ),
    );
  }

  Widget _buildFundamentalItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp)),
          Text(value,
              style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFinancials() {
    return _buildSectionContainer(
      title: 'Financials',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFinancialItem('Total Assets', '₹5,000 Cr'),
          _buildFinancialItem('Number of Units', '50,00,000'),
          _buildFinancialItem('NAV', '₹25.50'),
        ],
      ),
    );
  }

  Widget _buildFinancialItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp)),
          Text(value,
              style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAssetAllocation() {
    return _buildSectionContainer(
      title: 'Asset Allocation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAllocationBar('Equity', 70, AppColors.primaryGold),
          _buildAllocationBar('Debt', 20, AppColors.accent),
          _buildAllocationBar('Cash', 10, AppColors.success),
        ],
      ),
    );
  }

  Widget _buildShareholdingPattern() {
    return _buildSectionContainer(
      title: 'Top Holdings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHoldingItem('ABC Ltd.', '8%'),
          _buildHoldingItem('XYZ Corp.', '6%'),
          _buildHoldingItem('PQR Industries', '5%'),
          _buildHoldingItem('LMN Ltd.', '4%'),
          _buildHoldingItem('DEF Corp.', '3%'),
        ],
      ),
    );
  }

  Widget _buildHoldingItem(String company, String percentage) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(company,
              style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp)),
          Text(percentage,
              style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFAQs() {
    return _buildSectionContainer(
      title: 'FAQs',
      child: Column(
        children: [
          ExpansionTile(
            title: Text('What is the investment objective of this fund?',
                style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp)),
            children: [
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Text(
                    'The fund aims to provide long-term capital appreciation by investing in a diversified portfolio of large-cap equity securities.',
                    style: TextStyle(
                        color: AppColors.secondaryText, fontSize: 14.sp)),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('What is the minimum investment amount?',
                style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp)),
            children: [
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Text('The minimum investment amount is ₹1,000.',
                    style: TextStyle(
                        color: AppColors.secondaryText, fontSize: 14.sp)),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('How can I redeem my investment?',
                style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp)),
            children: [
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Text(
                    'You can redeem your investment through the app by navigating to the "Redeem" section in your portfolio.',
                    style: TextStyle(
                        color: AppColors.secondaryText, fontSize: 14.sp)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({required String title, required Widget child}) {
    return Container(
      padding: EdgeInsets.all(16.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}