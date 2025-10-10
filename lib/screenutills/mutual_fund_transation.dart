import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import '../../themes/app_colors.dart';
import '../../service/apiservice/mutual_fund_service.dart';

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Map<String, String> _fundNameCache = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Launch URL in browser
  Future<void> _launchURL(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No approval link available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open link: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Get fund name with caching
  Future<String> _getFundName(String rtaAmcCode, String rtaSchCode) async {
    final cacheKey = '${rtaAmcCode}_${rtaSchCode}';

    if (_fundNameCache.containsKey(cacheKey)) {
      return _fundNameCache[cacheKey]!;
    }

    try {
      final fundName = await MutualFundService.getFundName(rtaAmcCode, rtaSchCode);
      _fundNameCache[cacheKey] = fundName;
      return fundName;
    } catch (e) {
      print('Error fetching fund name: $e');
      return 'Fund Information';
    }
  }

  // Get all fund names for a transaction
  Future<List<String>> _getAllFundNames(List<dynamic> schList) async {
    List<String> fundNames = [];

    for (var scheme in schList) {
      final String rtaAmcCode = scheme['rtaAmcCode']?.toString() ?? 'N/A';
      final String rtaSchCode = scheme['rtaSchCode']?.toString() ?? 'N/A';

      if (rtaAmcCode != 'N/A' && rtaSchCode != 'N/A') {
        final fundName = await _getFundName(rtaAmcCode, rtaSchCode);
        fundNames.add(fundName);
      }
    }

    return fundNames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Transactions'),
      backgroundColor: AppColors.screenBackground ?? Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildTransactionHeader(),
            ),
            SliverToBoxAdapter(
              child: FutureBuilder<Map<String, dynamic>>(
                future: MutualFundService.getTransactionList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  } else if (snapshot.hasError || !snapshot.hasData || !snapshot.data!['status']) {
                    print('Error or invalid data: ${snapshot.error ?? 'No data or status false'}');
                    return _buildEmptyState(message: 'Failed to load transactions. Please try again.');
                  }

                  final apiData = snapshot.data!;
                  final List<dynamic>? transactions = apiData['data']?['transactionList'];

                  if (transactions == null || transactions.isEmpty) {
                    return _buildEmptyState(message: 'No transactions found.');
                  }

                  print('Processing ${transactions.length} transactions from API');

                  return _buildTransactionList(transactions);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGold ?? const Color(0xFFDAA520),
                  (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.history,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transaction History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText ?? Colors.black87,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  'View your recent transactions',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText ?? Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<dynamic> transactions) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index] as Map<String, dynamic>;
          return TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 600 + (index * 100)),
            builder: (context, double animValue, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - animValue)),
                child: Opacity(
                  opacity: animValue,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildTransactionCard(transaction),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final String uniqueRefNo = transaction['uniqueRefNo']?.toString() ?? 'N/A';
    final String orderStatus = transaction['orderStatus']?.toString() ?? 'N/A';
    final String totalAmount = transaction['totalAmount']?.toString() ?? '0.00';
    final String transactionType = transaction['transactionType']?.toString() ?? 'N/A';
    final String createdAt = transaction['createdAt']?.toString() ?? 'N/A';
    final String mfuGorn = transaction['mfuGorn']?.toString() ?? 'N/A';
    final String approvalLink = transaction['approvalLink']?.toString() ?? '';

    final transactionData = transaction['transactionData'] ?? {};
    final List<dynamic> schList = (transactionData['schList'] ?? transactionData['sysSchList'] ?? []) as List<dynamic>;

    // Map orderStatus to user-friendly text
    final String statusText = {
      'RQ': 'Pending',
      'CO': 'Confirmed',
      'FA': 'Failed',
      'SU': 'Successful',
    }[orderStatus] ?? 'Unknown';

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGold ?? Color(0xFFDAA520),
                      (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display all fund names
                    FutureBuilder<List<String>>(
                      future: _getAllFundNames(schList),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text(
                            'Loading funds...',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText ?? Colors.black87,
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Text(
                            'Fund Information',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText ?? Colors.black87,
                            ),
                          );
                        }

                        final fundNames = snapshot.data!;

                        // If single fund, show normally
                        if (fundNames.length == 1) {
                          return Text(
                            fundNames[0],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText ?? Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          );
                        }

                        // If multiple funds, show with count badge
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    fundNames[0],
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryText ?? Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGold ?? Color(0xFFDAA520),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '+${fundNames.length - 1}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (fundNames.length > 1) ...[
                              SizedBox(height: 4),
                              ...fundNames.skip(1).map((name) => Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  '• $name',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.secondaryText ?? Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )).toList(),
                            ],
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$transactionType • $statusText',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText ?? Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.secondaryText ?? Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '₹$totalAmount',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText ?? Colors.black87,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Date',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.secondaryText ?? Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatDate(createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText ?? Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reference No',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.secondaryText ?? Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                uniqueRefNo,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.primaryText ?? Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MFU GORN',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.secondaryText ?? Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                mfuGorn,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.primaryText ?? Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(height: 12),
          // Approve Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchURL(approvalLink),
              icon: Icon(Icons.check_circle_outline, size: 18),
              label: Text(
                'Approve Transaction',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold ?? Color(0xFFDAA520),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Format ISO date to readable format (e.g., "11 Sep 2025")
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
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryGold ?? Color(0xFFDAA520),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Loading transactions...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryText ?? Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({String? message}) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.1),
                    (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.history_toggle_off_rounded,
                size: 64,
                color: AppColors.primaryGold ?? const Color(0xFFDAA520),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No Transactions Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText ?? Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  message ?? 'No transaction history available at the moment.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.secondaryText ?? Colors.grey,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 24),
            TextButton(
              onPressed: () => setState(() {}),
              child: Text(
                'Retry Loading',
                style: TextStyle(
                  color: AppColors.primaryGold ?? const Color(0xFFDAA520),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}