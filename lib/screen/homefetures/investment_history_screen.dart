import 'package:cached_network_image/cached_network_image.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/service/apiservice/wallet_service.dart';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:classia_amc/screenutills/trade_details_screen.dart';


class InvestmentHistoryScreen extends StatefulWidget {
  const InvestmentHistoryScreen({Key? key}) : super(key: key);

  @override
  _InvestmentHistoryScreenState createState() =>
      _InvestmentHistoryScreenState();
}

class _InvestmentHistoryScreenState extends State<InvestmentHistoryScreen> {
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

    setState(() {
      _walletService = WalletService(token: '${UserConstants.TOKEN}');
    });
  }

  Future<void> _fetchTransactions() async {
    if (!_hasMore || _isListLoading) return;
    setState(() => _isListLoading = true);
    try {
      final response = await _walletService.getTransactionList(_page, _limit,transactionType: 'DEPOSIT');
      setState(() {
        transactions
            .addAll(List<Map<String, dynamic>>.from(response['transactions']));
        _total = response['pagination']['total'];
        _hasMore = transactions.length < _total;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: 'Investment History',
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInvestmentSummarySection(),
            SizedBox(height: 20.h),
            Text(
              'Investment History',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter: $selectedFilter',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 14.sp,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showFilterOptions(context),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
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
            Expanded(child: _buildInvestmentList(context)),
          ],
        ),
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
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Filter',
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

  Widget _buildInvestmentSummarySection() {
// Calculate total invested from transactions
    final totalInvested = transactions.fold<double>(
      0,
      (sum, txn) => sum + (txn['Amount'] as int).toDouble(),
    );
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Text(
            'Total Invested',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '₹${totalInvested.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentList(BuildContext context) {
    List<Map<String, dynamic>> filteredTransactions =
        transactions.where((transaction) {
      if (selectedFilter == 'All') return true;

      DateTime transactionDate = DateTime.parse(transaction['CreatedAt']);
      DateTime now = DateTime.now();

      if (selectedFilter == '1 Day') {
        return transactionDate.isAfter(now.subtract(Duration(days: 1)));
      } else if (selectedFilter == '1 Week') {
        return transactionDate.isAfter(now.subtract(Duration(days: 7)));
      } else if (selectedFilter == '1 Month') {
        return transactionDate
            .isAfter(DateTime(now.year, now.month - 1, now.day));
      } else if (selectedFilter == '3 Months') {
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
              'Your deposit history will appear here',
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
// Mock logo and name since API doesn't provide them
    const mockLogo = 'https://via.placeholder.com/50';
    final mockName = 'Transaction #${transaction['ID']}';
    final amount = (transaction['Amount'] as int).toDouble().toStringAsFixed(2);
    final date =
        DateTime.parse(transaction['CreatedAt']).toString().split('.')[0];

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TradingDetailsScreen(
              logo: mockLogo,
              name: mockName,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
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
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          leading: ClipOval(
            child: CachedNetworkImage(
              imageUrl: mockLogo,
              width: 40.w,
              height: 40.h,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                width: 40.w,
                height: 40.h,
                color: AppColors.border,
                child: Icon(
                  Icons.image,
                  color: AppColors.disabled,
                  size: 24.sp,
                ),
              ),
            ),
          ),
          title: Text(
            mockName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
              fontSize: 16.sp,
            ),
          ),
          subtitle: Text(
            date,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.secondaryText,
            ),
          ),
          trailing: Text(
            '₹$amount',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.success,
              fontSize: 16.sp,
            ),
          ),
        ),
      ),
    );
  }
}
