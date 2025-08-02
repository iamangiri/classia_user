// import 'package:classia_amc/screen/sip/sip_deatils%20_screen.dart';
// import 'package:classia_amc/screen/sip/sip_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:lottie/lottie.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import '../../themes/app_colors.dart';
// import 'jockey_sip_screen.dart';
//
// class PortfolioTab extends StatefulWidget {
//   const PortfolioTab({super.key});
//
//   @override
//   _PortfolioTabState createState() => _PortfolioTabState();
// }
//
// class _PortfolioTabState extends State<PortfolioTab> with TickerProviderStateMixin {
//   late AnimationController _horseAnimationController;
//   late Animation<double> _horseAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _horseAnimationController =
//     AnimationController(duration: const Duration(seconds: 2), vsync: this)
//       ..repeat();
//     _horseAnimation = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(
//           parent: _horseAnimationController, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _horseAnimationController.dispose();
//     super.dispose();
//   }
//
//   Future<List<Sip>> _loadSips() async {
//     final prefs = await SharedPreferences.getInstance();
//     return (prefs.getStringList('sips') ?? []).map((json) =>
//         Sip.fromJson(jsonDecode(json))).toList();
//   }
//
//   Future<void> _updateSip(Sip sip) async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> sips = prefs.getStringList('sips') ?? [];
//     int index = sips.indexWhere((json) =>
//     Sip
//         .fromJson(jsonDecode(json))
//         .id == sip.id);
//     if (index != -1) {
//       sips[index] = jsonEncode(sip.toJson());
//       await prefs.setStringList('sips', sips);
//     }
//   }
//
//   String formatCurrency(double amount) {
//     if (amount >= 10000000)
//       return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
//     if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
//     if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}K';
//     return '₹${amount.toStringAsFixed(0)}';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double cardWidth = MediaQuery
//         .of(context)
//         .size
//         .width - 32.w; // Adjusted for padding
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(16.w),
//       child: Column(
//         children: [
//           AnimatedBuilder(
//             animation: _horseAnimation,
//             builder: (context, child) {
//               return Transform.translate(
//                 offset: Offset(
//                     0, 5.h * (0.5 - (_horseAnimation.value - 0.5).abs())),
//                 child: Transform.rotate(
//                   angle: 0.1 * (0.5 - (_horseAnimation.value - 0.5).abs()),
//                   child: SizedBox(
//                     width: 150.w,
//                     height: 100.h,
//                     child: Center(child: Image.asset(
//                         'assets/images/jt1.gif', fit: BoxFit.contain)),
//                   ),
//                 ),
//               );
//             },
//           ),
//           SizedBox(height: 16.h),
//           Text(
//             'Your Investment Journey',
//             style: TextStyle(
//               fontSize: 24.sp,
//               fontWeight: FontWeight.bold,
//               color: AppColors.primaryColor ?? Colors.blueAccent,
//             ),
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             'Manage your SIPs here',
//             style: TextStyle(
//                 fontSize: 16.sp, color: AppColors.secondaryText ?? Colors.grey),
//           ),
//           FutureBuilder<List<Sip>>(
//             future: _loadSips(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                 return const Center(child: Text('No SIPs found'));
//               }
//               return Column(
//                 children: snapshot.data!.asMap().entries.map((entry) {
//                   int index = entry.key;
//                   Sip sip = entry.value;
//                   AnimationController progressController = AnimationController(
//                     duration: const Duration(seconds: 3),
//                     vsync: this,
//                   )
//                     ..forward();
//                   double progress = sip.goal.current / sip.goal.target * 100;
//
//                   return TweenAnimationBuilder(
//                     duration: Duration(milliseconds: 600 + (index * 100)),
//                     tween: Tween<double>(begin: 0.0, end: 1.0),
//                     builder: (context, double value, child) {
//                       return Transform.translate(
//                         offset: Offset(0, 50.h * (1 - value)),
//                         child: Opacity(
//                           opacity: value,
//                           child: GestureDetector(
//                             onTap: () =>
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(builder: (context) =>
//                                       SipDetailsScreen(sip: sip)),
//                                 ),
//                             child: Container(
//                               margin: EdgeInsets.only(bottom: 16.h),
//                               padding: EdgeInsets.all(20.w),
//                               decoration: BoxDecoration(
//                                 color: AppColors.surfaceColor?.withOpacity(
//                                     0.9) ?? Colors.grey[100]!.withOpacity(0.9),
//                                 borderRadius: BorderRadius.circular(20.r),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.1),
//                                     blurRadius: 12.r,
//                                     offset: Offset(0, 4.h),
//                                   ),
//                                 ],
//                                 border: Border.all(
//                                   color: Colors.white.withOpacity(0.2),
//                                   width: 1.w,
//                                 ),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment
//                                         .spaceBetween,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Container(
//                                             padding: EdgeInsets.all(12.w),
//                                             decoration: BoxDecoration(
//                                               color: sip.goal.color.withOpacity(
//                                                   0.2),
//                                               borderRadius: BorderRadius
//                                                   .circular(12.r),
//                                             ),
//                                             child: Icon(
//                                               sip.goal.icon,
//                                               color: sip.goal.color,
//                                               size: 24.sp,
//                                             ),
//                                           ),
//                                           SizedBox(width: 16.w),
//                                           Column(
//                                             crossAxisAlignment: CrossAxisAlignment
//                                                 .start,
//                                             children: [
//                                               Text(
//                                                 sip.goal.name,
//                                                 style: TextStyle(
//                                                   fontSize: 18.sp,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: AppColors
//                                                       .primaryColor ??
//                                                       Colors.blueAccent,
//                                                 ),
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                               Text(
//                                                 'Monthly: ${formatCurrency(
//                                                     sip.monthlyAmount)}',
//                                                 style: TextStyle(
//                                                   fontSize: 14.sp,
//                                                   color: AppColors
//                                                       .secondaryText ??
//                                                       Colors.grey,
//                                                 ),
//                                               ),
//                                               Text(
//                                                 'Status: ${sip.status[0]
//                                                     .toUpperCase()}${sip.status
//                                                     .substring(1)}',
//                                                 style: TextStyle(
//                                                   fontSize: 12.sp,
//                                                   color: sip.status == 'active'
//                                                       ? AppColors.success ??
//                                                       Colors.green
//                                                       : sip.status == 'paused'
//                                                       ? AppColors.warning ??
//                                                       Colors.orange
//                                                       : AppColors.error ??
//                                                       Colors.red,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                       Column(
//                                         crossAxisAlignment: CrossAxisAlignment
//                                             .end,
//                                         children: [
//                                           Text(
//                                             'Target',
//                                             style: TextStyle(
//                                               fontSize: 12.sp,
//                                               color: AppColors.secondaryText ??
//                                                   Colors.grey,
//                                             ),
//                                           ),
//                                           Text(
//                                             formatCurrency(sip.goal.target),
//                                             style: TextStyle(
//                                               fontSize: 16.sp,
//                                               fontWeight: FontWeight.bold,
//                                               color: AppColors.primaryColor ??
//                                                   Colors.blueAccent,
//                                             ),
//                                           ),
//                                           SizedBox(height: 8.h),
//                                           SizedBox(
//                                             width: 60.w,
//                                             height: 60.h,
//                                             child: Lottie.asset(
//                                               sip.goal.lottieAsset,
//                                               fit: BoxFit.contain,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(height: 16.h),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment
//                                         .spaceBetween,
//                                     children: [
//                                       Text(
//                                         'Progress: ${progress.toStringAsFixed(
//                                             1)}%',
//                                         style: TextStyle(
//                                           fontSize: 14.sp,
//                                           fontWeight: FontWeight.w600,
//                                           color: AppColors.primaryColor ??
//                                               Colors.blueAccent,
//                                         ),
//                                       ),
//                                       Row(
//                                         children: [
//                                           Icon(
//                                             Icons.trending_up,
//                                             color: AppColors.success ??
//                                                 Colors.green,
//                                             size: 16.sp,
//                                           ),
//                                           SizedBox(width: 4.w),
//                                           Text(
//                                             'On Track',
//                                             style: TextStyle(
//                                               fontSize: 14.sp,
//                                               fontWeight: FontWeight.w500,
//                                               color: AppColors.success ??
//                                                   Colors.green,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(height: 12.h),
//                                   Stack(
//                                     clipBehavior: Clip.none,
//                                     children: [
//                                       Container(
//                                         width: cardWidth,
//                                         height: 8.h,
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(
//                                               4.r),
//                                           color: Colors.grey[300],
//                                         ),
//                                       ),
//                                       AnimatedBuilder(
//                                         animation: Tween<double>(
//                                             begin: 0, end: progress / 100)
//                                             .animate(
//                                           CurvedAnimation(
//                                               parent: progressController,
//                                               curve: Curves.easeInOut),
//                                         ),
//                                         builder: (context, child) {
//                                           double progressValue = (progress /
//                                               100).clamp(0.0, 1.0);
//                                           return Container(
//                                             width: progressValue * cardWidth,
//                                             height: 8.h,
//                                             decoration: BoxDecoration(
//                                               borderRadius: BorderRadius
//                                                   .circular(4.r),
//                                               gradient: LinearGradient(
//                                                 colors: [
//                                                   AppColors.primaryGold ??
//                                                       const Color(0xFFDAA520),
//                                                   Colors.amber[700]!,
//                                                 ],
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                       AnimatedBuilder(
//                                         animation: Tween<double>(
//                                           begin: 0,
//                                           end: progress / 100,
//                                         ).animate(
//                                           CurvedAnimation(
//                                             parent: progressController,
//                                             curve: Curves.easeInOut,
//                                           ),
//                                         ),
//                                         builder: (context, child) {
//                                           return Positioned(
//                                             left: 0, // Always stay at the left edge
//                                             top: -30, // You can adjust this vertically as needed
//                                             child: SizedBox(
//                                               height: 60,
//                                               width: 80,
//                                               child: Image.asset(
//                                                 'assets/images/jt1.gif',
//                                                 fit: BoxFit.contain,
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                       ),
//
//                                     ],
//                                   ),
//                                   SizedBox(height: 16.h),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment
//                                         .spaceBetween,
//                                     children: [
//                                       Column(
//                                         crossAxisAlignment: CrossAxisAlignment
//                                             .start,
//                                         children: [
//                                           Text(
//                                             'Current Value',
//                                             style: TextStyle(
//                                               fontSize: 12.sp,
//                                               color: AppColors.secondaryText ??
//                                                   Colors.grey,
//                                             ),
//                                           ),
//                                           Text(
//                                             formatCurrency(sip.goal.current),
//                                             style: TextStyle(
//                                               fontSize: 16.sp,
//                                               fontWeight: FontWeight.bold,
//                                               color: AppColors.success ??
//                                                   Colors.green,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       Row(
//                                         children: [
//                                           _buildActionButton(
//                                             icon: Icons.pause,
//                                             color: AppColors.warning ??
//                                                 Colors.orange,
//                                             onPressed: sip.status == 'paused'
//                                                 ? null
//                                                 : () {
//                                               setState(() {
//                                                 sip.status = 'paused';
//                                                 _updateSip(sip);
//                                               });
//                                             },
//                                           ),
//                                           SizedBox(width: 8.w),
//                                           _buildActionButton(
//                                             icon: Icons.stop,
//                                             color: AppColors.error ??
//                                                 Colors.red,
//                                             onPressed: sip.status == 'stopped'
//                                                 ? null
//                                                 : () {
//                                               setState(() {
//                                                 sip.status = 'stopped';
//                                                 _updateSip(sip);
//                                               });
//                                             },
//                                           ),
//                                           SizedBox(width: 8.w),
//                                           _buildActionButton(
//                                             icon: Icons.edit,
//                                             color: AppColors.primaryColor ??
//                                                 Colors.blue,
//                                             onPressed: () {
//                                               // Placeholder for edit functionality
//                                               ScaffoldMessenger
//                                                   .of(context)
//                                                   .showSnackBar(
//                                                 SnackBar(content: Text(
//                                                     'Edit SIP functionality coming soon!')),
//                                               );
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                     onEnd: () {
//                       progressController
//                           .dispose(); // Dispose controller after animation
//                     },
//                   );
//                 }).toList(),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionButton(
//       {required IconData icon, required Color color, required VoidCallback? onPressed}) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: Container(
//         padding: EdgeInsets.all(8.w),
//         decoration: BoxDecoration(
//           color: color.withOpacity(onPressed == null ? 0.3 : 1.0),
//           borderRadius: BorderRadius.circular(12.r),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 6.r,
//               offset: Offset(0, 2.h),
//             ),
//           ],
//         ),
//         child: Icon(icon, size: 20.sp, color: Colors.white),
//       ),
//     );
//   }
// }

import 'package:classia_amc/screen/sip/sip_deatils%20_screen.dart';
import 'package:classia_amc/screen/sip/sip_model.dart';
import 'package:classia_amc/screen/sip/sip_portfolio_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../themes/app_colors.dart';
import 'sip_animated_horse_widget.dart';


class PortfolioTab extends StatefulWidget {
  const PortfolioTab({super.key});

  @override
  _PortfolioTabState createState() => _PortfolioTabState();
}

class _PortfolioTabState extends State<PortfolioTab> with TickerProviderStateMixin {
  late AnimationController _horseAnimationController;
  late Animation<double> _horseAnimation;

  @override
  void initState() {
    super.initState();
    _horseAnimationController =
    AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat();
    _horseAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _horseAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _horseAnimationController.dispose();
    super.dispose();
  }

  Future<List<Sip>> _loadSips() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList('sips') ?? []).map((json) => Sip.fromJson(jsonDecode(json))).toList();
  }

  Future<void> _updateSip(Sip sip) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> sips = prefs.getStringList('sips') ?? [];
    int index = sips.indexWhere((json) => Sip.fromJson(jsonDecode(json)).id == sip.id);
    if (index != -1) {
      sips[index] = jsonEncode(sip.toJson());
      await prefs.setStringList('sips', sips);
    }
  }

  Future<void> _restartSip(Sip sip) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> sips = prefs.getStringList('sips') ?? [];
    Sip newSip = Sip(
      id: DateTime.now().millisecondsSinceEpoch,
      goal: Goal(
        id: sip.goal.id,
        name: sip.goal.name,
        icon: sip.goal.icon,
        target: sip.goal.target,
        current: 0.0, // Reset progress
        monthlyPayment: sip.goal.monthlyPayment,
        color: sip.goal.color,
        progress: 0.0,
        lottieAsset: sip.goal.lottieAsset,
      ),
      frequency: sip.frequency,
      periodMonths: sip.periodMonths,
      monthlyAmount: sip.monthlyAmount,
      funds: sip.funds,
      topUp: sip.topUp,
      status: 'active',
    );
    sips.add(jsonEncode(newSip.toJson()));
    await prefs.setStringList('sips', sips);
    setState(() {});
  }

  Future<void> _confirmAction(String action, Sip sip, VoidCallback onConfirm) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        backgroundColor: AppColors.surfaceColor?.withOpacity(0.9) ?? Colors.grey[100]!.withOpacity(0.9),
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedHorseWidget(),
              SizedBox(height: 16.h),
              Text(
                'Confirm $action',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.primaryColor ?? Colors.blue),
              ),
              SizedBox(height: 8.h),
              Text(
                'Are you sure you want to $action this SIP?',
                style: TextStyle(fontSize: 14.sp, color: AppColors.secondaryText ?? Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    ),
                    child: Text('Confirm', style: TextStyle(fontSize: 14.sp)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirm == true) {
      onConfirm();
    }
  }

  String formatCurrency(double amount) {
    if (amount >= 10000000) return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width - 32.w;
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _horseAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 5.h * (0.5 - (_horseAnimation.value - 0.5).abs())),
                child: Transform.rotate(
                  angle: 0.1 * (0.5 - (_horseAnimation.value - 0.5).abs()),
                  child: SizedBox(
                    width: 150.w,
                    height: 100.h,
                    child: Center(child: Image.asset('assets/images/jt1.gif', fit: BoxFit.contain)),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 16.h),
          Text(
            'Your Investment Journey',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor ?? Colors.blueAccent,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Manage your SIPs here',
            style: TextStyle(fontSize: 16.sp, color: AppColors.secondaryText ?? Colors.grey),
          ),
          FutureBuilder<List<Sip>>(
            future: _loadSips(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No SIPs found'));
              }
              return Column(
                children: snapshot.data!.asMap().entries.map((entry) {
                  int index = entry.key;
                  Sip sip = entry.value;
                  AnimationController progressController = AnimationController(
                    duration: const Duration(seconds: 3),
                    vsync: this,
                  )..forward();
                  double progress = sip.goal.current / sip.goal.target * 100;

                  return TweenAnimationBuilder(
                    duration: Duration(milliseconds: 600 + (index * 100)),
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    builder: (context, double value, child) {
                      return Transform.translate(
                        offset: Offset(0, 50.h * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SipDetailsScreen(sip: sip)),
                            ),
                            child: Container(
                              margin: EdgeInsets.only(bottom: 16.h),
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceColor?.withOpacity(0.9) ?? Colors.grey[100]!.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 12.r,
                                    offset: Offset(0, 4.h),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1.w,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(12.w),
                                            decoration: BoxDecoration(
                                              color: sip.goal.color.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12.r),
                                            ),
                                            child: Icon(
                                              sip.goal.icon,
                                              color: sip.goal.color,
                                              size: 24.sp,
                                            ),
                                          ),
                                          SizedBox(width: 16.w),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                sip.goal.name,
                                                style: TextStyle(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primaryColor ?? Colors.blueAccent,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                'Monthly: ${formatCurrency(sip.monthlyAmount)}',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: AppColors.secondaryText ?? Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                'Status: ${sip.status[0].toUpperCase()}${sip.status.substring(1)}',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: sip.status == 'active'
                                                      ? AppColors.success ?? Colors.green
                                                      : sip.status == 'paused'
                                                      ? AppColors.warning ?? Colors.orange
                                                      : AppColors.error ?? Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Target',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: AppColors.secondaryText ?? Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            formatCurrency(sip.goal.target),
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primaryColor ?? Colors.blueAccent,
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          SizedBox(
                                            width: 60.w,
                                            height: 60.h,
                                            child: Lottie.asset(
                                              sip.goal.lottieAsset,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Progress: ${progress.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryColor ?? Colors.blueAccent,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.trending_up,
                                            color: AppColors.success ?? Colors.green,
                                            size: 16.sp,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            'On Track',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.success ?? Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12.h),
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width: cardWidth,
                                        height: 8.h,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4.r),
                                          color: Colors.grey[300],
                                        ),
                                      ),
                                      AnimatedBuilder(
                                        animation: Tween<double>(begin: 0, end: progress / 100).animate(
                                          CurvedAnimation(parent: progressController, curve: Curves.easeInOut),
                                        ),
                                        builder: (context, child) {
                                          double progressValue = (progress / 100).clamp(0.0, 1.0);
                                          return Container(
                                            width: progressValue * cardWidth,
                                            height: 8.h,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(4.r),
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppColors.primaryGold ?? const Color(0xFFDAA520),
                                                  Colors.amber[700]!,
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      AnimatedBuilder(
                                        animation: Tween<double>(begin: 0, end: progress / 100).animate(
                                          CurvedAnimation(parent: progressController, curve: Curves.easeInOut),
                                        ),
                                        builder: (context, child) {
                                          double progressValue = (progress / 100).clamp(0.0, 1.0);
                                          return Positioned(
                                            left: (progressValue * cardWidth) - 20.w,
                                            top: -30.h,
                                            child: SizedBox(
                                              height: 60.h,
                                              width: 80.w,
                                              child: Image.asset(
                                                'assets/images/jt1.gif',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Current Value',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: AppColors.secondaryText ?? Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            formatCurrency(sip.goal.current),
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.success ?? Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          if (sip.status != 'paused')
                                            _buildActionButton(
                                              icon: Icons.pause,
                                              color: AppColors.warning ?? Colors.orange,
                                              onPressed: () => _confirmAction('Pause', sip, () {
                                                setState(() {
                                                  sip.status = 'paused';
                                                  _updateSip(sip);
                                                });
                                              }),
                                            ),
                                          if (sip.status == 'paused')
                                            _buildActionButton(
                                              icon: Icons.play_arrow,
                                              color: AppColors.success ?? Colors.green,
                                              onPressed: () => _confirmAction('Resume', sip, () {
                                                setState(() {
                                                  sip.status = 'active';
                                                  _updateSip(sip);
                                                });
                                              }),
                                            ),
                                          SizedBox(width: 8.w),
                                          if (sip.status != 'stopped')
                                            _buildActionButton(
                                              icon: Icons.stop,
                                              color: AppColors.error ?? Colors.red,
                                              onPressed: () => _confirmAction('Stop', sip, () {
                                                setState(() {
                                                  sip.status = 'stopped';
                                                  _updateSip(sip);
                                                });
                                              }),
                                            ),
                                          if (sip.status == 'stopped')
                                            _buildActionButton(
                                              icon: Icons.restart_alt,
                                              color: AppColors.primaryColor ?? Colors.blue,
                                              onPressed: () => _confirmAction('Restart', sip, () => _restartSip(sip)),
                                            ),
                                          SizedBox(width: 8.w),
                                          _buildActionButton(
                                            icon: Icons.edit,
                                            color: AppColors.primaryColor ?? Colors.blue,
                                            onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => SipEditScreen(sip: sip)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    onEnd: () {
                      progressController.dispose();
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Icon(icon, size: 20.sp, color: Colors.white),
      ),
    );
  }
}