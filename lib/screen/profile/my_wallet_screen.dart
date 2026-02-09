import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../service/apiservice/wallet_service.dart';
import '../../utills/themes/light_app_theme.dart';
import '../../utills/constent/user_constant.dart';
import 'transaction_details_screen.dart';
import 'add_money_screen.dart';

class MyWalletScreen extends StatefulWidget {
  const MyWalletScreen({Key? key}) : super(key: key);

  @override
  _MyWalletScreenState createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends State<MyWalletScreen>
    with SingleTickerProviderStateMixin {
  late WalletService _walletService;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  double walletBalance = 0.0;
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> filteredTransactions = [];
  Map<String, dynamic>? paginationData;
  String selectedFilter = "All";
  final List<String> filters = ["All", "Deposit", "Withdraw"];

  bool _isLoadingTransactions = false;
  bool _isLoadingBalance = false;
  int _currentPage = 1;
  final int _sizePerPage = 20;

  @override
  void initState() {
    super.initState();
    _walletService = WalletService(token: UserConstants.TOKEN ?? '');
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
        final balance = data['balance'];
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
      final result = await _walletService.getTransactionList(
        _currentPage,
        _sizePerPage,
      );

      final transactionList =
          List<Map<String, dynamic>>.from(result['transactions'] ?? []);

      setState(() {
        transactions = transactionList;
        paginationData = result['pagination'];
        _applyFilter();
        _isLoadingTransactions = false;
      });
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          margin: EdgeInsets.all(16.w),
        ),
      );
    }
  }

  void _navigateToAddMoney() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMoneyScreen(
          currentBalance: walletBalance,
          onPaymentSuccess: () {
            // Reload wallet data when coming back
            _loadWalletData();
          },
        ),
      ),
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
          colors: [
            AppTheme.primaryDarkBlue,
            AppTheme.primaryDarkBlue.withOpacity(0.85)
          ],
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
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

  Widget _buildQuickActions() {
    return GestureDetector(
      onTap: _navigateToAddMoney,
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
            SizedBox(width: 6.w),
            Text(
              'Transaction History',
              style: TextStyle(
                fontSize: 16.sp,
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
                Icon(Icons.filter_list_rounded,
                    size: 18.sp, color: AppTheme.primaryGold),
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
                Icon(Icons.keyboard_arrow_down,
                    size: 18.sp, color: AppTheme.primaryGold),
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
                                  colors: [
                                    AppTheme.primaryGold,
                                    Color(0xFFB8860B)
                                  ],
                                )
                              : null,
                          color: isSelected ? null : AppTheme.lightBackground,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryGold
                                : AppTheme.border,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          filter,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textPrimary,
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
      itemBuilder: (context, index) =>
          _buildTransactionItem(filteredTransactions[index]),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> txn) {
    final type = txn['transactionType']?.toString().toUpperCase() ?? '';
    final isDeposit = type == 'DEPOSIT';
    final displayAmount =
        double.tryParse(txn['amount']?.toString() ?? '0') ?? 0.0;

    // Extract payment method from different possible locations
    String method = 'WALLET';
    if (txn['paymentGateway'] != null && txn['paymentGateway'].toString().isNotEmpty) {
      method = txn['paymentGateway'].toString();
    } else if (txn['paymentMethod'] != null && txn['paymentMethod'].toString().isNotEmpty) {
      method = txn['paymentMethod'].toString();
    }

    final dateStr = txn['createdAt'] ?? txn['CreatedAt'];
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
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDeposit
                ? AppTheme.successGreen.withOpacity(0.1)
                : AppTheme.errorRed.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: (isDeposit ? AppTheme.successGreen : AppTheme.errorRed)
                    .withOpacity(0.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                isDeposit ? Icons.south_west_rounded : Icons.north_east_rounded,
                color: isDeposit ? AppTheme.successGreen : AppTheme.errorRed,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 12.w),

            // Details - Takes remaining space
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    txn['description'] ??
                        (isDeposit ? 'Wallet Deposit' : 'Basket Subscription'),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5.sp,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 10.sp,
                        color: AppTheme.textSecondary,
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          DateFormat('dd MMM, yyyy').format(date),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // Amount Section - Fixed width constraint
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${isDeposit ? '+' : '-'}₹${displayAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color:
                          isDeposit ? AppTheme.successGreen : AppTheme.errorRed,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    method.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: AppTheme.textSecondary.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            SizedBox(width: 6.w),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12.sp,
              color: AppTheme.textSecondary.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}