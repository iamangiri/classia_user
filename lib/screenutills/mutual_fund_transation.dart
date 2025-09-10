import 'package:flutter/material.dart';
import 'dart:ui';
import '../../themes/app_colors.dart';
import '../../widget/custom_app_bar.dart';
import '../../service/apiservice/mutual_fund_service.dart';

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Transactions',
      ),
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
                    return _buildEmptyState(message: 'No transactions found. Please try again later.');
                  }

                  final apiData = snapshot.data!;
                  final String mfuGorn = apiData['data']?['mfuGorn'] ?? 'N/A';
                  final List<dynamic>? orderHistList = apiData['data']?['orderHistList'];

                  if (orderHistList == null || orderHistList.isEmpty) {
                    return _buildEmptyState(message: 'No transaction history available.');
                  }

                  print('Processing ${orderHistList.length} transactions from API');

                  return _buildTransactionList(mfuGorn, orderHistList);
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

  Widget _buildTransactionList(String mfuGorn, List<dynamic> transactions) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground?.withOpacity(0.8) ?? Colors.grey[100]!.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryGold?.withOpacity(0.3) ?? Color(0xFFDAA520).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MFU GORN',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText ?? Colors.black87,
                  ),
                ),
                Text(
                  mfuGorn,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGold ?? Color(0xFFDAA520),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
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
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final String event = transaction['event']?.toString() ?? 'N/A';
    final String eventTs = transaction['eventTs']?.toString() ?? 'N/A';
    final String eventEntityName = transaction['eventEntityName']?.toString() ?? 'N/A';
    final String orderNo = transaction['orderNo']?.toString() ?? 'N/A';
    final String rtaRemarks = transaction['rtaRemarks']?.toString() ?? 'None';

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
                    Text(
                      'Order #$orderNo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText ?? Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      event,
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
                    'Entity',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.secondaryText ?? Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    eventEntityName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
                    eventTs,
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
          if (rtaRemarks.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Remarks',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.secondaryText ?? Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  rtaRemarks,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryText ?? Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
        ],
      ),
    );
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