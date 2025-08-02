
// AMCListScreen (Unchanged)
import 'package:classia_amc/screen/sip/sip_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../themes/app_colors.dart';

class AMCListScreen extends StatelessWidget {
  AMCListScreen({super.key});

  final List<AMC> amcs = [
    AMC(
      name: 'SBI Mutual Fund',
      schemes: [
        Scheme(
            name: 'SBI Bluechip Fund',
            rank: '1',
            returnRate: '14.5%',
            risk: 'High'),
        Scheme(
            name: 'SBI Small Cap Fund',
            rank: '2',
            returnRate: '18.2%',
            risk: 'High'),
      ],
    ),
    AMC(
      name: 'HDFC Mutual Fund',
      schemes: [
        Scheme(
            name: 'HDFC Mid-Cap Opportunities',
            rank: '1',
            returnRate: '16.8%',
            risk: 'High'),
        Scheme(
            name: 'HDFC Flexi Cap Fund',
            rank: '3',
            returnRate: '13.9%',
            risk: 'Moderate'),
      ],
    ),
    AMC(
      name: 'ICICI Prudential Mutual Fund',
      schemes: [
        Scheme(
            name: 'ICICI Pru Value Discovery',
            rank: '2',
            returnRate: '15.1%',
            risk: 'Moderate'),
        Scheme(
            name: 'ICICI Pru Equity & Debt',
            rank: '1',
            returnRate: '12.7%',
            risk: 'Moderate'),
      ],
    ),
    AMC(
      name: 'Axis Mutual Fund',
      schemes: [
        Scheme(
            name: 'Axis Long Term Equity',
            rank: '1',
            returnRate: '14.0%',
            risk: 'High'),
        Scheme(
            name: 'Axis Bluechip Fund',
            rank: '2',
            returnRate: '11.8%',
            risk: 'Moderate'),
      ],
    ),
    AMC(
      name: 'Aditya Birla Sun Life',
      schemes: [
        Scheme(
            name: 'ABSL Frontline Equity',
            rank: '3',
            returnRate: '13.5%',
            risk: 'Moderate'),
        Scheme(
            name: 'ABSL Tax Relief 96',
            rank: '2',
            returnRate: '12.9%',
            risk: 'Moderate'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select AMC',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundColor ?? Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: amcs.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
            child: ListTile(
              contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              title: Text(amcs[index].name,
                  style:
                  TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              trailing: Icon(Icons.arrow_forward_ios,
                  size: 16.sp, color: AppColors.primaryColor ?? Colors.blue),
              onTap: () => Navigator.pop(context, amcs[index]),
            ),
          );
        },
      ),
    );
  }
}

// SchemeListScreen (Unchanged)
class SchemeListScreen extends StatefulWidget {
  final AMC amc;

  const SchemeListScreen({super.key, required this.amc});

  @override
  _SchemeListScreenState createState() => _SchemeListScreenState();
}

class _SchemeListScreenState extends State<SchemeListScreen> {
  final List<Scheme> selectedSchemes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Schemes for ${widget.amc.name}',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundColor ?? Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: widget.amc.schemes.length,
        itemBuilder: (context, index) {
          Scheme scheme = widget.amc.schemes[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
            child: CheckboxListTile(
              contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              title: Text(scheme.name,
                  style:
                  TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              subtitle: Text(
                'Rank: ${scheme.rank} | Return: ${scheme.returnRate} | Risk: ${scheme.risk}',
                style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.secondaryText ?? Colors.grey),
              ),
              value: selectedSchemes.contains(scheme),
              activeColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedSchemes.add(scheme);
                  } else {
                    selectedSchemes.remove(scheme);
                  }
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context, selectedSchemes),
        backgroundColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
        child: Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}

// TopFundsScreen (Unchanged)
class TopFundsScreen extends StatefulWidget {
  const TopFundsScreen({super.key});

  @override
  _TopFundsScreenState createState() => _TopFundsScreenState();
}

class _TopFundsScreenState extends State<TopFundsScreen> {
  final List<Fund> topFunds = [
    Fund(
        name: 'Parag Parikh Flexi Cap Fund',
        returnRate: '17.2%',
        risk: 'Moderate',
        color: Colors.blue),
    Fund(
        name: 'Mirae Asset Large Cap Fund',
        returnRate: '14.8%',
        risk: 'Moderate',
        color: Colors.green),
    Fund(
        name: 'Kotak Emerging Equity Fund',
        returnRate: '16.5%',
        risk: 'High',
        color: Colors.red),
    Fund(
        name: 'Nippon India Small Cap Fund',
        returnRate: '19.1%',
        risk: 'High',
        color: Colors.orange),
    Fund(
        name: 'HDFC Balanced Advantage Fund',
        returnRate: '13.7%',
        risk: 'Moderate',
        color: Colors.purple),
  ];
  final List<Fund> selectedFunds = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Top Funds',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundColor ?? Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: topFunds.length,
        itemBuilder: (context, index) {
          Fund fund = topFunds[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
            child: CheckboxListTile(
              contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              title: Text(fund.name,
                  style:
                  TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              subtitle: Text(
                'Return: ${fund.returnRate}, Risk: ${fund.risk}',
                style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.secondaryText ?? Colors.grey),
              ),
              value: selectedFunds.contains(fund),
              activeColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedFunds.add(fund);
                  } else {
                    selectedFunds.remove(fund);
                  }
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context, selectedFunds),
        backgroundColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
        child: Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}
