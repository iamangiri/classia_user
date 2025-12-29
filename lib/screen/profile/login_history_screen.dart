import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../service/apiservice/user_service.dart';
import '../../utills/themes/light_app_theme.dart';
import '../../widget/common_app_bar.dart';

class LoginHistoryScreen extends StatefulWidget {
  const LoginHistoryScreen({Key? key}) : super(key: key);

  @override
  State<LoginHistoryScreen> createState() => _LoginHistoryScreenState();
}

class _LoginHistoryScreenState extends State<LoginHistoryScreen> {
  List<LoginHistory> loginHistory = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  int currentPage = 1;
  int totalPages = 1;
  int totalItems = 0;
  final int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadLoginHistory();
  }

  Future<void> _loadLoginHistory() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    final response = await UserService.getLoginHistory(
      page: currentPage,
      limit: itemsPerPage,
    );

    setState(() {
      isLoading = false;
      if (response['success'] == true) {
        loginHistory = response['history'] as List<LoginHistory>;
        final pagination = response['pagination'];
        totalItems = pagination['total'];
        totalPages = (totalItems / itemsPerPage).ceil();
      } else {
        hasError = true;
        errorMessage = response['message'];
      }
    });
  }

  void _nextPage() {
    if (currentPage < totalPages) {
      setState(() {
        currentPage++;
      });
      _loadLoginHistory();
    }
  }

  void _previousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
      _loadLoginHistory();
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
    }
  }

  IconData _getDeviceIcon(String device) {
    if (device.toLowerCase().contains('postman')) {
      return FontAwesomeIcons.code;
    } else if (device.toLowerCase().contains('dart')) {
      return FontAwesomeIcons.mobileScreen;
    } else if (device.toLowerCase().contains('chrome')) {
      return FontAwesomeIcons.chrome;
    } else if (device.toLowerCase().contains('firefox')) {
      return FontAwesomeIcons.firefox;
    } else if (device.toLowerCase().contains('safari')) {
      return FontAwesomeIcons.safari;
    } else {
      return FontAwesomeIcons.desktop;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  CommonAppBar(title: 'Login History'),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: AppTheme.lightTheme.primaryColor,
        ),
      )
          : hasError
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red),
            SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.primaryColor,
              ),
              onPressed: _loadLoginHistory,
              child: Text(
                "Retry",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Header Info
          Container(
            padding: EdgeInsets.all(16),
            color: AppTheme.lightTheme.primaryColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.shieldHalved,
                      color: AppTheme.lightTheme.primaryColor,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Total Logins: $totalItems",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  "Page $currentPage of $totalPages",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // History List
          Expanded(
            child: loginHistory.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.clockRotateLeft,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No login history found",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: loginHistory.length,
              itemBuilder: (context, index) {
                final item = loginHistory[index];
                return _buildHistoryCard(item);
              },
            ),
          ),

          // Pagination
          if (totalPages > 1)
            Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentPage == 1
                          ? Colors.grey[300]
                          : AppTheme.lightTheme.primaryColor,
                      foregroundColor: currentPage == 1
                          ? Colors.grey[600]
                          : Colors.white,
                    ),
                    onPressed: currentPage == 1 ? null : _previousPage,
                    icon: Icon(Icons.arrow_back, size: 18),
                    label: Text("Previous"),
                  ),
                  Text(
                    "$currentPage / $totalPages",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentPage == totalPages
                          ? Colors.grey[300]
                          : AppTheme.lightTheme.primaryColor,
                      foregroundColor: currentPage == totalPages
                          ? Colors.grey[600]
                          : Colors.white,
                    ),
                    onPressed:
                    currentPage == totalPages ? null : _nextPage,
                    icon: Icon(Icons.arrow_forward, size: 18),
                    label: Text("Next"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(LoginHistory item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FaIcon(
                _getDeviceIcon(item.device),
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.device,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.locationDot,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 5),
                      Text(
                        item.ipAddress,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.clock,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 5),
                      Text(
                        _formatDateTime(item.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}