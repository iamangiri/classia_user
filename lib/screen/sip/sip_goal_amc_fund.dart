
import 'package:classia_amc/screen/sip/sip_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../service/apiservice/api_service.dart';
import '../../themes/app_colors.dart';

class AMCListScreen extends StatefulWidget {
  AMCListScreen({super.key});

  @override
  _AMCListScreenState createState() => _AMCListScreenState();
}

class _AMCListScreenState extends State<AMCListScreen> {
  final ApiService _apiService = ApiService();
  List<AMC> amcs = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAMCs();
  }

  Future<void> _fetchAMCs() async {
    try {
      final response = await _apiService.fetchMutualFunds();
      final funds = response.data.usersList;

      // Group funds by AMC
      final Map<String, List<Scheme>> amcMap = {};
      for (var fund in funds) {
        if (!amcMap.containsKey(fund.amc)) {
          amcMap[fund.amc] = [];
        }
        amcMap[fund.amc]!.add(Scheme(
          name: fund.scheamName,
          rank: 'N/A', // API doesn't provide rank
          returnRate: fund.oneYearChange ?? 'N/A',
          risk: 'N/A', // API doesn't provide risk
        ));
      }

      // Convert to list of AMCs
      final List<AMC> fetchedAMCs = amcMap.entries
          .map((entry) => AMC(
        name: entry.key,
        schemes: entry.value,
      ))
          .toList();

      setState(() {
        amcs = fetchedAMCs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select AMC',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.backgroundColor ?? Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: amcs.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w, vertical: 8.h),
              title: Text(
                amcs[index].name,
                style: TextStyle(
                    fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: AppColors.primaryColor ?? Colors.blue,
              ),
              onTap: () => Navigator.pop(context, amcs[index]),
            ),
          );
        },
      ),
    );
  }
}










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
        title: Text(
          'Select Schemes for ${widget.amc.name}',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
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
              title: Text(
                scheme.name,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Rank: ${scheme.rank} | Return: ${scheme.returnRate} | Risk: ${scheme.risk}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.secondaryText ?? Colors.grey,
                ),
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





class TopFundsScreen extends StatefulWidget {
  const TopFundsScreen({super.key});

  @override
  _TopFundsScreenState createState() => _TopFundsScreenState();
}

class _TopFundsScreenState extends State<TopFundsScreen> {
  final ApiService _apiService = ApiService();
  List<Fund> topFunds = [];
  List<Fund> selectedFunds = [];
  bool isLoading = true;
  String? errorMessage;

  final List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _fetchTopFunds();
  }

  Future<void> _fetchTopFunds() async {
    try {
      final response = await _apiService.fetchMutualFunds();
      final funds = response.data.usersList
          .where((fund) => !fund.isDeleted)
          .take(5) // Select first 5 non-deleted funds as "top funds"
          .toList();

      final List<Fund> fetchedFunds = funds.asMap().entries.map((entry) {
        final index = entry.key;
        final fund = entry.value;
        return Fund(
          name: fund.scheamName,
          returnRate: fund.oneYearChange ?? 'N/A',
          risk: 'N/A', // API doesn't provide risk
          color: colors[index % colors.length], // Assign a color cyclically
        );
      }).toList();

      setState(() {
        topFunds = fetchedFunds;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Top Funds',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.backgroundColor ?? Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : ListView.builder(
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
              title: Text(
                fund.name,
                style: TextStyle(
                    fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Return: ${fund.returnRate}, Risk: ${fund.risk}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.secondaryText ?? Colors.grey,
                ),
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