import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:intl/intl.dart';
import '../../service/apiservice/wallet_service.dart';
import '../../utills/themes/light_app_theme.dart';
import '../../widget/common_app_bar.dart';
import 'transaction_details_screen.dart';


class MyWalletScreen extends StatefulWidget {
  const MyWalletScreen({Key? key}) : super(key: key);

  @override
  _MyWalletScreenState createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends State<MyWalletScreen> with SingleTickerProviderStateMixin {
  late Razorpay _razorpay;
  late WalletService _walletService;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _loadWalletData() async {
    await Future.wait([
      _loadWalletBalance(),
      _loadTransactions(),
    ]);
  }

  Future<void> _loadWalletBalance() async {
    if (_isLoadingBalance) return;

    setState(() => _isLoadingBalance = true);

    try {
      final result = await _walletService.getWalletBalance();

      if (result['status'] == true && result['data'] != null) {
        final data = result['data'];
        final balance = data['mainBalance'];
        setState(() {
          walletBalance = double.tryParse(balance?.toString() ?? '0') ?? 0.0;
          _isLoadingBalance = false;
        });
      } else {
        setState(() => _isLoadingBalance = false);
      }
    } catch (e) {
      print('Error loading wallet balance: $e');
      setState(() => _isLoadingBalance = false);
      _showErrorSnackBar('Failed to load wallet balance');
    }
  }

  Future<void> _loadTransactions() async {
    if (_isLoadingTransactions) return;

    setState(() => _isLoadingTransactions = true);

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
      setState(() => _isLoadingTransactions = false);
      _showErrorSnackBar('Failed to load transactions');
    }
  }

  void _applyFilter() {
    if (selectedFilter == "All") {
      filteredTransactions = transactions;
    } else {
      filteredTransactions = transactions.where((txn) {
        final type = txn['transactionType']?.toString().toUpperCase() ?? '';
        if (selectedFilter.toUpperCase() == "WITHDRAW") {
          return type == "SUBSCRIPTION";
        }
        return type == selectedFilter.toUpperCase();
      }).toList();
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          margin: EdgeInsets.all(16.w),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          margin: EdgeInsets.all(16.w),
        ),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_isProcessingPayment) return;

    setState(() => _isProcessingPayment = true);

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

