import 'package:flutter/material.dart';
import '../screen/market/fund_deatils_screen.dart';
import '../themes/app_colors.dart';


class FundCard extends StatelessWidget {
  final Map<String, dynamic> fund;
  final bool isDarkMode;

  const FundCard({required this.fund, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final String logoUrl = fund['logo'] ?? "https://via.placeholder.com/150";
    final String name = fund['name'] ?? "Demo Fund";
    final String returns = fund['returns'] ?? "0%";
    final String minSip = fund['minSip'] ?? "₹1000";
    final String rating = fund['rating']?.toString() ?? "0.0";

    return GestureDetector(
      onTap: () {
        navigateToDetails(context);
      },
      child: Container(
        width: 160, // Reduced width for compactness
        height: 200, // Reduced height for better fit
        decoration: BoxDecoration(
          color: AppColors.cardBackground, // Light card background
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(12), // Reduced padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      logoUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.screenBackground,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.broken_image,
                            size: 20,
                            color: AppColors.secondaryText,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Returns: $returns',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: returns.contains('+')
                    ? AppColors.success
                    : AppColors.error,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Min SIP: $minSip',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
              ),
            ),
            Spacer(),
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: AppColors.warning,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  rating,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FundDetailsScreen(fund: fund),
      ),
    );
  }
}