import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../models/course_models.dart';
import '../../service/apiservice/learn_service.dart';
import '../../widget/common_app_bar.dart';
import '../../utills/constent/user_constant.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  bool _isLoading = true;
  String _error = '';
  List<Certificate> _certificates = [];
  int _pendingRequests = 0;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await LearnService.getUserCertificates();
      if (response.status) {
        setState(() {
          _certificates = response.data.certificates;
          _pendingRequests = response.data.pendingRequests;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: CommonAppBar(title: 'My Certificates'),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60.sp, color: Colors.red.shade300),
            SizedBox(height: 16.h),
            Text(
              'Failed to load certificates',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0A1F3A),
              ),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: _loadCertificates,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_certificates.isEmpty && _pendingRequests == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              size: 80.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              'No Certificates Yet',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0A1F3A),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Complete courses to earn certificates',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCertificates,
      color: const Color(0xFFD4AF37),
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          if (_pendingRequests > 0) _buildPendingBanner(),
          ..._certificates.map((cert) => _buildCertificateCard(cert)),
        ],
      ),
    );
  }

  Widget _buildPendingBanner() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF9800).withOpacity(0.1),
            const Color(0xFFFF9800).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFFF9800).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_top,
                  color: const Color(0xFFFF9800),
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending Requests',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0A1F3A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '$_pendingRequests certificate(s) being processed',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  color: const Color(0xFFD4AF37),
                  size: 20.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'You will receive your certificate on your registered email within 24 hours.',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade700,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateCard(Certificate cert) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Certificate Preview
          Container(
            height: 140.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A1F3A), Color(0xFF1A3A5A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Stack(
              children: [
                // Decorative elements
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -20,
                  left: -20,
                  child: Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                // Certificate icon
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        size: 48.sp,
                        color: const Color(0xFFD4AF37),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Certificate of Completion',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: cert.isIssued
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF9800),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      cert.isIssued ? 'Issued' : 'Pending',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Certificate Details
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cert.courseName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0A1F3A),
                  ),
                ),
                SizedBox(height: 10.h),
                // Certificate Number
                if (cert.certificateNumber.isNotEmpty)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          size: 14.sp,
                          color: const Color(0xFFD4AF37),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          cert.certificateNumber,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0A1F3A),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 10.h),
                if (cert.issuedAt != null)
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Issued: ${_formatDate(cert.issuedAt!)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 12.h),
                // Temp Certificate Actions (always shown)
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E7),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16.sp,
                            color: const Color(0xFFD4AF37),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Download temp certificate now. Original will be sent to your email.',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _downloadTempCertificate(cert),
                              icon: Icon(Icons.download, size: 16.sp),
                              label: Text('Download',
                                  style: TextStyle(fontSize: 12.sp)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFD4AF37),
                                side:
                                    const BorderSide(color: Color(0xFFD4AF37)),
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _shareTempCertificate(cert),
                              icon: Icon(Icons.share, size: 16.sp),
                              label: Text('Share',
                                  style: TextStyle(fontSize: 12.sp)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4AF37),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  Future<File> _generateTempCertificatePdf(Certificate cert) async {
    final pdf = pw.Document();

    // Get user name from UserConstants
    final userName =
        UserConstants.NAME.isNotEmpty ? UserConstants.NAME : 'Learner';
    final issueDate = cert.issuedAt ?? DateTime.now();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
            ),
            child: pw.Stack(
              children: [
                // Background pattern - subtle grid
                pw.Positioned.fill(
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#FAFAFA'),
                    ),
                  ),
                ),

                // Outer decorative border
                pw.Positioned(
                  top: 15,
                  left: 15,
                  right: 15,
                  bottom: 15,
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        color: PdfColor.fromHex('#D4AF37'),
                        width: 2,
                      ),
                    ),
                  ),
                ),

                // Inner decorative border
                pw.Positioned(
                  top: 25,
                  left: 25,
                  right: 25,
                  bottom: 25,
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        color: PdfColor.fromHex('#0A1F3A'),
                        width: 1,
                      ),
                    ),
                  ),
                ),

                // Corner decorations - Top Left
                pw.Positioned(
                  top: 30,
                  left: 30,
                  child: _buildCornerDecoration(),
                ),

                // Corner decorations - Top Right
                pw.Positioned(
                  top: 30,
                  right: 30,
                  child: pw.Transform.rotate(
                    angle: 1.5708,
                    child: _buildCornerDecoration(),
                  ),
                ),

                // Corner decorations - Bottom Left
                pw.Positioned(
                  bottom: 30,
                  left: 30,
                  child: pw.Transform.rotate(
                    angle: -1.5708,
                    child: _buildCornerDecoration(),
                  ),
                ),

                // Corner decorations - Bottom Right
                pw.Positioned(
                  bottom: 30,
                  right: 30,
                  child: pw.Transform.rotate(
                    angle: 3.1416,
                    child: _buildCornerDecoration(),
                  ),
                ),

                // Watermark
                pw.Center(
                  child: pw.Transform.rotate(
                    angle: -0.2,
                    child: pw.Opacity(
                      opacity: 0.06,
                      child: pw.Text(
                        'TEMP',
                        style: pw.TextStyle(
                          fontSize: 180,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#D4AF37'),
                        ),
                      ),
                    ),
                  ),
                ),

                // Main content
                pw.Positioned(
                  top: 50,
                  left: 60,
                  right: 60,
                  bottom: 50,
                  child: pw.Column(
                    children: [
                      // Header with logo placeholder
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Container(
                            width: 50,
                            height: 50,
                            decoration: pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              color: PdfColor.fromHex('#0A1F3A'),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                'CC',
                                style: pw.TextStyle(
                                  fontSize: 20,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#D4AF37'),
                                ),
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 15),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'CLASSIA CAPITAL',
                                style: pw.TextStyle(
                                  fontSize: 26,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#0A1F3A'),
                                  letterSpacing: 4,
                                ),
                              ),
                              pw.Text(
                                'Excellence in Financial Education',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColor.fromHex('#666666'),
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      pw.SizedBox(height: 20),

                      // Gold divider
                      pw.Container(
                        width: 200,
                        child: pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Container(
                                  height: 1,
                                  color: PdfColor.fromHex('#D4AF37')),
                            ),
                            pw.Container(
                              margin:
                                  const pw.EdgeInsets.symmetric(horizontal: 10),
                              width: 10,
                              height: 10,
                              decoration: pw.BoxDecoration(
                                shape: pw.BoxShape.circle,
                                color: PdfColor.fromHex('#D4AF37'),
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Container(
                                  height: 1,
                                  color: PdfColor.fromHex('#D4AF37')),
                            ),
                          ],
                        ),
                      ),

                      pw.SizedBox(height: 15),

                      // Certificate title
                      pw.Text(
                        'CERTIFICATE',
                        style: pw.TextStyle(
                          fontSize: 36,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#D4AF37'),
                          letterSpacing: 8,
                        ),
                      ),
                      pw.Text(
                        'OF COMPLETION',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#0A1F3A'),
                          letterSpacing: 6,
                        ),
                      ),

                      pw.SizedBox(height: 20),

                      // Award text
                      pw.Text(
                        'This certificate is proudly presented to',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColor.fromHex('#666666'),
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),

                      pw.SizedBox(height: 12),

                      // User Name with underline
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 40, vertical: 8),
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(
                              color: PdfColor.fromHex('#D4AF37'),
                              width: 2,
                            ),
                          ),
                        ),
                        child: pw.Text(
                          userName.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 32,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#0A1F3A'),
                            letterSpacing: 2,
                          ),
                        ),
                      ),

                      pw.SizedBox(height: 15),

                      pw.Text(
                        'for successfully completing',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColor.fromHex('#666666'),
                        ),
                      ),

                      pw.SizedBox(height: 10),

                      // Course Name Box
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#0A1F3A'),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          cert.courseName,
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),

                      pw.Spacer(),

                      // Bottom section with certificate info
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                        children: [
                          // Issue Date
                          pw.Column(
                            children: [
                              pw.Container(
                                width: 120,
                                height: 1,
                                color: PdfColor.fromHex('#CCCCCC'),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                DateFormat('dd MMMM yyyy').format(issueDate),
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#0A1F3A'),
                                ),
                              ),
                              pw.Text(
                                'Date of Issue',
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  color: PdfColor.fromHex('#999999'),
                                ),
                              ),
                            ],
                          ),

                          // Seal placeholder
                          pw.Container(
                            width: 70,
                            height: 70,
                            decoration: pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              border: pw.Border.all(
                                color: PdfColor.fromHex('#D4AF37'),
                                width: 3,
                              ),
                            ),
                            child: pw.Center(
                              child: pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                children: [
                                  pw.Container(
                                    width: 30,
                                    height: 30,
                                    decoration: pw.BoxDecoration(
                                      shape: pw.BoxShape.circle,
                                      color: PdfColor.fromHex('#D4AF37'),
                                    ),
                                    child: pw.Center(
                                      child: pw.Text(
                                        'OK',
                                        style: pw.TextStyle(
                                          fontSize: 10,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  pw.SizedBox(height: 4),
                                  pw.Text(
                                    'VERIFIED',
                                    style: pw.TextStyle(
                                      fontSize: 6,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColor.fromHex('#0A1F3A'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Certificate ID
                          pw.Column(
                            children: [
                              pw.Container(
                                width: 120,
                                height: 1,
                                color: PdfColor.fromHex('#CCCCCC'),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                cert.certificateNumber.isNotEmpty
                                    ? cert.certificateNumber
                                    : 'TEMP-${cert.id}',
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#0A1F3A'),
                                ),
                              ),
                              pw.Text(
                                'Certificate ID',
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  color: PdfColor.fromHex('#999999'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      pw.SizedBox(height: 12),

                      // Temporary notice
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 15, vertical: 8),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#FFF8E7'),
                          borderRadius: pw.BorderRadius.circular(4),
                          border: pw.Border.all(
                            color: PdfColor.fromHex('#D4AF37'),
                            width: 0.5,
                          ),
                        ),
                        child: pw.Text(
                          'NOTE: This is a temporary certificate. Your official certificate will be emailed within 24 hours.',
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: PdfColor.fromHex('#666666'),
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/temp_certificate_${cert.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildCornerDecoration() {
    return pw.Container(
      width: 30,
      height: 30,
      child: pw.CustomPaint(
        painter: (canvas, size) {
          canvas
            ..setColor(PdfColor.fromHex('#D4AF37'))
            ..moveTo(0, 0)
            ..lineTo(30, 0)
            ..lineTo(30, 5)
            ..lineTo(5, 5)
            ..lineTo(5, 30)
            ..lineTo(0, 30)
            ..closePath()
            ..fillPath();
        },
      ),
    );
  }

  Future<void> _downloadTempCertificate(Certificate cert) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
      ),
    );

    try {
      final file = await _generateTempCertificatePdf(cert);
      Navigator.pop(context); // Close loading

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text('Certificate saved to: ${file.path}'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate certificate: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareTempCertificate(Certificate cert) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
      ),
    );

    try {
      final file = await _generateTempCertificatePdf(cert);
      Navigator.pop(context); // Close loading

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My ${cert.courseName} Certificate from Classia Capital! 🎓',
      );
    } catch (e) {
      Navigator.pop(context); // Close loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share certificate: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
