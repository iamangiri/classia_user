// import 'package:classia_amc/screen/sip/sip_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../service/apiservice/api_service.dart';
// import '../../themes/app_colors.dart';
//
// class AMCListScreen extends StatefulWidget {
//   AMCListScreen({super.key});
//
//   @override
//   _AMCListScreenState createState() => _AMCListScreenState();
// }
//
// class _AMCListScreenState extends State<AMCListScreen> {
//   final ApiService _apiService = ApiService();
//   List<AMC> amcs = [];
//   bool isLoading = true;
//   String? errorMessage;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchAMCs();
//   }
//
//   Future<void> _fetchAMCs() async {
//     try {
//       final response = await _apiService.fetchMutualFunds();
//       final funds = response.data.usersList;
//
//       // Group funds by AMC
//       final Map<String, List<Scheme>> amcMap = {};
//       for (var fund in funds) {
//         if (!amcMap.containsKey(fund.amc)) {
//           amcMap[fund.amc] = [];
//         }
//         amcMap[fund.amc]!.add(Scheme(
//           name: fund.scheamName,
//           rank: 'N/A', // API doesn't provide rank
//           returnRate: fund.oneYearChange ?? 'N/A',
//           risk: 'N/A', // API doesn't provide risk
//         ));
//       }
//
//       // Convert to list of AMCs
//       final List<AMC> fetchedAMCs = amcMap.entries
//           .map((entry) => AMC(
//         name: entry.key,
//         schemes: entry.value,
//       ))
//           .toList();
//
//       setState(() {
//         amcs = fetchedAMCs;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         errorMessage = e.toString();
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Select AMC',
//           style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: AppColors.backgroundColor ?? Colors.white,
//         elevation: 0,
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : errorMessage != null
//           ? Center(child: Text(errorMessage!))
//           : ListView.builder(
//         padding: EdgeInsets.all(16.w),
//         itemCount: amcs.length,
//         itemBuilder: (context, index) {
//           return Card(
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12.r)),
//             child: ListTile(
//               contentPadding: EdgeInsets.symmetric(
//                   horizontal: 16.w, vertical: 8.h),
//               title: Text(
//                 amcs[index].name,
//                 style: TextStyle(
//                     fontSize: 16.sp, fontWeight: FontWeight.w600),
//               ),
//               trailing: Icon(
//                 Icons.arrow_forward_ios,
//                 size: 16.sp,
//                 color: AppColors.primaryColor ?? Colors.blue,
//               ),
//               onTap: () => Navigator.pop(context, amcs[index]),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
//
//
//
//
//
//
//
//
//
// class SchemeListScreen extends StatefulWidget {
//   final AMC amc;
//
//   const SchemeListScreen({super.key, required this.amc});
//
//   @override
//   _SchemeListScreenState createState() => _SchemeListScreenState();
// }
//
// class _SchemeListScreenState extends State<SchemeListScreen> {
//   final List<Scheme> selectedSchemes = [];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Select Schemes for ${widget.amc.name}',
//           style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: AppColors.backgroundColor ?? Colors.white,
//         elevation: 0,
//       ),
//       body: ListView.builder(
//         padding: EdgeInsets.all(16.w),
//         itemCount: widget.amc.schemes.length,
//         itemBuilder: (context, index) {
//           Scheme scheme = widget.amc.schemes[index];
//           return Card(
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12.r)),
//             child: CheckboxListTile(
//               contentPadding:
//               EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//               title: Text(
//                 scheme.name,
//                 style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
//               ),
//               subtitle: Text(
//                 'Rank: ${scheme.rank} | Return: ${scheme.returnRate} | Risk: ${scheme.risk}',
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   color: AppColors.secondaryText ?? Colors.grey,
//                 ),
//               ),
//               value: selectedSchemes.contains(scheme),
//               activeColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
//               onChanged: (value) {
//                 setState(() {
//                   if (value == true) {
//                     selectedSchemes.add(scheme);
//                   } else {
//                     selectedSchemes.remove(scheme);
//                   }
//                 });
//               },
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => Navigator.pop(context, selectedSchemes),
//         backgroundColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
//         child: Icon(Icons.check, color: Colors.white),
//       ),
//     );
//   }
// }
//
//
//
//
//
// class TopFundsScreen extends StatefulWidget {
//   const TopFundsScreen({super.key});
//
//   @override
//   _TopFundsScreenState createState() => _TopFundsScreenState();
// }
//
// class _TopFundsScreenState extends State<TopFundsScreen> {
//   final ApiService _apiService = ApiService();
//   List<Fund> topFunds = [];
//   List<Fund> selectedFunds = [];
//   bool isLoading = true;
//   String? errorMessage;
//
//   final List<Color> colors = [
//     Colors.blue,
//     Colors.green,
//     Colors.red,
//     Colors.orange,
//     Colors.purple,
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchTopFunds();
//   }
//
//   Future<void> _fetchTopFunds() async {
//     try {
//       final response = await _apiService.fetchMutualFunds();
//       final funds = response.data.usersList
//           .where((fund) => !fund.isDeleted)
//           .take(5) // Select first 5 non-deleted funds as "top funds"
//           .toList();
//
//       final List<Fund> fetchedFunds = funds.asMap().entries.map((entry) {
//         final index = entry.key;
//         final fund = entry.value;
//         return Fund(
//           name: fund.scheamName,
//           returnRate: fund.oneYearChange ?? 'N/A',
//           risk: 'N/A', // API doesn't provide risk
//           color: colors[index % colors.length], // Assign a color cyclically
//         );
//       }).toList();
//
//       setState(() {
//         topFunds = fetchedFunds;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         errorMessage = e.toString();
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Select Top Funds',
//           style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: AppColors.backgroundColor ?? Colors.white,
//         elevation: 0,
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : errorMessage != null
//           ? Center(child: Text(errorMessage!))
//           : ListView.builder(
//         padding: EdgeInsets.all(16.w),
//         itemCount: topFunds.length,
//         itemBuilder: (context, index) {
//           Fund fund = topFunds[index];
//           return Card(
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12.r)),
//             child: CheckboxListTile(
//               contentPadding:
//               EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//               title: Text(
//                 fund.name,
//                 style: TextStyle(
//                     fontSize: 16.sp, fontWeight: FontWeight.w600),
//               ),
//               subtitle: Text(
//                 'Return: ${fund.returnRate}, Risk: ${fund.risk}',
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   color: AppColors.secondaryText ?? Colors.grey,
//                 ),
//               ),
//               value: selectedFunds.contains(fund),
//               activeColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
//               onChanged: (value) {
//                 setState(() {
//                   if (value == true) {
//                     selectedFunds.add(fund);
//                   } else {
//                     selectedFunds.remove(fund);
//                   }
//                 });
//               },
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => Navigator.pop(context, selectedFunds),
//         backgroundColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
//         child: Icon(Icons.check, color: Colors.white),
//       ),
//     );
//   }
// }

