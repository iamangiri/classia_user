import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../service/apiservice/support_service.dart';
import '../themes/app_colors.dart';
import '../widget/common_app_bar.dart';
import '../widget/custom_app_bar.dart';

class SupportTicketListScreen extends StatefulWidget {
  @override
  _SupportTicketListScreenState createState() => _SupportTicketListScreenState();
}

class _SupportTicketListScreenState extends State<SupportTicketListScreen> {
  List<dynamic> _tickets = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await SupportService().getSupportTicketList(page: 1, limit: 10);

    setState(() {
      _isLoading = false;
      if (result != null && result['data'] != null && result['data']['tickets'] != null) {
        _tickets = result['data']['tickets'];
      } else {
        _errorMessage = 'Failed to load tickets';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: 'Support Tickets',
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
            : _errorMessage.isNotEmpty
            ? Center(
          child: Text(
            _errorMessage,
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 16.sp,
            ),
          ),
        )
            : _tickets.isEmpty
            ? Center(
          child: Text(
            'No tickets found',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 16.sp,
            ),
          ),
        )
            : ListView.separated(
          itemCount: _tickets.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final ticket = _tickets[index];
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
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                title: Text(
                  ticket['title'] ?? 'No Title',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                subtitle: Text(
                  ticket['description'] ?? 'No Description',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 14.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  ticket['status'] ?? 'Unknown',
                  style: TextStyle(
                    color: ticket['status'] == 'OPEN'
                        ? Colors.green
                        : ticket['status'] == 'CLOSED'
                        ? Colors.red
                        : AppColors.secondaryText,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}