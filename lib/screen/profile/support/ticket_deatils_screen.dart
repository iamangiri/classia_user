import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../service/apiservice/support_service.dart';
import '../../../utills/themes/light_app_theme.dart';


class TicketDetailsScreen extends StatefulWidget {
  final int ticketId;
  final Map<String, dynamic> ticket;

  const TicketDetailsScreen({
    Key? key,
    required this.ticketId,
    required this.ticket,
  }) : super(key: key);

  @override
  _TicketDetailsScreenState createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  final _supportService = SupportService();
  final _replyController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isLoadingReply = false;
  bool _isClosing = false;
  bool _isRefreshing = false;
  late Map<String, dynamic> _ticketData;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _ticketData = widget.ticket;
    _extractMessages();
  }

  void _extractMessages() {
    final messageData = _ticketData['messages'];

    if (messageData == null) {
      _messages = [];
      return;
    }

    if (messageData is List) {
      _messages = messageData.map((msg) {
        if (msg is Map) {
          return {
            'text': msg['text']?.toString() ?? '',
            'sender': msg['sender']?.toString() ?? 'user',
            'time': msg['time']?.toString() ?? '',
          };
        }
        return {'text': '', 'sender': 'user', 'time': ''};
      }).toList();
    } else if (messageData is Map) {
      _messages = [
        {
          'text': messageData['text']?.toString() ?? '',
          'sender': messageData['sender']?.toString() ?? 'user',
          'time': messageData['time']?.toString() ?? '',
        }
      ];
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = _ticketData['status'] ?? 'OPEN';
    final isClosed = status.toUpperCase() == 'CLOSED' || status.toUpperCase() == 'RESOLVED';

    return Scaffold(
      appBar: AppBar(
        title: Text("Ticket #${widget.ticketId}", style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        centerTitle: true,
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.sync, color: Colors.white, size: 18),
            onPressed: _refreshTicketData,
            tooltip: 'Refresh',
          ),
          if (!isClosed)
            PopupMenuButton<String>(
              icon: FaIcon(FontAwesomeIcons.ellipsisV, color: Colors.white),
              onSelected: (value) {
                if (value == 'close') {
                  _showCloseTicketDialog();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'close',
                  child: Row(
                    children: [
                      FaIcon(FontAwesomeIcons.times, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Close Ticket'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshTicketData,
              color: AppTheme.lightTheme.primaryColor,
              child: _buildTicketContent(),
            ),
          ),
          if (!isClosed) _buildReplySection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final status = _ticketData['status'] ?? 'OPEN';
    final priority = _ticketData['priority'] ?? 'MEDIUM';
    final category = _ticketData['category'] ?? 'GENERAL';
    final createdAt = _ticketData['created_at'] ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatusBadge(status),
              Spacer(),
              _buildPriorityIndicator(priority),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(FontAwesomeIcons.tag, size: 14, color: Colors.white),
              ),
              SizedBox(width: 8),
              Text(
                category,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              FaIcon(FontAwesomeIcons.clock, size: 12, color: Colors.white.withOpacity(0.8)),
              SizedBox(width: 6),
              Text(
                _formatDate(createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketContent() {
    final title = _ticketData['title'] ?? 'No Title';

    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            icon: FontAwesomeIcons.heading,
            title: 'Subject',
            content: title,
          ),
          SizedBox(height: 16),
          _buildConversationSection(),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(icon, size: 16, color: AppTheme.lightTheme.primaryColor),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FaIcon(FontAwesomeIcons.comments, size: 16, color: Colors.blue),
                ),
                SizedBox(width: 12),
                Text(
                  'Conversation',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_messages.length} ${_messages.length == 1 ? 'message' : 'messages'}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          if (_messages.isEmpty)
            Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No messages yet',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _messages.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message, index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, int index) {
    final text = message['text'] ?? '';
    final sender = message['sender'] ?? 'user';
    final time = message['time'] ?? '';
    final isUser = sender.toLowerCase() == 'user';

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: FaIcon(FontAwesomeIcons.headset, size: 12, color: Colors.blue),
                ),
                SizedBox(width: 8),
              ],
              Text(
                isUser ? 'You' : 'Support Team',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isUser ? AppTheme.lightTheme.primaryColor : Colors.blue[700],
                ),
              ),
              if (isUser) ...[
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.user,
                    size: 12,
                    color: AppTheme.lightTheme.primaryColor,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 8),
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser
                  ? AppTheme.lightTheme.primaryColor.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUser
                    ? AppTheme.lightTheme.primaryColor.withOpacity(0.3)
                    : Colors.blue.withOpacity(0.2),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            _formatMessageTime(time),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplySection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _replyController,
                decoration: InputDecoration(
                  hintText: "Type your reply...",
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),
          SizedBox(width: 12),
          GestureDetector(
            onTap: _isLoadingReply ? null : _sendReply,
            child: Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isLoadingReply
                    ? Colors.grey
                    : AppTheme.lightTheme.primaryColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: _isLoadingReply
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : FaIcon(FontAwesomeIcons.paperPlane, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toUpperCase()) {
      case 'OPEN':
      case 'PENDING':
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange[700]!;
        icon = FontAwesomeIcons.clock;
        break;
      case 'IN_PROGRESS':
      case 'IN PROGRESS':
        backgroundColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue[700]!;
        icon = FontAwesomeIcons.cog;
        break;
      case 'RESOLVED':
      case 'CLOSED':
        backgroundColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green[700]!;
        icon = FontAwesomeIcons.check;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey[700]!;
        icon = FontAwesomeIcons.questionCircle;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 12, color: textColor),
          SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityIndicator(String priority) {
    Color color;
    IconData icon;

    switch (priority.toUpperCase()) {
      case 'HIGH':
        color = Colors.red;
        icon = FontAwesomeIcons.exclamationCircle;
        break;
      case 'MEDIUM':
        color = Colors.orange;
        icon = FontAwesomeIcons.exclamationTriangle;
        break;
      case 'LOW':
        color = Colors.green;
        icon = FontAwesomeIcons.infoCircle;
        break;
      default:
        color = Colors.grey;
        icon = FontAwesomeIcons.minus;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 10, color: color),
          SizedBox(width: 6),
          Text(
            priority.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendReply() async {
    final replyText = _replyController.text.trim();

    if (replyText.isEmpty) {
      _showSnackBar("Please enter a message", isError: true);
      return;
    }

    setState(() {
      _isLoadingReply = true;
    });

    try {
      final response = await _supportService.replyToTicket(
        widget.ticketId,
        replyText,
      );

      if (response != null && response['status'] == true) {
        // Get updated ticket data from response
        final updatedTicketData = response['data'];

        if (updatedTicketData != null) {
          setState(() {
            _ticketData = {
              'id': updatedTicketData['ID'],
              'title': updatedTicketData['title'],
              'messages': updatedTicketData['message'],
              'status': updatedTicketData['status'],
              'priority': updatedTicketData['priority'],
              'category': updatedTicketData['category'],
              'created_at': updatedTicketData['CreatedAt'],
              'updated_at': updatedTicketData['UpdatedAt'],
            };
            _extractMessages();
          });
        }

        _replyController.clear();
        _showSnackBar("Reply sent successfully!");
        FocusScope.of(context).unfocus();

        // Scroll to bottom
        Future.delayed(Duration(milliseconds: 300), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        _showSnackBar("Failed to send reply. Please try again.", isError: true);
      }
    } catch (e) {
      print('Error sending reply: $e');
      _showSnackBar("An error occurred. Please try again.", isError: true);
    } finally {
      setState(() {
        _isLoadingReply = false;
      });
    }
  }

  Future<void> _refreshTicketData() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      // Fetch updated ticket list to get latest data
      final response = await _supportService.getSupportTicketList(
        page: 1,
        limit: 100,
      );

      if (response != null && response['data'] != null) {
        final ticketData = response['data']['tickets'] as List<dynamic>;

        // Find current ticket in the list
        final updatedTicket = ticketData.firstWhere(
              (ticket) => ticket['ID'] == widget.ticketId,
          orElse: () => null,
        );

        if (updatedTicket != null) {
          final messageData = updatedTicket['message'];

          setState(() {
            _ticketData = {
              'id': updatedTicket['ID'],
              'title': updatedTicket['title'],
              'messages': messageData,
              'status': updatedTicket['status'],
              'priority': updatedTicket['priority'],
              'category': updatedTicket['category'],
              'created_at': updatedTicket['CreatedAt'],
              'updated_at': updatedTicket['UpdatedAt'],
            };
            _extractMessages();
          });

          _showSnackBar("Ticket refreshed successfully!");
        } else {
          _showSnackBar("Could not find ticket", isError: true);
        }
      } else {
        _showSnackBar("Failed to refresh ticket", isError: true);
      }
    } catch (e) {
      print('Error refreshing ticket data: $e');
      _showSnackBar("An error occurred while refreshing", isError: true);
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _showCloseTicketDialog() {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            FaIcon(FontAwesomeIcons.times, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text("Close Ticket"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to close this ticket? Please provide a reason:",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: "Reason for closing...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.all(12),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final message = messageController.text.trim();
              if (message.isEmpty) {
                _showSnackBar("Please provide a reason", isError: true);
                return;
              }

              Navigator.pop(context);
              await _closeTicket(message);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text("Close Ticket"),
          ),
        ],
      ),
    );
  }

  Future<void> _closeTicket(String message) async {
    setState(() {
      _isClosing = true;
    });

    try {
      final success = await _supportService.closeTicket(
        widget.ticketId,
        message,
      );

      if (success) {
        _showSuccessDialog();
      } else {
        _showSnackBar("Failed to close ticket. Please try again.", isError: true);
      }
    } catch (e) {
      _showSnackBar("An error occurred. Please try again.", isError: true);
    } finally {
      setState(() {
        _isClosing = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: FaIcon(FontAwesomeIcons.check, color: Colors.green, size: 32),
            ),
            SizedBox(height: 16),
            Text(
              "Ticket Closed Successfully",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              "This ticket has been closed. Thank you for using our support service.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              "OK",
              style: TextStyle(
                color: AppTheme.lightTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'Unknown';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateString;
    }
  }

  String _formatMessageTime(String dateString) {
    if (dateString.isEmpty) return '';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }
}