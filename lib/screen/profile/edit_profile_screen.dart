import 'dart:io';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/custom_app_bar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers for text fields
  final TextEditingController _fullNameController = TextEditingController(text: "${UserConstants.NAME}");
  final TextEditingController _emailController = TextEditingController(text: "${UserConstants.EMAIL}");
  final TextEditingController _phoneController = TextEditingController(text: "${UserConstants.PHONE}");

  File? _profileImage;

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
      // Handle any errors during image picking
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to pick image: ${e.toString()}"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
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
            SizedBox(height: 16.h),
            Text(
              'Select Image Source',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: Icon(
                Icons.camera_alt,
                color: AppColors.primaryGold,
                size: 24.sp,
              ),
              title: Text(
                'Camera',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 16.sp,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: AppColors.primaryGold,
                size: 24.sp,
              ),
              title: Text(
                'Gallery',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 16.sp,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            // Add option to remove current image
            if (_profileImage != null)
              ListTile(
                leading: Icon(
                  Icons.delete,
                  color: AppColors.error,
                  size: 24.sp,
                ),
                title: Text(
                  'Remove Image',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 16.sp,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _profileImage = null;
                  });
                },
              ),
            SizedBox(height: 16.h),
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

        // Here you would typically:
        // 1. Upload the image to your server if _profileImage is not null
        // 2. Update user profile with new data
        // 3. Update UserConstants with new values

        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Profile updated successfully!"),
            backgroundColor: AppColors.success,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update profile: ${e.toString()}"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fix the errors in the form"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
            children: [
              // Profile Image with enhanced styling
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryGold,
                        width: 3.w,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 60.r,
                      backgroundColor: AppColors.border,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : const AssetImage('assets/images/default_profile.png') as ImageProvider,
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
                          border: Border.all(
                            color: AppColors.screenBackground,
                            width: 2.w,
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundColor: AppColors.primaryGold,
                          radius: 20.r,
                          child: Icon(
                            Icons.camera_alt,
                            color: AppColors.buttonText,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Full Name
              _buildTextField(
                label: "Full Name",
                hint: "Enter your full name",
                controller: _fullNameController,
                validator: (value) => value == null || value.isEmpty ? "Please enter your full name" : null,
              ),

              // Email
              _buildTextField(
                label: "Email",
                hint: "Enter your email",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please enter your email";
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return "Please enter a valid email";
                  return null;
                },
              ),

              // Phone Number
              _buildTextField(
                label: "Phone Number",
                hint: "Enter your phone number",
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please enter your phone number";
                  if (value.length < 10) return "Phone number must be at least 10 digits";
                  return null;
                },
              ),

              SizedBox(height: 30.h),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  minimumSize: Size(double.infinity, 48.h),
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
                  "Save",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.buttonText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Cancel Button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
          filled: true,
          fillColor: AppColors.cardBackground,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.primaryGold),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.error),
          ),
        ),
        validator: validator,
        onTap: onTap,
      ),
    );
  }
}