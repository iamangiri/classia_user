import 'package:flutter/material.dart';
import 'package:classia_amc/themes/app_colors.dart';

class MarketClosedOverlay extends StatelessWidget {
  final VoidCallback? onExploreFunds;

  const MarketClosedOverlay({Key? key, this.onExploreFunds}) : super(key: key);

  String _getNextOpeningTime() {
    final now = DateTime.now();
    final weekday = now.weekday;

    if (weekday == 6 || weekday == 7) {
      return "Monday at 9:15 AM";
    } else {
      final marketClose = DateTime(now.year, now.month, now.day, 15, 30);
      return now.isAfter(marketClose) ? "Tomorrow at 9:15 AM" : "Today at 9:15 AM";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundColor,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.access_time_outlined,
            size: 80,
            color: AppColors.primaryGold,
          ),
          const SizedBox(height: 24),
          Text(
            'Market is Closed',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'You can invest in mutual funds\nvia SIP or Lumpsum.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Real-time performance will be\navailable during market hours.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Trading resumes ${_getNextOpeningTime()}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onExploreFunds,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Explore Funds',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
