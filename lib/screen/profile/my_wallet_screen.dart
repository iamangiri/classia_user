import 'dart:convert';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:intl/intl.dart';
import '../../service/apiservice/wallet_service.dart';

class MyWalletScreen extends StatefulWidget {
  const MyWalletScreen({Key? key}) : super(key: key);

  @override
  _MyWalletScreenState createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends State<MyWalletScreen> {
  late Razorpay _razorpay;
  late WalletService _walletService;

  double walletBalance = 0.0;
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> filteredTransactions = [];
  Map<String, dynamic>? paginationData;
  String selectedFilter = "All";
  final List<String> filters = ["All", "Deposit", "Withdraw"];

  final TextEditingController _amountController = TextEditingController();
  bool _isProcessingPayment = false;
  bool _isLoadingTransactions = false;
  bool _isLoadingBalance = false;
  int _currentPage = 1;
  final int _sizePerPage = 20;

  @override
  void initState() {
    super.initState();
    _walletService = WalletService(token: '');
    _initializeRazorpay();
    _loadWalletData();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // Load both balance and transactions
  Future<void> _loadWalletData() async {
    await Future.wait([
      _loadWalletBalance(),
      _loadTransactions(),
    ]);
  }

  // Fetch wallet balance from API
  Future<void> _loadWalletBalance() async {
    if (_isLoadingBalance) return;

    setState(() {
      _isLoadingBalance = true;
    });

    try {
      final result = await _walletService.getWalletBalance();

      if (result['status'] == true && result['data'] != null) {
        final data = result['data'];
        // Use mainBalance from the API response
        final balance = data['mainBalance'];
        setState(() {
          walletBalance = double.tryParse(balance?.toString() ?? '0') ?? 0.0;
          _isLoadingBalance = false;
        });
      } else {
        setState(() {
          _isLoadingBalance = false;
        });
      }
    } catch (e) {
      print('Error loading wallet balance: $e');
      setState(() {
        _isLoadingBalance = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load wallet balance: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadTransactions() async {
    if (_isLoadingTransactions) return;

    setState(() {
      _isLoadingTransactions = true;
    });

    try {
      final result = await WalletService.TransactionList(
        page: _currentPage,
        sizePerPage: _sizePerPage,
      );

      if (result['status'] == true && result['data'] != null) {
        final data = result['data'];
        final transactionList = List<Map<String, dynamic>>.from(
            data['transactionList'] ?? []
        );

        setState(() {
          transactions = transactionList;
          paginationData = {
            'totalRecords': data['totalRecords'],
            'totalPages': data['totalPages'],
            'currentPage': data['currentPage'],
          };
          _applyFilter();
          _isLoadingTransactions = false;
        });
      }
    } catch (e) {
      print('Error loading transactions: $e');
      setState(() {
        _isLoadingTransactions = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load transactions: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    }
  }

  void _applyFilter() {
    if (selectedFilter == "All") {
      filteredTransactions = transactions;
    } else {
      filteredTransactions = transactions.where((txn) {
        final type = txn['transactionType']?.toString().toUpperCase() ?? '';
        // Map "Withdraw" filter to "SUBSCRIPTION" type from API
        if (selectedFilter.toUpperCase() == "WITHDRAW") {
          return type == "SUBSCRIPTION";
        }
        return type == selectedFilter.toUpperCase();
      }).toList();
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_isProcessingPayment) return;

    setState(() {
      _isProcessingPayment = true;
    });

    final amount = double.parse(_amountController.text);

    try {
      final depositResponse = await _walletService.depositMoney(
        amount: amount,
        depositDetails: {
          'paymentId': response.paymentId ?? '',
          'orderId': response.orderId ?? '',
          'signature': response.signature ?? '',
          'timestamp': DateTime.now().toIso8601String(),
          'method': 'razorpay',
        },
      );

      print('Basket Deposit API Response: $depositResponse');

      _amountController.clear();

      // Reload wallet data (balance + transactions)
      await _loadWalletData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('₹$amount added successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error calling deposit API: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment successful but failed to update wallet: ${e.toString()}'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _isProcessingPayment = false;
    });

    debugPrint('Payment Error Code: ${response.code}');
    debugPrint('Payment Error Message: ${response.message}');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Failed: ${response.message ?? "Unknown error occurred"}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('External Wallet: ${response.walletName}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    }
  }

  void _openRazorpayCheckout(double amount) {
    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag',
      'amount': (amount * 100).toInt(),
      'name': 'Classia Capital',
      'description': 'Wallet Recharge',
      'prefill': {
        'contact': '8888888888',
        'email': 'test@razorpay.com'
      },
      'external': {
        'wallets': ['paytm']
      },
      'theme': {
        'color': '#D4AF37'
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open payment gateway: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
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
            onPressed: _isProcessingPayment
                ? null
                : () {
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
            child: _isProcessingPayment
                ? SizedBox(
              width: 20.w,
              height: 20.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.buttonText,
              ),
            )
                : Text('Proceed to Pay', style: TextStyle(color: AppColors.buttonText)),
          ),
        ],
      ),
    );
  }

  Future<void> _refresh() async {
    await _loadWalletData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(title: 'My Wallet'),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primaryGold,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
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
          _isLoadingBalance
              ? SizedBox(
            height: 40.h,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          )
              : Text(
            '₹${walletBalance.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.white.withOpacity(0.8), size: 16.sp),
              SizedBox(width: 4.w),
              Text(
                '${transactions.where((t) => t['transactionType']?.toString().toUpperCase() == 'DEPOSIT').length} Deposits',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              SizedBox(width: 12.w),
              Icon(Icons.trending_down, color: Colors.white.withOpacity(0.8), size: 16.sp),
              SizedBox(width: 4.w),
              Text(
                '${transactions.where((t) => t['transactionType']?.toString().toUpperCase() == 'SUBSCRIPTION').length} Withdrawals',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return _buildActionButton(
      'Add Money',
      Icons.add_circle_outline,
      AppColors.primaryGold,
      _isProcessingPayment ? null : _showAddMoneyDialog,
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: onTap == null ? color.withOpacity(0.5) : color, size: 28.sp),
            SizedBox(width: 12.w),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: onTap == null ? AppColors.primaryText.withOpacity(0.5) : AppColors.primaryText,
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
                    setState(() {
                      selectedFilter = filter;
                      _applyFilter();
                    });
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
    if (_isLoadingTransactions) {
      return Container(
        height: 200.h,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold),
        ),
      );
    }

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
        final type = txn['transactionType']?.toString().toUpperCase() ?? '';
        final isDeposit = type == 'DEPOSIT';
        final amount = double.tryParse(txn['amount']?.toString() ?? '0') ?? 0.0;

        // Handle transactionData - it can be a Map or contain nested data
        final transactionData = txn['transactionData'];
        String paymentId = 'N/A';
        String method = 'WALLET';

        if (transactionData != null && transactionData is Map<String, dynamic>) {
          paymentId = transactionData['paymentId']?.toString() ?? 'N/A';
          method = transactionData['method']?.toString() ?? 'WALLET';

          // If amount is 0, try to get it from transactionData
          if (amount == 0.0 && transactionData['amount'] != null) {
            final dataAmount = double.tryParse(transactionData['amount']?.toString() ?? '0') ?? 0.0;
            if (dataAmount > 0) {
              // Update the amount variable for display
              txn['amount'] = dataAmount.toString();
            }
          }
        }

        final dateStr = txn['createdAt'];
        DateTime? date;

        try {
          date = dateStr != null ? DateTime.parse(dateStr) : DateTime.now();
        } catch (e) {
          date = DateTime.now();
        }

        // Get the final amount for display
        final displayAmount = double.tryParse(txn['amount']?.toString() ?? '0') ?? 0.0;

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isDeposit ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: (isDeposit ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  isDeposit ? Icons.add_circle : Icons.remove_circle,
                  color: isDeposit ? Colors.green : Colors.red,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDeposit ? 'Wallet Deposit' : 'Basket Subscription',
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
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.payment, size: 10.sp, color: AppColors.secondaryText),
                        SizedBox(width: 4.w),
                        Text(
                          method.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (paymentId != 'N/A' && paymentId != 'null') ...[
                      SizedBox(height: 2.h),
                      Text(
                        'Payment ID: $paymentId',
                        style: TextStyle(fontSize: 9.sp, color: AppColors.secondaryText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isDeposit ? '+' : '-'}₹${displayAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: isDeposit ? Colors.green : Colors.red,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: (isDeposit ? Colors.green : Colors.red).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: isDeposit ? Colors.green : Colors.red,
                      ),
                    ),
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