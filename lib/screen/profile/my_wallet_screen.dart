import 'dart:convert';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:intl/intl.dart';

class MyWalletScreen extends StatefulWidget {
  const MyWalletScreen({Key? key}) : super(key: key);

  @override
  _MyWalletScreenState createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends State<MyWalletScreen> {
  late Razorpay _razorpay;
  double walletBalance = 0.0;
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> linkedAccounts = [];
  String selectedFilter = "All";
  final List<String> filters = ["All", "Added", "Deducted", "1 Week", "1 Month"];

  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
    _loadWalletData();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _loadWalletData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      walletBalance = prefs.getDouble('wallet_balance') ?? 0.0;

      final transactionsJson = prefs.getString('transactions');
      if (transactionsJson != null) {
        transactions = List<Map<String, dynamic>>.from(
            json.decode(transactionsJson).map((item) => Map<String, dynamic>.from(item))
        );
      }

      final accountsJson = prefs.getString('linked_accounts');
      if (accountsJson != null) {
        linkedAccounts = List<Map<String, dynamic>>.from(
            json.decode(accountsJson).map((item) => Map<String, dynamic>.from(item))
        );
      }
    });
  }

  Future<void> _saveWalletData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('wallet_balance', walletBalance);
    await prefs.setString('transactions', json.encode(transactions));
    await prefs.setString('linked_accounts', json.encode(linkedAccounts));
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    final amount = double.parse(_amountController.text);
    final coins = amount; // 1 INR = 1 Coin

    setState(() {
      walletBalance += coins;
      transactions.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'ADDED',
        'amount': amount,
        'coins': coins,
        'description': 'Wallet Recharge',
        'paymentId': response.paymentId,
        'date': DateTime.now().toIso8601String(),
        'status': 'SUCCESS'
      });
    });

    _saveWalletData();
    _amountController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('₹$amount added successfully! You got $coins coins'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message}'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
  }

  void _openRazorpayCheckout(double amount) {
    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag', // Razorpay Test Key
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': 'Classia Capital',
      'description': 'Wallet Recharge',
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
      'theme': {'color': '#D4AF37'}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _deductCoinsForJockeyTrading() {
    const coinsToDeduct = 10.0;

    if (walletBalance >= coinsToDeduct) {
      setState(() {
        walletBalance -= coinsToDeduct;
        transactions.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'type': 'DEDUCTED',
          'amount': coinsToDeduct,
          'coins': coinsToDeduct,
          'description': 'Jockey Trading Fee',
          'date': DateTime.now().toIso8601String(),
          'status': 'SUCCESS'
        });
      });
      _saveWalletData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('10 coins deducted for Jockey Trading'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient balance! Please recharge your wallet'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showAddMoneyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Add Money to Wallet',
          style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.primaryText),
              decoration: InputDecoration(
                labelText: 'Enter Amount (₹)',
                labelStyle: TextStyle(color: AppColors.secondaryText),
                prefixIcon: Icon(Icons.currency_rupee, color: AppColors.primaryGold),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.primaryGold),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 8.w,
              children: [100, 500, 1000, 2000].map((amt) {
                return ElevatedButton(
                  onPressed: () => _amountController.text = amt.toString(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.border,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: Text('₹$amt', style: TextStyle(color: AppColors.primaryText)),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_amountController.text.isNotEmpty) {
                final amount = double.tryParse(_amountController.text);
                if (amount != null && amount > 0) {
                  Navigator.pop(context);
                  _openRazorpayCheckout(amount);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: Text('Proceed to Pay', style: TextStyle(color: AppColors.buttonText)),
          ),
        ],
      ),
    );
  }







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(title: 'My Wallet'),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWalletBalanceCard(),
              SizedBox(height: 20.h),
              _buildQuickActions(),
              SizedBox(height: 20.h),
              _buildTransactionHeader(),
              SizedBox(height: 12.h),
              _buildTransactionList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletBalanceCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryGold, Color(0xFFB8860B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.3),
            blurRadius: 12.r,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Wallet Balance',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              Icon(Icons.account_balance_wallet, color: Colors.white, size: 28.sp),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '${walletBalance.toStringAsFixed(2)} Coins',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '≈ ₹${walletBalance.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'Add Money',
            Icons.add_circle_outline,
            AppColors.primaryGold,
            _showAddMoneyDialog,
          ),
        ),

        SizedBox(width: 12.w),
        Expanded(
          child: _buildActionButton(
            'Trade (10₹)',
            Icons.trending_up,
            Color(0xFFFF9800),
            _deductCoinsForJockeyTrading,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28.sp),
            SizedBox(height: 8.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Transaction History',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        GestureDetector(
          onTap: _showFilterOptions,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.filter_list, size: 16.sp, color: AppColors.primaryGold),
                SizedBox(width: 4.w),
                Text(
                  selectedFilter,
                  style: TextStyle(color: AppColors.primaryGold, fontSize: 12.sp),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter Transactions',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 8.h,
              children: filters.map((filter) {
                return ElevatedButton(
                  onPressed: () {
                    setState(() => selectedFilter = filter);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedFilter == filter
                        ? AppColors.primaryGold
                        : AppColors.border,
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: selectedFilter == filter
                          ? AppColors.buttonText
                          : AppColors.primaryText,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    List<Map<String, dynamic>> filteredTransactions = transactions.where((txn) {
      if (selectedFilter == 'All') return true;
      if (selectedFilter == 'Added') return txn['type'] == 'ADDED';
      if (selectedFilter == 'Deducted') return txn['type'] == 'DEDUCTED';

      DateTime txnDate = DateTime.parse(txn['date']);
      DateTime now = DateTime.now();

      if (selectedFilter == '1 Week') {
        return txnDate.isAfter(now.subtract(Duration(days: 7)));
      } else if (selectedFilter == '1 Month') {
        return txnDate.isAfter(DateTime(now.year, now.month - 1, now.day));
      }
      return true;
    }).toList();

    if (filteredTransactions.isEmpty) {
      return Container(
        height: 200.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 60.sp, color: AppColors.secondaryText),
              SizedBox(height: 12.h),
              Text(
                'No transactions yet',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 16.sp),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final txn = filteredTransactions[index];
        final isAdded = txn['type'] == 'ADDED';
        final date = DateTime.parse(txn['date']);

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isAdded ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: (isAdded ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  isAdded ? Icons.add_circle : Icons.remove_circle,
                  color: isAdded ? Colors.green : Colors.red,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      txn['description'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                        color: AppColors.primaryText,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      DateFormat('dd MMM yyyy, hh:mm a').format(date),
                      style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isAdded ? '+' : '-'}${txn['coins']} Coins',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: isAdded ? Colors.green : Colors.red,
                    ),
                  ),
                  Text(
                    '₹${txn['amount']}',
                    style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    _amountController.dispose();
    super.dispose();
  }
}