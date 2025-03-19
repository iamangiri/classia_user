import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class FundCard extends StatelessWidget {
  final Map<String, dynamic> fund;
  final bool isDarkMode;

  const FundCard({required this.fund, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    // Provide default dummy values if any key is null
    final String logoUrl = fund['logo'] ?? "https://via.placeholder.com/150";
    final String name = fund['name'] ?? "Demo Fund";
    final String returns = fund['returns'] ?? "0%";
    final String minSip = fund['minSip'] ?? "₹1000";
    final String rating = fund['rating']?.toString() ?? "0.0";

    return GestureDetector(
      onTap: () {
        _navigateToDetails(context);
      },
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[700] : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(logoUrl),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Color(0xFF212121),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Returns: $returns',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: returns.contains('+')
                    ? Color(0xFF4CAF50)
                    : Color(0xFFF44336),
              ),
            ),
            Text(
              'Min SIP: $minSip',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
            Spacer(),
            Row(
              children: [
                Icon(Icons.star, color: Color(0xFFFFC107), size: 18),
                Text(
                  ' $rating',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : Color(0xFF212121),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }






  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FundDetailsScreen(fund: fund),
      ),
    );
  }
}

class FundDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> fund;

  const FundDetailsScreen({required this.fund});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =  true;
    // Determine text and background colors based on mode.
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color sectionBackground = isDarkMode ? Colors.grey[850]! : Colors.white;
    final Color actionBackground = isDarkMode ? Colors.grey[850]! : Colors.white.withOpacity(0.95);

    // Provide default dummy values for all keys
    final String logoUrl = fund['logo'] ?? "https://via.placeholder.com/150";
    final String name = fund['name'] ?? "Demo Fund";
    final String returns = fund['returns'] ?? "0%";
    final String cagr = fund['cagr'] ?? "0%";
    final String risk = fund['risk']?.toString() ?? "Low";
    final String nav = fund['nav'] ?? "₹0.00";
    final String aum = fund['aum'] ?? "₹0.00";
    final String expenseRatio = fund['expenseRatio'] ?? "0.00%";
    final String minSip = fund['minSip'] ?? "₹1000";
    final String minLumpsum = fund['minLumpsum'] ?? "₹5000";
    final String managerPhoto = fund['managerPhoto'] ?? "https://via.placeholder.com/100";
    final String managerName = fund['managerName'] ?? "John Doe";
    final String managerExperience = fund['managerExperience']?.toString() ?? "0";
    final String managerSince = fund['managerSince'] ?? "2020";

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            backgroundColor: isDarkMode ? Colors.black : Colors.blueAccent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    // Use a darker gradient in dark mode
                    colors: isDarkMode
                        ? [Colors.black, Colors.grey[900]!]
                        : [Colors.blueAccent, Colors.lightBlueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(isDarkMode ? 0.1 : 0.2),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: NetworkImage(logoUrl),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Performance', textColor),
                  SizedBox(height: 16),
                  Container(
                    height: 215,
                    decoration: BoxDecoration(
                      color: sectionBackground,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        )
                      ],
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildPerformanceChart(isDarkMode),
                        SizedBox(height: 16),
                        _buildPerformanceMetrics(returns, cagr, risk, textColor),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  _buildSectionHeader('Key Metrics', textColor),
                  SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildMetricItem('NAV', nav, textColor, isDarkMode),
                      _buildMetricItem('AUM', aum, textColor, isDarkMode),
                      _buildMetricItem('Expense Ratio', expenseRatio, textColor, isDarkMode),
                      _buildMetricItem('Minimum SIP', minSip, textColor, isDarkMode),
                    ],
                  ),
                  SizedBox(height: 24),
                  _buildSectionHeader('Investment Options', textColor),
                  SizedBox(height: 16),
                  _buildInvestmentOptions(minSip, minLumpsum, textColor),
                  SizedBox(height: 24),
                  _buildSectionHeader('Fund Manager', textColor),
                  SizedBox(height: 16),
                  _buildFundManagerInfo(managerPhoto, managerName, managerExperience, managerSince, textColor),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildActionButtons(actionBackground),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  Widget _buildPerformanceChart(bool isDarkMode) {
    // Replace with an actual chart widget if needed.
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.grey[800]!, Colors.grey[700]!]
              : [Colors.blueAccent.withOpacity(0.2), Colors.lightBlueAccent.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          'Performance Chart',
          style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.grey),
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics(String returns, String cagr, String risk, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMetricChip('1Y Return', returns, Colors.lightGreen),
        _buildMetricChip('3Y CAGR', cagr, Colors.amber),
        _buildMetricChip('Risk', risk, Colors.red),
      ],
    );
  }

  Widget _buildMetricChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String title, String value, Color textColor, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentOptions(String minSip, String minLumpsum, Color textColor) {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.account_balance_wallet, color: textColor),
          title: Text('SIP Investment', style: TextStyle(color: textColor)),
          subtitle: Text('Start from $minSip/month', style: TextStyle(color: textColor)),
          trailing: Icon(Icons.arrow_forward_ios, color: textColor),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.money, color: textColor),
          title: Text('Lump Sum Investment', style: TextStyle(color: textColor)),
          subtitle: Text('Minimum $minLumpsum', style: TextStyle(color: textColor)),
          trailing: Icon(Icons.arrow_forward_ios, color: textColor),
        ),
      ],
    );
  }

  Widget _buildFundManagerInfo(String managerPhoto, String managerName, String managerExperience, String managerSince, Color textColor) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(managerPhoto),
      ),
      title: Text(
        managerName,
        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      ),
      subtitle: Text('Experience: $managerExperience years', style: TextStyle(color: textColor)),
      trailing: Chip(
        label: Text('Since $managerSince', style: TextStyle(color: textColor)),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildActionButtons(Color backgroundColor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: Offset(0, -4),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: Icon(Icons.compare,color: Colors.white,),
              label: Text('Compare',style: TextStyle(color: Colors.white),),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(Icons.inventory_sharp,color: Colors.white,),
              label: Text('Invest Now',style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {

              },
            ),
          ),
        ],
      ),
    );
  }
}
