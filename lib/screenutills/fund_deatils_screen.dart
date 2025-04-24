import 'package:cached_network_image/cached_network_image.dart';
import 'package:classia_amc/screen/homefetures/investment_history_screen.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FundDetailsScreen extends StatelessWidget {
  final Map<String, String> fund;

  const FundDetailsScreen({Key? key, required this.fund}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CustomAppBar(
        title: fund['name']!,

      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fund Overview Card
            _buildFundOverviewCard(context),
            SizedBox(height: 20.h),
            // Key Metrics Grid
            _buildKeyMetricsGrid(),
            SizedBox(height: 20.h),
            // Performance Card
            _buildPerformanceCard(),
            SizedBox(height: 20.h),
            // Details Card
            _buildDetailsCard(),
            SizedBox(height: 20.h),
            // Invest Button
            _buildInvestButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFundOverviewCard(BuildContext context) {
    final isPositive = fund['change']!.startsWith('+');
    return Container(
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
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: fund['logo']!,
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
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fund['symbol']!,
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      fund['company']!,
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Price',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14.sp,
                    ),
                  ),
                  Text(
                    '₹${fund['price']}',
                    style: TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Change',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14.sp,
                    ),
                  ),
                  Text(
                    fund['change']!,
                    style: TextStyle(
                      color: isPositive ? AppColors.success : AppColors.error,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: 1.6,
      children: [
        _buildMetricCard('NAV', '₹${fund['nav'] ?? 'N/A'}'),
        _buildMetricCard('Risk Level', fund['riskLevel'] ?? 'N/A'),
        _buildMetricCard('Category', fund['category'] ?? 'N/A'),
        _buildMetricCard('Min. Investment', '₹${fund['minInvestment'] ?? 'N/A'}'),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value) {
    return Container(
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
      padding: EdgeInsets.all(12.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard() {
    return Container(
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
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1-Year Return',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14.sp,
                    ),
                  ),
                  Text(
                    fund['returns1Y'] ?? 'N/A',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '3-Year Return',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14.sp,
                    ),
                  ),
                  Text(
                    fund['returns3Y'] ?? 'N/A',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            height: 100.h,
            color: AppColors.border,
            child: Center(
              child: Text(
                'Performance Chart Placeholder',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
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
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fund Details',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          _buildDetailRow('Fund Manager', fund['fundManager'] ?? 'N/A'),
          _buildDetailRow('Inception Date', fund['inceptionDate'] ?? 'N/A'),
          SizedBox(height: 12.h),
          Text(
            'Description',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14.sp,
            ),
          ),
          Text(
            fund['description'] ?? 'No description available.',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14.sp,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InvestmentHistoryScreen(),
            ),
          );
        },
        child: Text(
          'Invest Now',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.buttonText,
          ),
        ),
      ),
    );
  }
}