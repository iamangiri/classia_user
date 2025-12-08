

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../service/apiservice/bajaj_api_service.dart';
import '../../themes/app_colors.dart';
import '../market/market_stock_chart_screen.dart';
import 'basket_api_service.dart';
import 'basket_model.dart';


class BasketInvestScreen extends StatefulWidget {
  final int basketId;

  const BasketInvestScreen({
    Key? key,
    required this.basketId,
  }) : super(key: key);

  @override
  State<BasketInvestScreen> createState() => _BasketInvestScreenState();
}

class _BasketInvestScreenState extends State<BasketInvestScreen> {
  final BasketApiService _basketApi = BasketApiService();

  Basket? _basket;
  Map<String, dynamic>? _fundsData;
  bool _isLoadingBasket = false;
  bool _isLoadingFunds = false;
  bool _isPlacingOrders = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadBasketDetails(),
      _loadFundsData(),
    ]);
  }

  Future<void> _loadBasketDetails() async {
    setState(() {
      _isLoadingBasket = true;
      _errorMessage = null;
    });

    try {
      final basket = await _basketApi.fetchBasketById(widget.basketId);
      setState(() {
        _basket = basket;
        _isLoadingBasket = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingBasket = false;
      });
      _showSnackBar('Error loading basket: $e', isError: true);
    }
  }

  Future<void> _loadFundsData() async {
    setState(() => _isLoadingFunds = true);
    try {
      final response = await BajajApiService.getFunds();

      if (response['statusCode'] == 0) {
        setState(() {
          _fundsData = response['data'];
          _isLoadingFunds = false;
        });
      } else {
        setState(() => _isLoadingFunds = false);
        _showSnackBar(
          response['message'] ?? 'Failed to load funds',
          isError: true,
        );
      }
    } catch (e) {
      setState(() => _isLoadingFunds = false);
      _showSnackBar('Error loading funds: $e', isError: true);
    }
  }

  // NEW: Show holding options bottom sheet
  void _showHoldingOptionsBottomSheet(Holding holding) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      isScrollControlled: true,
      builder: (context) => HoldingOptionsBottomSheet(
        holding: holding,
        onEdit: () {
          Navigator.pop(context);
          _showEditHoldingBottomSheet(holding);
        },
        onViewChart: () {
          Navigator.pop(context);
          _navigateToChartScreen(holding);
        },
      ),
    );
  }

  // NEW: Show edit holding bottom sheet
  void _showEditHoldingBottomSheet(Holding holding) {
    final orderTypeController = TextEditingController(text: holding.orderType);
    final unitsController = TextEditingController(text: holding.units);
    final targetPriceController = TextEditingController(text: holding.tgtPrice);
    final stopLossController = TextEditingController(text: holding.slPrice);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      isScrollControlled: true,
      builder: (context) => EditHoldingBottomSheet(
        holding: holding,
        orderTypeController: orderTypeController,
        unitsController: unitsController,
        targetPriceController: targetPriceController,
        stopLossController: stopLossController,
        onSave: (updatedHolding) {
          _updateHoldingInBasket(updatedHolding);
        },
      ),
    );
  }

  // NEW: Update holding in basket
  void _updateHoldingInBasket(Holding updatedHolding) {
    setState(() {
      if (_basket != null) {
        final index = _basket!.holdings.indexWhere(
              (h) => h.symbol == updatedHolding.symbol,
        );
        if (index != -1) {
          _basket!.holdings[index] = updatedHolding;
          _showSnackBar('Holding updated successfully', isError: false);
        }
      }
    });
  }

  // NEW: Navigate to chart screen
  void _navigateToChartScreen(Holding holding) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarketStockChartScreen(
          exchange: holding.exchId,
          symbol: holding.symbol,
          // You can add more parameters if needed
        ),
      ),
    );
  }

  // FIXED: Updated order placement logic with correct order types
  Future<void> _placeBasketOrders() async {
    if (_basket == null || _basket!.holdings.isEmpty) {
      _showSnackBar('No holdings to invest', isError: true);
      return;
    }

    final available = _fundsData?['available'] ?? 0.0;
    if (available <= 0) {
      _showSnackBar('Insufficient funds available', isError: true);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            Icon(Icons.shopping_cart_checkout, color: AppColors.primaryGold),
            SizedBox(width: 8.w),
            Text(
              'Confirm Investment',
              style: TextStyle(
                color: AppColors.headingText,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Place orders for all ${_basket!.holdings.length} stocks in this basket?',
          style: TextStyle(color: AppColors.primaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.onPrimaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: const Text('Invest Now'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isPlacingOrders = true);

    int successCount = 0;
    int failureCount = 0;
    List<String> errorMessages = [];

    for (var holding in _basket!.holdings) {
      try {
        // FIXED: Correct order type mapping
        String orderType;
        double limitPrice = 0;
        double slPrice = 0;

        final orderTypeUpper = holding.orderType.toUpperCase();

        if (orderTypeUpper == 'MARKET') {
          orderType = 'RL-M'; // Market order
        } else if (orderTypeUpper == 'LIMIT') {
          orderType = 'RL'; // Limit order (NOT RL-L!)
          limitPrice = double.tryParse(holding.tgtPrice) ?? 0;
        } else if (orderTypeUpper == 'SL' || orderTypeUpper == 'STOPLOSS') {
          orderType = 'SL'; // Stop loss
          slPrice = double.tryParse(holding.slPrice) ?? 0;
          limitPrice = double.tryParse(holding.tgtPrice) ?? 0;
        } else if (orderTypeUpper == 'SL-M') {
          orderType = 'SL-M'; // Stop loss market
          slPrice = double.tryParse(holding.slPrice) ?? 0;
        } else {
          // Default to market order if unknown type
          orderType = 'RL-M';
        }

        // FIXED: Product type mapping
        final product = _basket!.type.toUpperCase() == 'DELIVERY' ? 'D' : 'I';

        final response = await BajajApiService.placeOrder(
          orderType: 'place',
          qty: int.tryParse(holding.units) ?? 1,
          exchange: holding.exchId,
          buySell: 'BUY',
          orderTag: 'Classia Capital',
          orderTypeValue: orderType,
          product: product,
          validity: 'DAY',
          symbol: holding.symbol,
          slPrice: slPrice,
          limitPrice: limitPrice,
        );

        if (response['statusCode'] == 0) {
          successCount++;
        } else {
          failureCount++;
          errorMessages.add('${holding.symbol}: ${response['message']}');
        }
      } catch (e) {
        failureCount++;
        errorMessages.add('${holding.symbol}: $e');
      }
    }

    setState(() => _isPlacingOrders = false);
    _showResultDialog(successCount, failureCount, errorMessages);
  }

  void _showResultDialog(int successCount, int failureCount, List<String> errorMessages) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            Icon(
              successCount > 0 ? Icons.check_circle : Icons.error,
              color: successCount > 0 ? AppColors.success : AppColors.error,
            ),
            SizedBox(width: 8.w),
            Text(
              'Order Results',
              style: TextStyle(
                color: AppColors.headingText,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (successCount > 0)
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          '$successCount orders placed successfully',
                          style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              if (failureCount > 0) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error, color: AppColors.error),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              '$failureCount orders failed',
                              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      if (errorMessages.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        ...errorMessages.map((msg) => Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text('• $msg', style: TextStyle(color: AppColors.secondaryText, fontSize: 12.sp)),
                        )),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (successCount > 0) {
                Navigator.pop(context); // Go back after success
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.onPrimaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Invest in Basket',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
      ),
      body: _isLoadingBasket
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
          : _errorMessage != null
          ? _buildErrorState()
          : _basket == null
          ? _buildEmptyState()
          : Column(
        children: [
          _buildFundsCard(),
          _buildBasketInfoCard(),
          Expanded(
            child: _basket!.holdings.isEmpty
                ? _buildEmptyHoldingsState()
                : ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: _basket!.holdings.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => _showHoldingOptionsBottomSheet(_basket!.holdings[index]),
                child: _buildHoldingCard(_basket!.holdings[index]),
              ),
            ),
          ),
          _buildInvestButton(),
        ],
      ),
    );
  }

  Widget _buildErrorState() => Center(
    child: Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80.w, color: AppColors.error),
          SizedBox(height: 16.h),
          Text('Error Loading Basket', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.headingText)),
          SizedBox(height: 8.h),
          Text(_errorMessage ?? 'Unknown error', textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: AppColors.secondaryText)),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.onPrimaryColor,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildEmptyState() => Center(child: Text('Basket not found', style: TextStyle(fontSize: 16.sp, color: AppColors.secondaryText)));

  Widget _buildEmptyHoldingsState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inventory_2_outlined, size: 80.w, color: AppColors.disabled),
        SizedBox(height: 16.h),
        Text('No holdings in this basket', style: TextStyle(fontSize: 16.sp, color: AppColors.secondaryText)),
      ],
    ),
  );

  Widget _buildFundsCard() {
    if (_isLoadingFunds) {
      return _loadingCard();
    }
    if (_fundsData == null) return const SizedBox.shrink();

    final available = _fundsData!['available'] ?? 0.0;
    final marginUtilized = _fundsData!['marginUtilized'] ?? 0.0;

    return _gradientCard(
      child: Column(
        children: [
          Row(
            children: [
              _iconCircle(Icons.account_balance_wallet),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Available Funds', style: TextStyle(fontSize: 12.sp, color: AppColors.onPrimaryColor.withOpacity(0.7))),
                    Text('₹${available.toStringAsFixed(2)}', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppColors.onPrimaryColor)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(color: Colors.white24),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _fundDetailItem('Margin Used', '₹${marginUtilized.toStringAsFixed(2)}'),
              _fundDetailItem('Cash Available', '₹${(_fundsData!['cashAvailable'] ?? 0.0).toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _loadingCard() => Container(margin: EdgeInsets.all(16.w), padding: EdgeInsets.all(16.w), decoration: _cardDecoration(), child: const Center(child: CircularProgressIndicator(color: AppColors.primaryGold)));

  Widget _gradientCard({required Widget child}) => Container(
    margin: EdgeInsets.all(16.w),
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [AppColors.primaryColor, AppColors.primaryColor.withOpacity(0.8)]),
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [BoxShadow(color: AppColors.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
    ),
    child: child,
  );

  Widget _iconCircle(IconData icon) => Container(padding: EdgeInsets.all(10.w), decoration: const BoxDecoration(color: AppColors.primaryGold, shape: BoxShape.circle), child: Icon(icon, color: AppColors.onPrimaryColor, size: 24.sp));

  Widget _fundDetailItem(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(fontSize: 11.sp, color: AppColors.onPrimaryColor.withOpacity(0.7))),
    SizedBox(height: 4.h),
    Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.onPrimaryColor)),
  ]);

  Widget _buildBasketInfoCard() => Container(
    margin: EdgeInsets.symmetric(horizontal: 16.w),
    padding: EdgeInsets.all(16.w),
    decoration: _cardDecoration(borderColor: AppColors.border),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_basket!.basketName, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.headingText)),
        SizedBox(height: 12.h),
        Wrap(spacing: 8.w, runSpacing: 8.h, children: [
          _infoChip(Icons.trending_up, 'Return: ${_basket!.expectedReturn}%', AppColors.success),
          _infoChip(Icons.speed, _basket!.volatility, AppColors.warning),
          _infoChip(Icons.delivery_dining, _basket!.type, AppColors.primaryColor),
        ]),
        SizedBox(height: 12.h),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Total Holdings', style: TextStyle(fontSize: 13.sp, color: AppColors.secondaryText)),
          Text('${_basket!.holdings.length} stocks', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
        ]),
      ],
    ),
  );

  Widget _infoChip(IconData icon, String label, Color color) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r), border: Border.all(color: color.withOpacity(0.3))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14.sp, color: color),
      SizedBox(width: 4.w),
      Text(label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: color)),
    ]),
  );

  Widget _buildHoldingCard(Holding holding) => Container(
    margin: EdgeInsets.only(bottom: 12.h),
    padding: EdgeInsets.all(14.w),
    decoration: _cardDecoration(borderColor: AppColors.border),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(color: AppColors.primaryGold.withOpacity(0.15), borderRadius: BorderRadius.circular(10.r)),
              child: Icon(Icons.show_chart, color: AppColors.primaryGold, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(holding.fullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: AppColors.headingText), maxLines: 2, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      _tagChip(holding.symbol),
                      SizedBox(width: 6.w),
                      Text('${holding.holdinPercentage}%', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.primaryGold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: _holdingDetailItem('Units', holding.units, Icons.inventory_2_outlined)),
            SizedBox(width: 8.w),
            Expanded(child: _holdingDetailItem('Order Type', holding.orderType, Icons.assignment_outlined)),
          ],
        ),
        if (holding.tgtPrice != '0' || holding.slPrice != '0') ...[
          SizedBox(height: 8.h),
          Row(
            children: [
              if (holding.tgtPrice != '0')
                Expanded(child: _priceBox('Target', '₹${holding.tgtPrice}', Icons.trending_up, AppColors.success)),
              if (holding.slPrice != '0')
                Expanded(child: _priceBox('Stop Loss', '₹${holding.slPrice}', Icons.trending_down, AppColors.error)),
            ],
          ),
        ],
      ],
    ),
  );

  Widget _tagChip(String text) => Container(
    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
    decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4.r)),
    child: Text(text, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.primaryColor)),
  );

  Widget _holdingDetailItem(String label, String value, IconData icon) => Container(
    padding: EdgeInsets.all(10.w),
    decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(8.r), border: Border.all(color: AppColors.border)),
    child: Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.secondaryText),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10.sp, color: AppColors.secondaryText)),
            Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
          ],
        ),
      ],
    ),
  );

  Widget _priceBox(String label, String price, IconData icon, Color color) => Container(
    padding: EdgeInsets.all(10.w),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r), border: Border.all(color: color.withOpacity(0.3))),
    child: Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 4.w),
          Text(label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: color)),
        ]),
        SizedBox(height: 4.h),
        Text(price, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: color)),
      ],
    ),
  );

  BoxDecoration _cardDecoration({Color? borderColor}) => BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(16.r),
    border: borderColor != null ? Border.all(color: borderColor, width: 1) : null,
  );

  Widget _buildInvestButton() => Container(
    padding: EdgeInsets.all(16.w),
    color: AppColors.cardBackground,
    child: SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isPlacingOrders ? null : _placeBasketOrders,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGold,
            foregroundColor: AppColors.onPrimaryColor,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            elevation: 4,
          ),
          child: _isPlacingOrders
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text('Invest Now', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        ),
      ),
    ),
  );
}