import 'package:classia_amc/models/mutual_fund_models.dart' show MutualFund;
import 'package:classia_amc/screen/sip/sip_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../service/apiservice/api_service.dart';
import '../../themes/app_colors.dart';

class AMCListScreen extends StatefulWidget {
  const AMCListScreen({super.key});

  @override
  _AMCListScreenState createState() => _AMCListScreenState();
}

class _AMCListScreenState extends State<AMCListScreen> {
  final ApiService _apiService = ApiService();
  List<AMC> amcs = [];
  List<AMC> filteredAmcs = [];
  bool isLoading = true;
  String? errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAMCs();
    _searchController.addListener(_filterAmcs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterAmcs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredAmcs = query.isEmpty
          ? amcs
          : amcs.where((amc) => amc.name.toLowerCase().contains(query)).toList();
    });
  }

  Future<void> _fetchAMCs() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await _apiService.fetchMutualFunds();
      final funds = response.data.mfList; // Changed from usersList to mfList

      if (funds.isEmpty) {
        setState(() {
          errorMessage = 'No mutual funds available';
          isLoading = false;
        });
        return;
      }

      // Group funds by AMC
      final Map<String, List<Scheme>> amcMap = {};
      for (var fund in funds.where((f) => !f.isDeleted)) { // Filter out deleted funds
        if (!amcMap.containsKey(fund.amc)) {
          amcMap[fund.amc] = [];
        }
        amcMap[fund.amc]!.add(Scheme(
          name: fund.shortName, // Use shortened name for better UI
          rank: 'N/A',
          returnRate: fund.displayReturn,
          risk: _calculateRisk(fund), // Calculate risk based on return volatility
        ));
      }

      // Convert to list of AMCs and sort
      final List<AMC> fetchedAMCs = amcMap.entries
          .map((entry) => AMC(
        name: entry.key,
        schemes: entry.value,
      ))
          .toList();

      fetchedAMCs.sort((a, b) => a.name.compareTo(b.name));

      setState(() {
        amcs = fetchedAMCs;
        filteredAmcs = fetchedAMCs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  String _calculateRisk(MutualFund fund) {
    // Simple risk calculation based on return ranges
    final oneYear = fund.oneYearChange;
    if (oneYear == null) return 'N/A';

    try {
      final returnValue = double.parse(oneYear.replaceAll('%', ''));
      if (returnValue < 5) return 'Low';
      if (returnValue < 15) return 'Medium';
      return 'High';
    } catch (e) {
      return 'N/A';
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search AMCs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text('Loading AMCs...', style: TextStyle(fontSize: 16.sp)),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
              SizedBox(height: 16.h),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                errorMessage!,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: _fetchAMCs,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredAmcs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64.sp, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              _searchController.text.isEmpty
                  ? 'No AMCs available'
                  : 'No AMCs found matching "${_searchController.text}"',
              style: TextStyle(fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchAMCs,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: filteredAmcs.length,
        itemBuilder: (context, index) {
          final amc = filteredAmcs[index];
          return Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: 12.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryColor?.withOpacity(0.1) ??
                    Colors.blue.withOpacity(0.1),
                child: Text(
                  amc.name.isNotEmpty ? amc.name[0].toUpperCase() : 'A',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor ?? Colors.blue,
                  ),
                ),
              ),
              title: Text(
                amc.name,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${amc.schemes.length} scheme${amc.schemes.length != 1 ? 's' : ''} available',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: AppColors.primaryColor ?? Colors.blue,
              ),
              onTap: () => Navigator.pop(context, amc),
            ),
          );
        },
      ),
    );
  }
}