      _amountController.clear();
      await _loadWalletData();
      _showSuccessSnackBar('₹$amount added successfully!');
    } catch (e) {
      print('Error calling deposit API: $e');
      _showErrorSnackBar('Payment successful but failed to update wallet');
    } finally {
      setState(() => _isProcessingPayment = false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessingPayment = false);
    _showErrorSnackBar('Payment Failed: ${response.message ?? "Unknown error"}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showSuccessSnackBar('External Wallet: ${response.walletName}');
  }

  void _openRazorpayCheckout(double amount) {
    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag',
      'amount': (amount * 100).toInt(),
      'name': 'Classia Capital',
      'description': 'Wallet Recharge',
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
      'external': {'wallets': ['paytm']},
      'theme': {'color': '#DAA520'}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      _showErrorSnackBar('Failed to open payment gateway');
    }
  }

  // ✅ Fixed: Using StatefulBuilder and SingleChildScrollView to prevent overflow
  void _showAddMoneyDialog() {
    _amountController.clear();
    int? selectedAmount;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: SingleChildScrollView(
              // ✅ Prevents overflow when keyboard opens
              child: Container(
                constraints: BoxConstraints(maxWidth: 400.w),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryDarkBlue.withOpacity(0.12),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    _buildDialogHeader(),

                    // Content
                    Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Amount Input
                          _buildAmountInput(),

                          SizedBox(height: 24.h),

                          // Quick Select
                          _buildQuickSelectSection(selectedAmount, (amt) {
                            setDialogState(() {
                              selectedAmount = amt;
                              _amountController.text = amt.toString();
                            });
                          }),

                          SizedBox(height: 32.h),

                          // Action Buttons
                          _buildDialogActions(dialogContext),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDialogHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryDarkBlue,
            AppTheme.primaryDarkBlue.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.r),
          topRight: Radius.circular(28.r),
        ),
      ),
      child: Column(
        children: [
          // Animated Icon Container
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryGold.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppTheme.primaryGold,
                    size: 36.sp,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20.h),
          Text(
            'Add Money',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'Top up your wallet balance',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.currency_rupee,
                color: AppTheme.primaryGold,
                size: 16.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              'Enter Amount',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightBackground,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppTheme.primaryGold.withOpacity(0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGold.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              prefixIcon: Container(
                width: 60.w,
                alignment: Alignment.center,
                child: Text(
                  '₹',
                  style: TextStyle(
                    color: AppTheme.primaryGold,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              hintText: '0',
              hintStyle: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.4),
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 24.h,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickSelectSection(int? selectedAmount, Function(int) onSelect) {
    final amounts = [100, 500, 1000, 2000, 5000];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryDarkBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.touch_app_rounded,
                color: AppTheme.primaryDarkBlue,
                size: 16.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              'Quick Select',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: amounts.map((amt) {
            final isSelected = _amountController.text == amt.toString();
            return GestureDetector(
              onTap: () => onSelect(amt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                    colors: [AppTheme.primaryGold, AppTheme.primaryGold.withOpacity(0.85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                      : null,
                  color: isSelected ? null : AppTheme.lightBackground,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryGold
                        : AppTheme.textSecondary.withOpacity(0.15),
                    width: isSelected ? 2 : 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: AppTheme.primaryGold.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                      : null,
                ),
                child: Text(
                  '₹$amt',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDialogActions(BuildContext dialogContext) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 18.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
                side: BorderSide(
                  color: AppTheme.textSecondary.withOpacity(0.25),
                  width: 1.5,
                ),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryGold, Color(0xFFB8860B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGold.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isProcessingPayment
                  ? null
                  : () {
                if (_amountController.text.isNotEmpty) {
                  final amount = double.tryParse(_amountController.text);
                  if (amount != null && amount > 0) {
                    Navigator.pop(dialogContext);
                    _openRazorpayCheckout(amount);
                  } else {
                    _showErrorSnackBar('Please enter a valid amount');
                  }
                } else {
                  _showErrorSnackBar('Please enter an amount');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: 18.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: _isProcessingPayment
                  ? SizedBox(
                width: 24.w,
                height: 24.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Proceed to Pay',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _refresh() async {
    await _loadWalletData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.screenBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDarkBlue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Wallet',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: Colors.white, size: 24.sp),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppTheme.primaryGold,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWalletBalanceCard(),
                  SizedBox(height: 24.h),
                  _buildQuickActions(),
                  SizedBox(height: 28.h),
                  _buildTransactionSection(),
                ],
              ),
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
          colors: [AppTheme.primaryDarkBlue, AppTheme.primaryDarkBlue.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDarkBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned(
            right: -30.w,
            top: -30.h,
            child: Container(
              width: 150.w,
              height: 150.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            left: -20.w,
            bottom: -40.h,
            child: Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGold.withOpacity(0.1),
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(28.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_rounded,
                            color: AppTheme.primaryGold,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Available Balance',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: AppTheme.successGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppTheme.successGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                _isLoadingBalance
                    ? SizedBox(
                  height: 48.h,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGold,
                      strokeWidth: 3,
                    ),
                  ),
                )
                    : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGold,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      walletBalance.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 42.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),


              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, Color color, String value, String label) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return GestureDetector(
      onTap: _isProcessingPayment ? null : _showAddMoneyDialog,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppTheme.primaryGold.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGold.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryGold, Color(0xFFB8860B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGold.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 28.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Money',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Top up your wallet balance instantly',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppTheme.lightBackground,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppTheme.primaryGold,
                size: 18.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTransactionHeader(),
        SizedBox(height: 16.h),
        _buildTransactionList(),
      ],
    );
  }

  Widget _buildTransactionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryDarkBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                color: AppTheme.primaryDarkBlue,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Transaction History',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: _showFilterOptions,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppTheme.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.filter_list_rounded, size: 18.sp, color: AppTheme.primaryGold),
                SizedBox(width: 6.w),
                Text(
                  selectedFilter,
                  style: TextStyle(
                    color: AppTheme.primaryGold,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.keyboard_arrow_down, size: 18.sp, color: AppTheme.primaryGold),
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
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Filter Transactions',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: filters.map((filter) {
                final isSelected = selectedFilter == filter;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilter = filter;
                          _applyFilter();
                        });
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                            colors: [AppTheme.primaryGold, Color(0xFFB8860B)],
                          )
                              : null,
                          color: isSelected ? null : AppTheme.lightBackground,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryGold : AppTheme.border,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          filter,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textPrimary,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_isLoadingTransactions) {
      return Container(
        height: 200.h,
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGold),
        ),
      );
    }

    if (filteredTransactions.isEmpty) {
      return Container(
        height: 250.h,
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppTheme.border),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 48.sp,
                  color: AppTheme.textSecondary.withOpacity(0.5),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'No transactions yet',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Your transactions will appear here',
                style: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.7),
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredTransactions.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) => _buildTransactionItem(filteredTransactions[index]),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> txn) {
    final type = txn['transactionType']?.toString().toUpperCase() ?? '';
    final isDeposit = type == 'DEPOSIT';
    final displayAmount = double.tryParse(txn['amount']?.toString() ?? '0') ?? 0.0;

    final transactionData = txn['transactionData'];
    String method = 'WALLET';
    if (transactionData != null && transactionData is Map<String, dynamic>) {
      method = transactionData['method']?.toString() ?? 'WALLET';
    }

    final dateStr = txn['createdAt'];
    DateTime date;
    try {
      date = dateStr != null ? DateTime.parse(dateStr) : DateTime.now();
    } catch (e) {
      date = DateTime.now();
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailsScreen(transaction: txn),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDeposit
                ? AppTheme.successGreen.withOpacity(0.2)
                : AppTheme.errorRed.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: (isDeposit ? AppTheme.successGreen : AppTheme.errorRed).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                isDeposit ? Icons.south_west_rounded : Icons.north_east_rounded,
                color: isDeposit ? AppTheme.successGreen : AppTheme.errorRed,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 14.w),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDeposit ? 'Wallet Deposit' : 'Basket Subscription',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12.sp,
                        color: AppTheme.textSecondary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        DateFormat('dd MMM yyyy, hh:mm a').format(date),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightBackground,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      method.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Amount & Arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isDeposit ? '+' : '-'}₹${displayAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17.sp,
                    color: isDeposit ? AppTheme.successGreen : AppTheme.errorRed,
                  ),
                ),
                SizedBox(height: 8.h),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.sp,
                  color: AppTheme.textSecondary.withOpacity(0.5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    _amountController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}