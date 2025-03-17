import 'package:flutter/material.dart';

class FundCard extends StatelessWidget {
  final Map<String, dynamic> fund;
  final bool isDarkMode;

  const FundCard({required this.fund, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
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
                      image: NetworkImage(fund['logo']),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(fund['name'],
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Color(0xFF212121))),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('Returns: ${fund['returns']}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: fund['returns'].contains('+')
                        ? Color(0xFF4CAF50)
                        : Color(0xFFF44336))),
            Text('Min SIP: ${fund['minSip']}',
                style: TextStyle(fontSize: 12, color: Colors.grey[400])),
            Spacer(),
            Row(
              children: [
                Icon(Icons.star, color: Color(0xFFFFC107), size: 18),
                Text(' ${fund['rating']}',
                    style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white70 : Color(0xFF212121))),
              ],
            )
          ],
        ),
      ),
    );
  }



  Widget _buildInfoRow(String label, String value,
      {Color? positiveColor, String? riskLevel}) {
    Color valueColor = Colors.grey;
    if (positiveColor != null && value.contains('+')) {
      valueColor = positiveColor;
    }
    if (riskLevel != null) {
      valueColor = _getRiskColor(riskLevel);
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value,
              style: TextStyle(
                  color: valueColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) => Icon(
        index < rating.floor() ? Icons.star : Icons.star_border,
        color: Color(0xFFFFD700),
        size: 16,
      )),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.lightBlueAccent],
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
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: NetworkImage(fund['logo']),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(fund['name'],
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
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
                  _buildSectionHeader('Performance'),
                  SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[900] : Colors.white,
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
                        _buildPerformanceChart(),
                        SizedBox(height: 16),
                        _buildPerformanceMetrics(),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  _buildSectionHeader('Key Metrics'),
                  SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildMetricItem('NAV', fund['nav']),
                      _buildMetricItem('AUM', fund['aum']),
                      _buildMetricItem('Expense Ratio', fund['expenseRatio']),
                      _buildMetricItem('Minimum SIP', fund['minSip']),
                    ],
                  ),
                  SizedBox(height: 24),
                  _buildSectionHeader('Investment Options'),
                  SizedBox(height: 16),
                  _buildInvestmentOptions(),
                  SizedBox(height: 24),
                  _buildSectionHeader('Fund Manager'),
                  SizedBox(height: 16),
                  _buildFundManagerInfo(),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title,
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold));
  }

  Widget _buildPerformanceChart() {
    // Implement actual chart here
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent.withOpacity(0.2), Colors.lightBlueAccent.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(child: Text('Performance Chart', style: TextStyle(color: Colors.grey))),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMetricChip('1Y Return', fund['returns'], Colors.lightGreen),
        _buildMetricChip('3Y CAGR', fund['cagr'], Colors.amber),
        _buildMetricChip('Risk', fund['risk'] ,Colors.red),
      ],
    );
  }

  Widget _buildMetricChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
        SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMetricItem(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: TextStyle(color: Colors.grey))),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildInvestmentOptions() {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.account_balance_wallet),
          title: Text('SIP Investment'),
          subtitle: Text('Start from ₹${fund['minSip']}/month'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.money),
          title: Text('Lump Sum Investment'),
          subtitle: Text('Minimum ₹${fund['minLumpsum']}'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
      ],
    );
  }

  Widget _buildFundManagerInfo() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(fund['managerPhoto']),
      ),
      title: Text(fund['managerName'],
          style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('Experience: ${fund['managerExperience']}'),
      trailing: Chip(
          label: Text('Since ${fund['managerSince']}'),
          backgroundColor: Colors.blueAccent.withOpacity(0.1)),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
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
              icon: Icon(Icons.compare),
              label: Text('Compare'),
              style: OutlinedButton.styleFrom(
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
              icon: Icon(Icons.inventory_sharp),
              label: Text('Invest Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}