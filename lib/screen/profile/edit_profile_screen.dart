import 'dart:io';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:classia_amc/themes/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers for editable fields only
  final TextEditingController _fullNameController = TextEditingController(text: UserConstants.NAME);
  final TextEditingController _addressController = TextEditingController(text: UserConstants.ADDRESS);
  final TextEditingController _cityController = TextEditingController(text: UserConstants.CITY);
  final TextEditingController _stateController = TextEditingController(text: UserConstants.STATE);
  final TextEditingController _pinCodeController = TextEditingController(text: UserConstants.PIN_CODE);

  File? _profileImage;

  @override
  void initState() {
    super.initState();
    // Load profile image if exists
    if (UserConstants.PROFILE_IMAGE.isNotEmpty) {
      // If you have a local file path stored
      // _profileImage = File(UserConstants.PROFILE_IMAGE);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );

      if (pickedImage != null) {
        // Crop the image
        final CroppedFile? croppedImage = await ImageCropper().cropImage(
          sourcePath: pickedImage.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: AppColors.primaryGold,
              toolbarWidgetColor: AppColors.buttonText,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              hideBottomControls: false,
              statusBarColor: AppColors.primaryGold,
              activeControlsWidgetColor: AppColors.primaryGold,
            ),
            IOSUiSettings(
              title: 'Crop Image',
              minimumAspectRatio: 1.0,
              aspectRatioLockEnabled: true,
            ),
          ],
        );

        if (croppedImage != null) {
          setState(() {
            _profileImage = File(croppedImage.path);
          });
        }
      }
    } catch (e) {
      _showSnackBar("Failed to pick image: ${e.toString()}", isError: true);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Select Image Source',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primaryGold, size: 24.sp),
              title: Text('Camera', style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primaryGold, size: 24.sp),
              title: Text('Gallery', style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_profileImage != null)
              ListTile(
                leading: Icon(Icons.delete, color: AppColors.error, size: 24.sp),
                title: Text('Remove Image', style: TextStyle(color: AppColors.error, fontSize: 16.sp)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _profileImage = null);
                },
              ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Simulate API call - replace with actual API call
        await Future.delayed(const Duration(seconds: 2));

        // Update UserConstants
        await UserConstants.updateField(UserConstants.NAME_KEY, _fullNameController.text);
        await UserConstants.updateField(UserConstants.ADDRESS_KEY, _addressController.text);
        await UserConstants.updateField(UserConstants.CITY_KEY, _cityController.text);
        await UserConstants.updateField(UserConstants.STATE_KEY, _stateController.text);
        await UserConstants.updateField(UserConstants.PIN_CODE_KEY, _pinCodeController.text);

        // Upload profile image if changed
        if (_profileImage != null) {
          // TODO: Upload image to server and get URL
          // await UserConstants.updateField(UserConstants.PROFILE_IMAGE_KEY, imageUrl);
        }

        setState(() => _isLoading = false);
        _showSnackBar("Profile updated successfully!", isError: false);
        Navigator.pop(context, true); // Return true to indicate success
      } catch (e) {
        setState(() => _isLoading = false);
        _showSnackBar("Failed to update profile: ${e.toString()}", isError: true);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(title: 'Edit Profile'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Section
              Center(
                child: Stack(
                  children: [
            Container(
            decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryGold, width: 3.w),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGold.withOpacity(0.3),
                blurRadius: 12.r,
                spreadRadius: 2.r,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 60.r,
            backgroundColor: AppColors.border,

            // If local picked image exists → show FileImage
            // If network image exists → show NetworkImage
            // Else → show icon
            child: _profileImage == null && UserConstants.PROFILE_IMAGE.isEmpty
                ? Icon(
              Icons.person,
              size: 55.r,
              color: AppColors.primaryGold,
            )
                : null,

            backgroundImage: _profileImage != null
                ? FileImage(_profileImage!)
                : (UserConstants.PROFILE_IMAGE.isNotEmpty
                ? NetworkImage(UserConstants.PROFILE_IMAGE)
                : null),
          ),
        ),

        Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryGold,
                            border: Border.all(color: AppColors.screenBackground, width: 2.w),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8.r,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            backgroundColor: AppColors.primaryGold,
                            radius: 18.r,
                            child: Icon(Icons.camera_alt, color: AppColors.buttonText, size: 18.sp),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),

              // Personal Information Section
              _buildSectionHeader('Personal Information'),
              SizedBox(height: 12.h),

              // Full Name (Editable)
              _buildEditableField(
                label: "Full Name",
                hint: "Enter your full name",
                controller: _fullNameController,
                icon: Icons.person_outline,
                validator: (value) => value == null || value.isEmpty ? "Please enter your full name" : null,
              ),

              // Email (Read-only)
              _buildReadOnlyField(
                label: "Email",
                value: UserConstants.EMAIL,
                icon: Icons.email_outlined,
                isVerified: UserConstants.IS_EMAIL_VERIFIED ?? false,
              ),

              // Phone Number (Read-only)
              _buildReadOnlyField(
                label: "Phone Number",
                value: UserConstants.PHONE,
                icon: Icons.phone_outlined,
                isVerified: UserConstants.IS_MOBILE_VERIFIED ?? false,
              ),

              SizedBox(height: 24.h),

              // Address Information Section
              _buildSectionHeader('Address Information'),
              SizedBox(height: 12.h),

              // Address (Editable)
              _buildEditableField(
                label: "Address",
                hint: "Enter your address",
                controller: _addressController,
                icon: Icons.home_outlined,
                maxLines: 2,
              ),

              // City (Editable)
              _buildEditableField(
                label: "City",
                hint: "Enter your city",
                controller: _cityController,
                icon: Icons.location_city_outlined,
              ),

              // State (Editable)
              _buildEditableField(
                label: "State",
                hint: "Enter your state",
                controller: _stateController,
                icon: Icons.map_outlined,
              ),

              // PIN Code (Editable)
              _buildEditableField(
                label: "PIN Code",
                hint: "Enter PIN code",
                controller: _pinCodeController,
                icon: Icons.pin_drop_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length != 6) {
                    return "PIN code must be 6 digits";
                  }
                  return null;
                },
              ),

              SizedBox(height: 24.h),

              // KYC Status Section
              _buildSectionHeader('KYC Status'),
              SizedBox(height: 12.h),

              // Aadhaar Status (Read-only)
              _buildKYCStatusCard(
                label: "Aadhaar Verification",
                isVerified: UserConstants.IS_AADHAAR_VERIFIED ?? false,
                icon: Icons.credit_card,
              ),

              SizedBox(height: 12.h),

              // PAN Status (Read-only)
              _buildKYCStatusCard(
                label: "PAN Verification",
                isVerified: UserConstants.IS_PAN_VERIFIED ?? false,
                icon: Icons.account_balance_wallet_outlined,
                value: UserConstants.maskedPAN.isNotEmpty ? UserConstants.maskedPAN : null,
              ),

              SizedBox(height: 30.h),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.buttonText),
                    ),
                  )
                      : Text(
                    "Save Changes",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.buttonText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: AppColors.secondaryText, fontSize: 16.sp),
                  ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText,
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(color: AppColors.primaryText, fontSize: 15.sp),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.secondaryText.withOpacity(0.5), fontSize: 14.sp),
          prefixIcon: Icon(icon, color: AppColors.primaryGold, size: 22.sp),
          filled: true,
          fillColor: AppColors.cardBackground,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.primaryGold, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.error, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
    bool isVerified = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border.withOpacity(0.5), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.secondaryText, size: 22.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    value.isEmpty ? "Not provided" : value,
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (isVerified)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, color: AppColors.success, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'Verified',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.secondaryText.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'Locked',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildKYCStatusCard({
    required String label,
    required bool isVerified,
    required IconData icon,
    String? value,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isVerified
            ? AppColors.success.withOpacity(0.1)
            : AppColors.cardBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isVerified ? AppColors.success.withOpacity(0.3) : AppColors.border.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: isVerified
                  ? AppColors.success.withOpacity(0.2)
                  : AppColors.secondaryText.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: isVerified ? AppColors.success : AppColors.secondaryText,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (value != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    value,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isVerified
                  ? AppColors.success.withOpacity(0.2)
                  : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isVerified ? Icons.check_circle : Icons.cancel,
                  color: isVerified ? AppColors.success : AppColors.error,
                  size: 16.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  isVerified ? 'Verified' : 'Not Verified',
                  style: TextStyle(
                    color: isVerified ? AppColors.success : AppColors.error,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}