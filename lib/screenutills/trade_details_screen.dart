import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/screenutills/create_folio_screen.dart';
import 'package:classia_amc/service/apiservice/wallet_service.dart';
import 'package:classia_amc/service/apiservice/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final List<Map<String, dynamic>> performances = [
    {
      "stockId": 1,
      "symbol": "AAPL",
      "name": "Apple Inc.",
      "closingPrice": 150.25,
      "percentChange": 1.23,
    },
    {
      "stockId": 2,
      "symbol": "GOOGL",
      "name": "Alphabet Inc.",
      "closingPrice": 2800.50,
      "percentChange": -0.45,
    },
  ];

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
        backgroundColor: AppColors.primaryGold,
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
                color: AppColors.primaryText,
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
              color: AppColors.primaryText,
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
              color: AppColors.primaryText,
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
                  _buildFundDetailsSection(),
                  SizedBox(height: 24.h),
                  _buildStockPerformanceSection(),
                  SizedBox(height: 24.h),
                  _buildRecentTransactions(),
                  SizedBox(height: 24.h),
                  _buildFolioInputSection(),
                  SizedBox(height: 20.h),
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
              'JOCECY Special: Real-time JOCECY points show the fund’s performance, allowing you to invest and withdraw instantly.',
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

  Widget _buildFundDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildDetailCard('AUM', '₹12,450 Cr')),
            SizedBox(width: 12.w),
            Expanded(child: _buildDetailCard('Min. Invest', '₹500')),
            SizedBox(width: 12.w),
            Expanded(child: _buildDetailCard('Jockey Point', '5.75%')),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: _buildDetailCard('1Y Return', '18.6%')),
            SizedBox(width: 12.w),
            Expanded(child: _buildDetailCard('Risk Level', 'Moderate')),
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
          _buildInfoItem('Fund Manager', '10+ Years Experience'),
          _buildInfoItem('Sector Allocation', 'Diversified Equity'),
          _buildInfoItem('Exit Load', '1% if redeemed within 1 year'),
          Divider(color: AppColors.border),
          SizedBox(height: 12.h),
          _buildInfoSectionHeader('Asset Allocation'),
          SizedBox(height: 8.h),
          _buildAllocationBar('Equity', 78, AppColors.primaryGold),
          _buildAllocationBar('Debt', 18, AppColors.accent),
          _buildAllocationBar('Cash', 4, AppColors.success),
        ],
      ),
    );
  }

  Widget _buildStockPerformanceSection() {
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
          _buildInfoSectionHeader('Stock Performance'),
          SizedBox(height: 12.h),
          ...performances.map((stock) => _buildStockItem(stock)).toList(),
        ],
      ),
    );
  }

  Widget _buildStockItem(Map<String, dynamic> stock) {
    final percentChange = stock['percentChange'] as double;
    final isPositive = percentChange >= 0;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: isPositive ? AppColors.success : AppColors.error,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stock['symbol']} - ${stock['name']}',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '\$${stock['closingPrice'].toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : ''}${percentChange.toStringAsFixed(2)}%',
            style: TextStyle(
              color: isPositive ? AppColors.success : AppColors.error,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
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

  Widget _buildRecentTransactions() {
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
          _buildInfoSectionHeader('Recent Transactions'),
          SizedBox(height: 12.h),
          _buildTransactionItem(
              'Invest', '₹10,000', '2025-04-20', AppColors.success),
          _buildTransactionItem(
              'Withdraw', '₹5,000', '2025-04-15', AppColors.error),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
      String type, String amount, String date, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                type == 'Invest' ? Icons.arrow_upward : Icons.arrow_downward,
                color: color,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                type,
                style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
              ),
              Text(
                date,
                style:
                TextStyle(color: AppColors.secondaryText, fontSize: 12.sp),
              ),
            ],
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
                  style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
                ),
                SizedBox(height: 8.h),
                ElevatedButton(
                  onPressed: () async {
                    final newFolio = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateFolioScreen()),
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
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
              onPressed: _isLoading ? null : () => _handleInvestOrWithdraw('Withdraw'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.buttonText, size: 20.sp),
                SizedBox(width: 12.w),
                Text(
                  '$action Successful!',
                  style: TextStyle(color: AppColors.buttonText, fontSize: 14.sp),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}