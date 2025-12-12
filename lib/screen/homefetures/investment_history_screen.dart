import 'package:cached_network_image/cached_network_image.dart';
import 'package:classia_amc/service/apiservice/wallet_service.dart';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:classia_amc/service/apiservice/mutual_fund_service.dart';

class InvestmentHistoryScreen extends StatefulWidget {
  const InvestmentHistoryScreen({Key? key}) : super(key: key);

  @override
  _InvestmentHistoryScreenState createState() =>
      _InvestmentHistoryScreenState();
}

class _InvestmentHistoryScreenState extends State<InvestmentHistoryScreen>
    with SingleTickerProviderStateMixin {
  String selectedFilter = "All";
  final List<String> filters = [
    "All",
    "Subscription",
    "Purchase",
    "Redemption",
    "SIP",
    "Switch"
  ];
  List<Map<String, dynamic>> transactions = [];
  bool _isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fetchTransactions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchTransactions() async {
    setState(() => _isLoading = true);
    try {
      final response = await MutualFundService.getTransactionList();

      if (response['status'] == true) {
        final List<dynamic>? transactionList = response['data']?['transactionList'];

        if (transactionList != null) {
          setState(() {
            transactions = transactionList
                .map((e) => e as Map<String, dynamic>)
                .toList();
          });
          _animationController.forward();
        }
      }
    } catch (e) {
      print('Error fetching transactions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load transactions: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CommonAppBar(
        title: 'Investment History',
      ),
      body: _isLoading
          ? _buildLoadingState()
          : RefreshIndicator(
        onRefresh: _fetchTransactions,
        color: const Color(0xFFFFD700),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInvestmentSummarySection(),
              SizedBox(height: 24.h),
              _buildHeaderRow(),
              SizedBox(height: 16.h),
              Expanded(child: _buildInvestmentList(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Transaction History',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0A1F3A),
          ),
        ),
        GestureDetector(
          onTap: () => _showFilterOptions(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFD700).withOpacity(0.1),
                  const Color(0xFFFFD700).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  size: 18.sp,
                  color: const Color(0xFFFFD700),
                ),
                SizedBox(width: 6.w),
                Text(
                  selectedFilter,
                  style: TextStyle(
                    color: const Color(0xFF0A1F3A),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Transactions',
                    style: TextStyle(
                      color: const Color(0xFF0A1F3A),
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF0A1F3A)),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: filters.map((filter) {
                  final isSelected = selectedFilter == filter;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedFilter = filter;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
                        )
                            : null,
                        color: isSelected ? null : const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF0A1F3A),
                          fontSize: 14.sp,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInvestmentSummarySection() {
    final totalInvested = transactions.fold<double>(
      0,
          (sum, txn) {
        final amount = txn['totalAmount'] ?? txn['amount'];
        if (amount == null) return sum;
        return sum + double.tryParse(amount.toString())!;
      },
    );

    final totalTransactions = transactions.length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1F3A), Color(0xFF1A3A5A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A1F3A).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Invested',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '₹${totalInvested.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    Text(
                      totalTransactions.toString(),
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                    Text(
                      'Transactions',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentList(BuildContext context) {
    List<Map<String, dynamic>> filteredTransactions =
    transactions.where((transaction) {
      if (selectedFilter == 'All') return true;

      final String transactionType = transaction['transactionType']?.toString() ?? '';
      return transactionType.toUpperCase() == selectedFilter.toUpperCase();
    }).toList();

    if (filteredTransactions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        return FadeTransition(
          opacity: _animationController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                index * 0.1,
                1.0,
                curve: Curves.easeOut,
              ),
            )),
            child: Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: _buildTransactionItem(context, filteredTransactions[index]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionItem(
      BuildContext context, Map<String, dynamic> transaction) {
    final String transactionType = transaction['transactionType']?.toString() ?? 'UNKNOWN';
    final amount = transaction['totalAmount'] ?? transaction['amount'] ?? '0';
    final String createdAt = transaction['createdAt']?.toString() ?? '';
    final transactionData = transaction['transactionData'];

    // Get basket info if available
    String basketInfo = 'Transaction #${transaction['id']}';
    if (transactionData != null && transactionData is Map) {
      final basketId = transactionData['basketId'];
      if (basketId != null) {
        basketInfo = 'Basket #$basketId';
      }
    }

    // Type-specific styling
    final typeConfig = _getTypeConfig(transactionType);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showTransactionDetails(context, transaction);
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    gradient: typeConfig['gradient'] as LinearGradient,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    typeConfig['icon'] as IconData,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        basketInfo,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0A1F3A),
                          fontSize: 15.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: (typeConfig['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              transactionType,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: typeConfig['color'] as Color,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            _formatDate(createdAt),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${double.tryParse(amount.toString())?.toStringAsFixed(2) ?? '0.00'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0A1F3A),
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14.sp,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getTypeConfig(String type) {
    switch (type.toUpperCase()) {
      case 'SUBSCRIPTION':
        return {
          'icon': Icons.repeat_rounded,
          'color': const Color(0xFF9C27B0),
          'gradient': const LinearGradient(
            colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
          ),
        };
      case 'PURCHASE':
        return {
          'icon': Icons.shopping_cart_rounded,
          'color': const Color(0xFF4CAF50),
          'gradient': const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
          ),
        };
      case 'REDEMPTION':
        return {
          'icon': Icons.account_balance_wallet_rounded,
          'color': const Color(0xFFE53935),
          'gradient': const LinearGradient(
            colors: [Color(0xFFE53935), Color(0xFFC62828)],
          ),
        };
      case 'SIP':
        return {
          'icon': Icons.timeline_rounded,
          'color': const Color(0xFF2196F3),
          'gradient': const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          ),
        };
      case 'SWITCH':
        return {
          'icon': Icons.swap_horiz_rounded,
          'color': const Color(0xFFFF9800),
          'gradient': const LinearGradient(
            colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
          ),
        };
      default:
        return {
          'icon': Icons.receipt_long_rounded,
          'color': const Color(0xFF607D8B),
          'gradient': const LinearGradient(
            colors: [Color(0xFF607D8B), Color(0xFF455A64)],
          ),
        };
    }
  }

  void _showTransactionDetails(BuildContext context, Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        final transactionType = transaction['transactionType']?.toString() ?? 'UNKNOWN';
        final typeConfig = _getTypeConfig(transactionType);
        final transactionData = transaction['transactionData'];

        return Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      gradient: typeConfig['gradient'] as LinearGradient,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      typeConfig['icon'] as IconData,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaction Details',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0A1F3A),
                          ),
                        ),
                        Text(
                          transactionType,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: typeConfig['color'] as Color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF0A1F3A)),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              _buildDetailRow('Transaction ID', transaction['id']?.toString() ?? 'N/A'),
              _buildDetailRow('Amount', '₹${transaction['totalAmount'] ?? transaction['amount'] ?? '0'}'),
              _buildDetailRow('Date', _formatDate(transaction['createdAt']?.toString() ?? '')),
              if (transaction['mfuGorn'] != null)
                _buildDetailRow('MFU GORN', transaction['mfuGorn']?.toString() ?? 'N/A'),
              if (transaction['uniqueRefNo'] != null)
                _buildDetailRow('Reference No', transaction['uniqueRefNo']?.toString() ?? 'N/A'),
              if (transactionData != null && transactionData is Map) ...[
                const Divider(height: 32),
                Text(
                  'Additional Details',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0A1F3A),
                  ),
                ),
                SizedBox(height: 12.h),
                if (transactionData['basketId'] != null)
                  _buildDetailRow('Basket ID', transactionData['basketId']?.toString() ?? 'N/A'),
                if (transactionData['status'] != null)
                  _buildDetailRow('Status', transactionData['status']?.toString() ?? 'N/A'),
                if (transactionData['startDate'] != null)
                  _buildDetailRow('Start Date', _formatDate(transactionData['startDate']?.toString() ?? '')),
                if (transactionData['endDate'] != null)
                  _buildDetailRow('End Date', _formatDate(transactionData['endDate']?.toString() ?? '')),
              ],
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0A1F3A),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading transactions...',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0A1F3A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFD700).withOpacity(0.1),
                  const Color(0xFFFFD700).withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 80.sp,
              color: const Color(0xFFFFD700),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No Transactions Found',
            style: TextStyle(
              color: const Color(0xFF0A1F3A),
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your transaction history will appear here',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}