import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'add_bank_screen.dart';

class BankInfoScreen extends StatefulWidget {
  const BankInfoScreen({Key? key}) : super(key: key);

  @override
  _BankInfoScreenState createState() => _BankInfoScreenState();
}

class _BankInfoScreenState extends State<BankInfoScreen> {
  // Dummy bank details list; replace with actual data source
  List<Map<String, String>> bankDetails = [
  ];

  void _addBank(Map<String, String> newBank) {
    setState(() {
      bankDetails.add(newBank);
    });
  }

  void _editBank(int index, Map<String, String> updatedBank) {
    setState(() {
      bankDetails[index] = updatedBank;
    });
  }

  void _deleteBank(int index) {
    setState(() {
      bankDetails.removeAt(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Bank deleted successfully"),
          backgroundColor: AppColors.success,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(title: 'Bank Information'),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            if (bankDetails.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(
                      Icons.account_balance, // Bank icon
                      size: 120.w, // same size as before
                      color: AppColors.secondaryText,
                    ),
                      SizedBox(height: 16.h),
                      Text(
                        "No bank details available",
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 18.sp,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddBankScreen(
                                onSave: _addBank,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.add, color: AppColors.buttonText, size: 20.sp),
                        label: Text(
                          "Add Bank",
                          style: TextStyle(
                            color: AppColors.buttonText,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: bankDetails.length,
                  itemBuilder: (context, index) {
                    final bank = bankDetails[index];
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8.h),
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
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    bank["bankName"] ?? "",
                                    style: TextStyle(
                                      color: AppColors.primaryText,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit, color: AppColors.primaryGold, size: 20.sp),
                                  onPressed: () {
                                    // Placeholder for EditBankScreen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddBankScreen(
                                          onSave: (updatedBank) => _editBank(index, updatedBank),
                                          initialData: bank,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: AppColors.error, size: 20.sp),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: AppColors.cardBackground,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                        title: Text(
                                          "Delete Bank",
                                          style: TextStyle(color: AppColors.primaryText, fontSize: 18.sp),
                                        ),
                                        content: Text(
                                          "Are you sure you want to delete this bank?",
                                          style: TextStyle(color: AppColors.secondaryText, fontSize: 16.sp),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text(
                                              "Cancel",
                                              style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              _deleteBank(index);
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              "Delete",
                                              style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "Branch: ${bank["branch"] ?? ""}",
                              style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "Account Holder: ${bank["accountHolder"] ?? ""}",
                              style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "Account Number: ${bank["accountNumber"] ?? ""}",
                              style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "IFSC: ${bank["ifsc"] ?? ""}",
                              style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 20.h),
            if (bankDetails.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddBankScreen(
                        onSave: _addBank,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.add, color: AppColors.buttonText, size: 20.sp),
                label: Text(
                  "Add Bank",
                  style: TextStyle(
                    color: AppColors.buttonText,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  minimumSize: Size(double.infinity, 48.h),
                ),
              ),
          ],
        ),
      ),
    );
  }
}