// Enhanced TopFundsScreen
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
    Colors.teal,
    Colors.indigo,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _fetchTopFunds();
  }

  Future<void> _fetchTopFunds() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await _apiService.fetchMutualFunds();
      final allFunds = response.data.mfList
          .where((fund) => !fund.isDeleted && fund.oneYearChange != null)
          .toList();

      if (allFunds.isEmpty) {
        setState(() {
          errorMessage = 'No funds available';
          isLoading = false;
        });
        return;
      }

      // Sort by one year return and take top performing funds
      allFunds.sort((a, b) {
        try {
          final aReturn = double.parse(a.oneYearChange!.replaceAll('%', ''));
          final bReturn = double.parse(b.oneYearChange!.replaceAll('%', ''));
          return bReturn.compareTo(aReturn); // Descending order
        } catch (e) {
          return 0;
        }
      });

      final topPerformingFunds = allFunds.take(10).toList(); // Top 10 funds

      final List<Fund> fetchedFunds = topPerformingFunds.asMap().entries.map((entry) {
        final index = entry.key;
        final fund = entry.value;
        return Fund(
          name: fund.shortName,
          returnRate: fund.displayReturn,
          risk: _calculateRisk(fund),
          color: colors[index % colors.length],
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

  String _calculateRisk(MutualFund fund) {
    final oneYear = fund.oneYearChange;
    if (oneYear == null) return 'N/A';

    try {
      final returnValue = double.parse(oneYear.replaceAll('%', ''));
      if (returnValue < 5) return 'Low';
      if (returnValue < 15) return 'Medium';
      return 'High';
    } catch (e) {
      return 'N/A';
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
        actions: [
          if (selectedFunds.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Center(
                child: Text(
                  '${selectedFunds.length} selected',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryGold ?? const Color(0xFFDAA520),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!),
            ElevatedButton(
              onPressed: _fetchTopFunds,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchTopFunds,
        child: ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: topFunds.length,
          itemBuilder: (context, index) {
            Fund fund = topFunds[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.only(bottom: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: CheckboxListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                secondary: Container(
                  width: 4.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: fund.color,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                title: Text(
                  fund.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.trending_up,
                            size: 14.sp, color: Colors.green),
                        SizedBox(width: 4.w),
                        Text(
                          'Return: ${fund.returnRate}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Icon(Icons.security,
                            size: 14.sp, color: Colors.orange),
                        SizedBox(width: 4.w),
                        Text(
                          'Risk: ${fund.risk}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
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
      ),
      floatingActionButton: selectedFunds.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context, selectedFunds),
        backgroundColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
        icon: const Icon(Icons.check, color: Colors.white),
        label: Text(
          'Select (${selectedFunds.length})',
          style: const TextStyle(color: Colors.white),
        ),
      )
          : null,
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