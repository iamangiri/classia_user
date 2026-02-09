import 'package:cached_network_image/cached_network_image.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/service/apiservice/wallet_service.dart';
import 'package:classia_amc/utills/constent/app_constant.dart';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:classia_amc/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/screenutills/trade_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String selectedTab = "Lumpsum"; // Default selected tab
  String selectedFilter = "All";
  final List<String> filters = [
    "All",
    "1 Day",
    "1 Week",
    "1 Month",
    "3 Months"
  ];
  List<Map<String, dynamic>> transactions = [];
  bool _isLoading = false;
  bool _isListLoading = false;
  int _page = 1;
  int _limit = 10;
  int _total = 0;
  bool _hasMore = true;

  late WalletService _walletService;

  @override
  void initState() {
    super.initState();
    _initializeWalletService();
    _fetchTransactions();
  }

  Future<void> _initializeWalletService() async {
    if (!mounted) return;
    setState(() {
      _walletService = WalletService(token: '${UserConstants.TOKEN}');
    });
  }

  Future<void> _fetchTransactions() async {
    if (!_hasMore || _isListLoading) return;
    if (!mounted) return;
    setState(() => _isListLoading = true);
    try {
      final response = await _walletService.getTransactionList(_page, _limit);
      if (!mounted) return;
      setState(() {
        transactions
            .addAll(List<Map<String, dynamic>>.from(response['transactions']));
        _total = response['pagination']['total'];
        _hasMore = transactions.length < _total;
        if (_hasMore) _page++;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isListLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: 'Wallet',
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabBar(),
            SizedBox(height: 20.h),
            Expanded(
              child: selectedTab == "Lumpsum"
                  ? _buildLumpsumContent()
                  : _buildSipContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildTabButton("Lumpsum"),
          _buildTabButton("SIP"),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tabName) {
    bool isSelected = selectedTab == tabName;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = tabName;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGold : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Text(
              tabName,
              style: TextStyle(
                color:
                    isSelected ? AppColors.buttonText : AppColors.primaryText,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLumpsumContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBalanceSection(),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Investments & Withdrawals",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            GestureDetector(
              onTap: () => _showFilterOptions(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      size: 18.sp,
                      color: AppColors.primaryGold,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Filter',
                      style: TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          "Filter: $selectedFilter",
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 12.h),
        Flexible(
          fit: FlexFit.loose,
          child: _buildInvestmentWithdrawList(context),
        ),
      ],
    );
  }

  Widget _buildSipContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.secondaryText,
            size: 120.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            'No SIP Data Available',
            style: TextStyle(color: AppColors.primaryText, fontSize: 18.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            'SIP transaction history will appear here',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Filter",
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 8.h,
                children: filters.map((filter) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedFilter == filter
                          ? AppColors.primaryGold
                          : AppColors.border,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedFilter = filter;
                      });
                      Navigator.pop(context);
                    },
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: selectedFilter == filter
                            ? AppColors.buttonText
                            : AppColors.primaryText,
                        fontSize: 14.sp,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceSection() {
    final totalInvested = transactions
        .where((txn) => txn['transactionType'] == 'DEPOSIT')
        .fold<double>(0, (sum, txn) => sum + (txn['amount'] ?? 0).toDouble());
    final totalWithdrawn = transactions
        .where((txn) =>
            txn['transactionType'] == 'WITHDRAW' ||
            txn['transactionType'] == 'SUBSCRIPTION')
        .fold<double>(0, (sum, txn) => sum + (txn['amount'] ?? 0).toDouble());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildBalanceCard("Total Invested",
            "₹${totalInvested.toStringAsFixed(2)}", AppColors.success),
        SizedBox(width: 12.w),
        _buildBalanceCard("Total Withdrawn",
            "₹${totalWithdrawn.toStringAsFixed(2)}", AppColors.error),
      ],
    );
  }

  Widget _buildBalanceCard(String title, String amount, Color accentColor) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvestmentWithdrawList(BuildContext context) {
    List<Map<String, dynamic>> filteredTransactions =
        transactions.where((transaction) {
      if (selectedFilter == "All") return true;

      DateTime transactionDate = DateTime.parse(
          transaction['transactionDate'] ?? transaction['CreatedAt']);
      DateTime now = DateTime.now();

      if (selectedFilter == "1 Day") {
        return transactionDate.isAfter(now.subtract(Duration(days: 1)));
      } else if (selectedFilter == "1 Week") {
        return transactionDate.isAfter(now.subtract(Duration(days: 7)));
      } else if (selectedFilter == "1 Month") {
        return transactionDate
            .isAfter(DateTime(now.year, now.month - 1, now.day));
      } else if (selectedFilter == "3 Months") {
        return transactionDate
            .isAfter(DateTime(now.year, now.month - 3, now.day));
      }
      return true;
    }).toList();

    if (filteredTransactions.isEmpty && !_isListLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              color: AppColors.secondaryText,
              size: 120.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              'No Transactions Found',
              style: TextStyle(color: AppColors.primaryText, fontSize: 18.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              'Your transaction history will appear here',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredTransactions.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == filteredTransactions.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: _isListLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _fetchTransactions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
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
        return _buildTransactionItem(context, filteredTransactions[index]);
      },
    );
  }

  Widget _buildTransactionItem(
      BuildContext context, Map<String, dynamic> transaction) {
    final String type = (transaction['transactionType'] ?? '').toString();
    bool isPositive = type == 'DEPOSIT';
    const mockLogo = 'https://via.placeholder.com/50';

    final title =
        transaction['description'] ?? (isPositive ? 'Deposit' : 'Withdrawal');
    final subtitle = transaction['referenceName'] != null &&
            transaction['referenceName'].toString().isNotEmpty
        ? transaction['referenceName']
        : (transaction['transactionDate'] != null
            ? transaction['transactionDate'].toString().split('T')[0]
            : '');

    final amount = (transaction['amount'] ?? 0).toDouble().toStringAsFixed(2);
    final date = transaction['transactionDate'] != null
        ? DateTime.parse(transaction['transactionDate'].toString())
            .toString()
            .split('.')[0]
        : DateTime.parse(transaction['CreatedAt'].toString())
            .toString()
            .split('.')[0];

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TradingDetailsScreen(
              id: 0,
              logo: mockLogo,
              value: 0,
              fundName: "",
              projection: 0,
              name: '',
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6.r,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          leading: Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: mockLogo,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  color: AppColors.border.withOpacity(0.1),
                  child: Icon(
                    Icons.image,
                    color: AppColors.disabled,
                    size: 16.sp,
                  ),
                ),
              ),
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
              fontSize: 13.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.secondaryText.withOpacity(0.8),
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : '-'}₹$amount',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isPositive ? AppColors.success : AppColors.error,
                  fontSize: 14.sp,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 10.sp,
                color: AppColors.secondaryText.withOpacity(0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