// NEW: Holding Options Bottom Sheet Widget
class HoldingOptionsBottomSheet extends StatelessWidget {
  final Holding holding;
  final VoidCallback onEdit;
  final VoidCallback onViewChart;

  const HoldingOptionsBottomSheet({
    Key? key,
    required this.holding,
    required this.onEdit,
    required this.onViewChart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.star, color: AppColors.primaryGold, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      holding.fullName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.headingText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      holding.symbol,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: AppColors.secondaryText, size: 24.sp),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Options
          _buildOptionTile(
            icon: Icons.edit,
            title: 'Edit Holding',
            subtitle: 'Change order type, units, target, stop loss',
            onTap: onEdit,
          ),
          SizedBox(height: 16.h),
          _buildOptionTile(
            icon: Icons.show_chart,
            title: 'View Chart',
            subtitle: 'Analyze stock performance',
            onTap: onViewChart,
          ),
          SizedBox(height: 24.h),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(color: AppColors.border),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: AppColors.primaryGold, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.headingText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.secondaryText, size: 24.sp),
          ],
        ),
      ),
    );
  }
}

// NEW: Edit Holding Bottom Sheet Widget
class EditHoldingBottomSheet extends StatefulWidget {
  final Holding holding;
  final TextEditingController orderTypeController;
  final TextEditingController unitsController;
  final TextEditingController targetPriceController;
  final TextEditingController stopLossController;
  final Function(Holding) onSave;

