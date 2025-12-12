import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
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
      final fundName = await MutualFundService.getFundName(
          rtaAmcCode, rtaSchCode);
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

  // Check if transaction is a mutual fund transaction
  bool _isMutualFundTransaction(Map<String, dynamic> transaction) {
    // Check if transaction has mutual fund specific fields
    final String? mfuGorn = transaction['mfuGorn']?.toString();
    final String? uniqueRefNo = transaction['uniqueRefNo']?.toString();
    final String? orderStatus = transaction['orderStatus']?.toString();
    final transactionData = transaction['transactionData'];

    // Check if transactionData has schList or sysSchList (mutual fund schemes)
    if (transactionData != null && transactionData is Map<String, dynamic>) {
      final schList = transactionData['schList'] ??
          transactionData['sysSchList'];
      if (schList != null && schList is List && schList.isNotEmpty) {
        return true;
      }
    }

    // Check if it has mutual fund specific fields
    if (mfuGorn != null && mfuGorn != 'null' && mfuGorn.isNotEmpty) {
      return true;
    }

    if (uniqueRefNo != null && uniqueRefNo != 'null' &&
        uniqueRefNo.isNotEmpty) {
      return true;
    }

    if (orderStatus != null && orderStatus != 'null' &&
        orderStatus.isNotEmpty) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Mutual Fund Transactions'),
      backgroundColor: const Color(0xFFF8F9FA),
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
                  } else if (snapshot.hasError || !snapshot.hasData ||
                      !snapshot.data!['status']) {
                    print('Error or invalid data: ${snapshot.error ??
                        'No data or status false'}');
                    return _buildEmptyState(
                        message: 'Failed to load transactions. Please try again.');
                  }

                  final apiData = snapshot.data!;
                  final List<
                      dynamic>? allTransactions = apiData['data']?['transactionList'];

                  if (allTransactions == null || allTransactions.isEmpty) {
                    return _buildEmptyState(message: 'No transactions found.');
                  }

                  // Filter only mutual fund transactions
                  final List<dynamic> mutualFundTransactions = allTransactions
                      .where((transaction) =>
                      _isMutualFundTransaction(transaction as Map<
                          String,
                          dynamic>))
                      .toList();

                  print('Total transactions: ${allTransactions.length}');
                  print('Mutual fund transactions: ${mutualFundTransactions
                      .length}');

                  if (mutualFundTransactions.isEmpty) {
                    return _buildEmptyState(
                        message: 'No mutual fund transactions found.');
                  }

                  return _buildTransactionList(mutualFundTransactions);
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1F3A), Color(0xFF1A3A5A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A1F3A).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: Color(0xFFFFD700),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transaction History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'View your mutual fund transactions',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
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
        padding: const EdgeInsets.symmetric(vertical: 8),
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
    final String transactionType = transaction['transactionType']?.toString() ??
        'N/A';
    final String createdAt = transaction['createdAt']?.toString() ?? 'N/A';
    final String mfuGorn = transaction['mfuGorn']?.toString() ?? 'N/A';
    final String approvalLink = transaction['approvalLink']?.toString() ?? '';

    final transactionData = transaction['transactionData'] ?? {};
    final List<dynamic> schList = (transactionData['schList'] ??
        transactionData['sysSchList'] ?? []) as List<dynamic>;

    // Map orderStatus to user-friendly text and color
    final Map<String, Map<String, dynamic>> statusConfig = {
      'RQ': {'text': 'Pending', 'color': Color(0xFFFF9800)},
      'CO': {'text': 'Confirmed', 'color': Color(0xFF4CAF50)},
      'FA': {'text': 'Failed', 'color': Color(0xFFE53935)},
      'SU': {'text': 'Successful', 'color': Color(0xFF4CAF50)},
    };

    final statusInfo = statusConfig[orderStatus] ??
        {'text': 'Unknown', 'color': Color(0xFF9E9E9E)};
    final String statusText = statusInfo['text'] as String;
    final Color statusColor = statusInfo['color'] as Color;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0A1F3A).withOpacity(0.05),
                  const Color(0xFF0A1F3A).withOpacity(0.02),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display all fund names
                      FutureBuilder<List<String>>(
                        future: _getAllFundNames(schList),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text(
                              'Loading funds...',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0A1F3A),
                              ),
                            );
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text(
                              'Fund Information',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A1F3A),
                              ),
                            );
                          }

                          final fundNames = snapshot.data!;

                          // If single fund, show normally
                          if (fundNames.length == 1) {
                            return Text(
                              fundNames[0],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A1F3A),
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
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0A1F3A),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFFD700), Color(
                                            0xFFDAA520)
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '+${fundNames.length - 1} more',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (fundNames.length > 1) ...[
                                const SizedBox(height: 6),
                                ...fundNames.skip(1).take(2).map((name) =>
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        '• $name',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )).toList(),
                                if (fundNames.length > 3)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      '• +${fundNames.length -
                                          3} more funds...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Amount and Date Row
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'Amount',
                        '₹$totalAmount',
                        Icons.currency_rupee,
                        const Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailItem(
                        'Date',
                        _formatDate(createdAt),
                        Icons.calendar_today,
                        const Color(0xFF2196F3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Transaction Type
                _buildInfoRow('Type', transactionType, Icons.swap_horiz),
                const SizedBox(height: 8),

                // Reference Number
                if (uniqueRefNo != 'N/A')
                  _buildInfoRow('Ref No', uniqueRefNo, Icons.tag),
                if (uniqueRefNo != 'N/A')
                  const SizedBox(height: 8),

                // MFU GORN
                if (mfuGorn != 'N/A')
                  _buildInfoRow('MFU GORN', mfuGorn, Icons.qr_code),
                if (mfuGorn != 'N/A')
                  const SizedBox(height: 16),

                // Approve Button
                if (approvalLink.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchURL(approvalLink),
                      icon: const Icon(Icons.check_circle_outline, size: 20),
                      label: const Text(
                        'Approve Transaction',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: const Color(0xFF0A1F3A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon,
      Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A1F3A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0A1F3A).withOpacity(0.6)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF0A1F3A),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading transactions...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0A1F3A),
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFD700).withOpacity(0.1),
                    const Color(0xFFFFD700).withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_toggle_off_rounded,
                size: 64,
                color: Color(0xFFFFD700),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Transactions Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A1F3A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? 'No mutual fund transaction history available.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFFD700),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}