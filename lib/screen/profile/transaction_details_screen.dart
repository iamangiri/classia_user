import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/common_app_bar.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailsScreen({Key? key, required this.transaction}) : super(key: key);

  @override
  _TransactionDetailsScreenState createState() => _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  bool _isGeneratingPDF = false;

  String get _transactionType => widget.transaction['transactionType']?.toString().toUpperCase() ?? '';
  bool get _isDeposit => _transactionType == 'DEPOSIT';
  double get _amount => double.tryParse(widget.transaction['amount']?.toString() ?? '0') ?? 0.0;

  DateTime get _transactionDate {
    try {
      final dateStr = widget.transaction['createdAt'];
      return dateStr != null ? DateTime.parse(dateStr) : DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  String get _paymentId {
    final transactionData = widget.transaction['transactionData'];
    if (transactionData != null && transactionData is Map<String, dynamic>) {
      return transactionData['paymentId']?.toString() ?? 'N/A';
    }
    return 'N/A';
  }

  String get _paymentMethod {
    final transactionData = widget.transaction['transactionData'];
    if (transactionData != null && transactionData is Map<String, dynamic>) {
      return transactionData['method']?.toString() ?? 'WALLET';
    }
    return 'WALLET';
  }

  String get _transactionId => widget.transaction['id']?.toString() ?? 'N/A';

  Future<void> _generateAndDownloadInvoice() async {
    setState(() {
      _isGeneratingPDF = true;
    });

    try {
      final pdf = await _createInvoicePDF();

      // Save PDF to device
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/invoice_${_transactionId}.pdf');
      await file.writeAsBytes(await pdf.save());

      // Share or print the PDF
      await _showPdfOptions(file.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invoice generated successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate invoice: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isGeneratingPDF = false;
      });
    }
  }

  Future<void> _showPdfOptions(String filePath) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Invoice Generated',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: Icon(Icons.share, color: AppColors.primaryGold),
              title: Text('Share Invoice', style: TextStyle(color: AppColors.primaryText)),
              onTap: () async {
                Navigator.pop(context);
                await Share.shareXFiles([XFile(filePath)], text: 'Transaction Invoice');
              },
            ),
            ListTile(
              leading: Icon(Icons.print, color: AppColors.primaryGold),
              title: Text('Print Invoice', style: TextStyle(color: AppColors.primaryText)),
              onTap: () async {
                Navigator.pop(context);
                await Printing.layoutPdf(
                  onLayout: (format) async => await File(filePath).readAsBytes(),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.download, color: AppColors.primaryGold),
              title: Text('Save to Downloads', style: TextStyle(color: AppColors.primaryText)),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final downloadsDir = Directory('/storage/emulated/0/Download');
                  if (!await downloadsDir.exists()) {
                    await downloadsDir.create(recursive: true);
                  }
                  final newFile = File('${downloadsDir.path}/Classia_Invoice_${_transactionId}.pdf');
                  await File(filePath).copy(newFile.path);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Invoice saved to Downloads folder'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to save: ${e.toString()}'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<pw.Document> _createInvoicePDF() async {
    final pdf = pw.Document();

    // Load logo
    final Uint8List? logoData = await _loadLogo();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with logo and company info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Company Logo and Name
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'MFD Classia Capital',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Private Limited',
                        style: pw.TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  // Invoice Type
                  pw.Container(
                    padding: pw.EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: pw.BoxDecoration(
                      color: _isDeposit ? PdfColors.green50 : PdfColors.red50,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(
                        color: _isDeposit ? PdfColors.green : PdfColors.red,
                        width: 2,
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          _isDeposit ? 'PAYMENT RECEIPT' : 'DEBIT RECEIPT',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: _isDeposit ? PdfColors.green900 : PdfColors.red900,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          DateFormat('dd MMM yyyy').format(_transactionDate),
                          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 24),
              pw.Divider(color: PdfColors.grey300, thickness: 2),
              pw.SizedBox(height: 24),

              // Company Address and Contact
              pw.Container(
                padding: pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Company Details',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    _buildInfoRow('Address:', '58, 2nd Cross Rd, Chowdiah Block, Mannarayanapalya'),
                    _buildInfoRow('', 'Chamundi Nagar, RT Nagar, Bengaluru, Karnataka 560032'),
                    _buildInfoRow('Email:', 'support@classiacapital.com'),
                    _buildInfoRow('Phone:', '+91 98869 88679'),
                    _buildInfoRow('Website:', 'www.classiacapital.com'),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              // Transaction Details
              pw.Text(
                'Transaction Details',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),

              // Transaction table
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    _buildDetailRow('Transaction ID:', _transactionId, isHeader: true),
                    _buildDetailRow('Transaction Type:', _isDeposit ? 'Wallet Deposit' : 'Basket Subscription'),
                    _buildDetailRow('Payment Method:', _paymentMethod.toUpperCase()),
                    if (_paymentId != 'N/A' && _paymentId != 'null')
                      _buildDetailRow('Payment ID:', _paymentId),
                    _buildDetailRow('Transaction Date:', DateFormat('dd MMM yyyy, hh:mm a').format(_transactionDate)),
                    _buildDetailRow('Status:', 'COMPLETED', highlight: true),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              // Amount Section
              pw.Container(
                padding: pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [
                      _isDeposit ? PdfColors.green50 : PdfColors.red50,
                      PdfColors.white,
                    ],
                  ),
                  borderRadius: pw.BorderRadius.circular(12),
                  border: pw.Border.all(
                    color: _isDeposit ? PdfColors.green : PdfColors.red,
                    width: 2,
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Transaction Amount',
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          _isDeposit ? 'Amount Credited' : 'Amount Debited',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey600,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      '${_isDeposit ? '+' : '-'} ${_amount.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: _isDeposit ? PdfColors.green900 : PdfColors.red900,
                      ),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Footer
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Thank you for investing with Classia Capital',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Your Trusted Investment Partner',
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.amber700,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'SEBI Registered',
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Generated on: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
                        style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.amber50,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  'This is a computer-generated receipt and does not require a signature. '
                      'For queries, please contact support@classiacapital.com',
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          if (label.isNotEmpty)
            pw.SizedBox(
              width: 60,
              child: pw.Text(
                label,
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
            ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDetailRow(String label, String value, {bool isHeader = false, bool highlight = false}) {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: pw.BoxDecoration(
        color: isHeader
            ? PdfColors.amber50
            : highlight
            ? PdfColors.green50
            : null,
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: isHeader || highlight ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: PdfColors.grey800,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: isHeader || highlight ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: highlight ? PdfColors.green900 : PdfColors.grey900,
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List?> _loadLogo() async {
    try {
      final ByteData data = await rootBundle.load('assets/logo/logo.jpg');
      return data.buffer.asUint8List();
    } catch (e) {
      print('Failed to load logo: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(title: 'Transaction Details'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction Status Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isDeposit
                      ? [Colors.green.shade400, Colors.green.shade600]
                      : [Colors.red.shade400, Colors.red.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: (_isDeposit ? Colors.green : Colors.red).withOpacity(0.3),
                    blurRadius: 12.r,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    _isDeposit ? Icons.check_circle : Icons.remove_circle,
                    color: Colors.white,
                    size: 60.sp,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    _isDeposit ? 'Money Added' : 'Money Debited',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${_isDeposit ? '+' : '-'}₹${_amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'COMPLETED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Transaction Details Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10.r,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction Details',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildDetailItem('Transaction ID', _transactionId),
                  _buildDetailItem('Type', _isDeposit ? 'Wallet Deposit' : 'Basket Subscription'),
                  _buildDetailItem('Payment Method', _paymentMethod.toUpperCase()),
                  if (_paymentId != 'N/A' && _paymentId != 'null')
                    _buildDetailItem('Payment ID', _paymentId),
                  _buildDetailItem(
                    'Date & Time',
                    DateFormat('dd MMM yyyy, hh:mm a').format(_transactionDate),
                  ),
                  _buildDetailItem('Amount', '₹${_amount.toStringAsFixed(2)}', isAmount: true),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Download Invoice Button
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton.icon(
                onPressed: _isGeneratingPDF ? null : _generateAndDownloadInvoice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                icon: _isGeneratingPDF
                    ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Icon(Icons.download, color: Colors.white, size: 24.sp),
                label: Text(
                  _isGeneratingPDF ? 'Generating Invoice...' : 'Download Invoice',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Info Card
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.primaryGold.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primaryGold,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'You can download, share, or print this invoice for your records.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.primaryText,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.secondaryText,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isAmount ? 18.sp : 14.sp,
              fontWeight: isAmount ? FontWeight.bold : FontWeight.w600,
              color: isAmount ? AppColors.primaryGold : AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}