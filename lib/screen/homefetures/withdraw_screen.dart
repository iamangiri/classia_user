import 'package:cached_network_image/cached_network_image.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:classia_amc/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../screenutills/trade_details_screen.dart';

class WithdrawScreen extends StatefulWidget {
  @override
  _WithdrawScreenState createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  String selectedFilter = "All";
  final List<String> filters = ["All", "1 Day", "1 Week", "1 Month", "3 Months"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: 'Withdrawals History',
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWithdrawSummarySection(),
            SizedBox(height: 20.h),
            Text(
              'Withdrawal History',
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
            Expanded(child: _buildWithdrawalList(context)),
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
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
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

  Widget _buildWithdrawSummarySection() {
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
            'Total Withdrawn',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '₹20,000',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalList(BuildContext context) {
    List<Map<String, String>> transactions = [
      {
        'name': 'ICICI Prudential AMC',
        'logo': 'https://via.placeholder.com/50',
        'amount': '₹8,000',
        'date': '2025-02-09 15:45',
        'type': 'Withdrawal',
      },
      {
        'name': 'Axis Mutual Fund',
        'logo': 'https://via.placeholder.com/50',
        'amount': '₹5,000',
        'date': '2025-02-07 14:00',
        'type': 'Withdrawal',
      },
      {
        'name': 'Aditya Birla Sun Life AMC',
        'logo': 'https://via.placeholder.com/50',
        'amount': '₹6,000',
        'date': '2025-02-03 09:30',
        'type': 'Withdrawal',
      },
      {
        'name': 'UTI Mutual Fund',
        'logo': 'https://via.placeholder.com/50',
        'amount': '₹4,500',
        'date': '2025-02-01 08:45',
        'type': 'Withdrawal',
      },
    ];

    List<Map<String, String>> filteredTransactions = transactions.where((transaction) {
      if (selectedFilter == 'All') return true;

      DateTime transactionDate = DateTime.parse(transaction['date']!.replaceFirst(' ', 'T'));
      DateTime now = DateTime.now();

      if (selectedFilter == '1 Day') {
        return transactionDate.isAfter(now.subtract(Duration(days: 1)));
      } else if (selectedFilter == '1 Week') {
        return transactionDate.isAfter(now.subtract(Duration(days: 7)));
      } else if (selectedFilter == '1 Month') {
        return transactionDate.isAfter(DateTime(now.year, now.month - 1, now.day));
      } else if (selectedFilter == '3 Months') {
        return transactionDate.isAfter(DateTime(now.year, now.month - 3, now.day));
      }
      return true;
    }).toList();

    return ListView.builder(
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        return _buildTransactionItem(context, filteredTransactions[index]);
      },
    );
  }

  Widget _buildTransactionItem(BuildContext context, Map<String, String> transaction) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TradingDetailsScreen(
              logo: transaction['logo']!,
              name: transaction['name']!,
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
              imageUrl: transaction['logo']!,
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
            transaction['name']!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
              fontSize: 16.sp,
            ),
          ),
          subtitle: Text(
            transaction['date']!,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.secondaryText,
            ),
          ),
          trailing: Text(
            transaction['amount']!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.error,
              fontSize: 16.sp,
            ),
          ),
        ),
      ),
    );
  }
}