  const EditHoldingBottomSheet({
    Key? key,
    required this.holding,
    required this.orderTypeController,
    required this.unitsController,
    required this.targetPriceController,
    required this.stopLossController,
    required this.onSave,
  }) : super(key: key);

  @override
  _EditHoldingBottomSheetState createState() => _EditHoldingBottomSheetState();
}

class _EditHoldingBottomSheetState extends State<EditHoldingBottomSheet> {
  final List<String> _orderTypes = ['MARKET', 'LIMIT', 'SL', 'SL-M'];
  String _selectedOrderType = 'MARKET';

  @override
  void initState() {
    super.initState();
    _selectedOrderType = widget.holding.orderType.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.edit, color: AppColors.primaryGold, size: 28.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Edit Holding',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.headingText,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: AppColors.secondaryText, size: 24.sp),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Stock Info
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.holding.fullName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.headingText,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        widget.holding.symbol,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${widget.holding.holdinPercentage}%',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Form
          Text(
            'Order Details',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.headingText,
            ),
          ),
          SizedBox(height: 16.h),

          // Order Type Dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Type',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedOrderType,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: AppColors.secondaryText),
                    dropdownColor: AppColors.cardBackground,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.primaryText,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedOrderType = newValue!;
                        widget.orderTypeController.text = newValue;
                      });
                    },
                    items: _orderTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Units Input
          _buildTextField(
            controller: widget.unitsController,
            label: 'Units',
            hintText: 'Enter number of units',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16.h),

          // Target Price Input (visible for LIMIT and SL)
          if (_selectedOrderType == 'LIMIT' || _selectedOrderType == 'SL')
            Column(
              children: [
                _buildTextField(
                  controller: widget.targetPriceController,
                  label: 'Target Price (₹)',
                  hintText: 'Enter target price',
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16.h),
              ],
            ),

          // Stop Loss Input (visible for SL and SL-M)
          if (_selectedOrderType == 'SL' || _selectedOrderType == 'SL-M')
            Column(
              children: [
                _buildTextField(
                  controller: widget.stopLossController,
                  label: 'Stop Loss (₹)',
                  hintText: 'Enter stop loss price',
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16.h),
              ],
            ),

          // Save Button
          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final updatedHolding = Holding(
                  id: widget.holding.id,
                  isin: widget.holding.isin,
                  token: widget.holding.token,
                  units: widget.unitsController.text,
                  exchId: widget.holding.exchId,
                  symbol: widget.holding.symbol,
                  slPrice: widget.stopLossController.text,
                  tgtPrice: widget.targetPriceController.text,
                  stockId: widget.holding.stockId,
                  fullName: widget.holding.fullName,
                  holdinPercentage: widget.holding.holdinPercentage,
                  orderType: _selectedOrderType,
                );
                widget.onSave(updatedHolding);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: AppColors.onPrimaryColor,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required TextInputType keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.primaryText,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: AppColors.secondaryText),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primaryGold),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
          ),
        ),
      ],
    );
  }
}