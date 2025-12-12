import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../service/apiservice/support_service.dart';

import '../../../utills/themes/light_app_theme.dart';
import 'create_ticket_screen.dart';
import 'ticket_deatils_screen.dart';


class TicketListScreen extends StatefulWidget {
  const TicketListScreen({Key? key}) : super(key: key);

  @override
  _TicketListScreenState createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  final _supportService = SupportService();
  final _scrollController = ScrollController();

  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  final int _limit = 10;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTickets();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreTickets();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Support Tickets", style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        centerTitle: true,
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.plus, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateTicketScreen()),
            ).then((_) => _refreshTickets()),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _tickets.isEmpty
                ? _buildEmptyState()
                : _buildTicketList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FaIcon(FontAwesomeIcons.ticket, size: 20, color: Colors.white),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Support Tickets",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Track and manage your support requests",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search tickets...",
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
          prefixIcon: Padding(
            padding: EdgeInsets.all(16),
            child: FaIcon(FontAwesomeIcons.search, size: 16, color: Colors.grey[500]),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: FaIcon(FontAwesomeIcons.times, size: 16, color: Colors.grey[500]),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
              _refreshTickets();
            },
          )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          _debounceSearch();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.lightTheme.primaryColor),
          ),
          SizedBox(height: 16),
          Text(
            "Loading your tickets...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(50),
              ),
              child: FaIcon(FontAwesomeIcons.ticketAlt, size: 48, color: Colors.grey[400]),
            ),
            SizedBox(height: 24),
            Text(
              "No Support Tickets",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              "You haven't created any support tickets yet. Tap the + button to create your first ticket.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateTicketScreen()),
              ).then((_) => _refreshTickets()),
              icon: FaIcon(FontAwesomeIcons.plus, size: 16),
              label: Text("Create Ticket"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketList() {
    final filteredTickets = _searchQuery.isEmpty
        ? _tickets
        : _tickets
        .where((ticket) =>
    ticket['title']?.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
        ticket['lastMessage']?.toLowerCase().contains(_searchQuery.toLowerCase()) == true)
        .toList();

    return RefreshIndicator(
      onRefresh: _refreshTickets,
      color: AppTheme.lightTheme.primaryColor,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredTickets.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filteredTickets.length) {
            return _buildLoadingMoreIndicator();
          }

          final ticket = filteredTickets[index];
          return _buildTicketCard(ticket);
        },
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    final status = ticket['status'] ?? 'OPEN';
    final title = ticket['title'] ?? 'No Title';
    final lastMessage = ticket['lastMessage'] ?? 'No Message';
    final messageCount = ticket['messageCount'] ?? 1;
    final createdAt = ticket['created_at'] ?? '';
    final ticketId = ticket['id'] ?? 0;
    final priority = ticket['priority'] ?? 'MEDIUM';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TicketDetailsScreen(
              ticketId: ticketId,
              ticket: ticket,
            ),
          ),
        ).then((_) => _refreshTickets());
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
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
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatusBadge(status),
                  Spacer(),
                  Text(
                    "#$ticketId",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  if (messageCount > 1)
                    Container(
                      margin: EdgeInsets.only(right: 8),
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.comments,
                            size: 10,
                            color: AppTheme.lightTheme.primaryColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '$messageCount',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.lightTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Text(
                      lastMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  FaIcon(FontAwesomeIcons.clock, size: 12, color: Colors.grey[400]),
                  SizedBox(width: 4),
                  Text(
                    _formatDate(createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  Spacer(),
                  _buildPriorityIndicator(priority),
                ],
              ),
            ],
          ),
        ),
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
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange[700]!;
        icon = FontAwesomeIcons.clock;
        break;
      case 'IN_PROGRESS':
      case 'IN PROGRESS':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue[700]!;
        icon = FontAwesomeIcons.cog;
        break;
      case 'RESOLVED':
      case 'CLOSED':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green[700]!;
        icon = FontAwesomeIcons.check;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey[700]!;
        icon = FontAwesomeIcons.questionCircle;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 10, color: textColor),
          SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
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

    switch (priority.toUpperCase()) {
      case 'HIGH':
        color = Colors.red;
        break;
      case 'MEDIUM':
        color = Colors.orange;
        break;
      case 'LOW':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 4),
        Text(
          priority.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: EdgeInsets.all(16),
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.lightTheme.primaryColor),
      ),
    );
  }

  String _extractLastMessage(dynamic messageData) {
    if (messageData == null) return 'No Message';

    // Handle array of messages
    if (messageData is List) {
      if (messageData.isEmpty) return 'No Message';

      // Get the last message
      final lastMsg = messageData.last;
      if (lastMsg is Map && lastMsg['text'] != null) {
        return lastMsg['text'].toString();
      }
      return 'No Message';
    }

    // Handle single message object
    if (messageData is Map && messageData['text'] != null) {
      return messageData['text'].toString();
    }

    // Handle string
    if (messageData is String) {
      return messageData;
    }

    return 'No Message';
  }

  int _getMessageCount(dynamic messageData) {
    if (messageData == null) return 0;

    if (messageData is List) {
      return messageData.length;
    }

    return 1;
  }

  Future<void> _loadTickets() async {
    try {
      final response = await _supportService.getSupportTicketList(
        page: _currentPage,
        limit: _limit,
      );

      if (response != null && response['data'] != null) {
        final ticketData = response['data']['tickets'] as List<dynamic>;

        final formattedTickets = ticketData.map((ticket) {
          final messageData = ticket['message'];

          return {
            'id': ticket['ID'],
            'title': ticket['title'],
            'lastMessage': _extractLastMessage(messageData),
            'messageCount': _getMessageCount(messageData),
            'messages': messageData, // Store full messages array
            'status': ticket['status'],
            'priority': ticket['priority'],
            'category': ticket['category'],
            'created_at': ticket['CreatedAt'],
            'updated_at': ticket['UpdatedAt'],
          };
        }).toList();

        setState(() {
          _tickets = List<Map<String, dynamic>>.from(formattedTickets);
          _hasMoreData = _tickets.length >= _limit;
          _isLoading = false;
        });
      } else {
        setState(() {
          _tickets = [];
          _hasMoreData = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading tickets: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar("Failed to load tickets. Please try again.");
    }
  }

  Future<void> _loadMoreTickets() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await _supportService.getSupportTicketList(
        page: _currentPage + 1,
        limit: _limit,
      );

      if (response != null && response['data'] != null) {
        final ticketData = response['data']['tickets'] as List<dynamic>;

        final newTickets = ticketData.map((ticket) {
          final messageData = ticket['message'];

          return {
            'id': ticket['ID'],
            'title': ticket['title'],
            'lastMessage': _extractLastMessage(messageData),
            'messageCount': _getMessageCount(messageData),
            'messages': messageData,
            'status': ticket['status'],
            'priority': ticket['priority'],
            'category': ticket['category'],
            'created_at': ticket['CreatedAt'],
            'updated_at': ticket['UpdatedAt'],
          };
        }).toList();

        setState(() {
          _tickets.addAll(newTickets);
          _currentPage++;
          _hasMoreData = newTickets.length >= _limit;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _hasMoreData = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      print('Error loading more tickets: $e');
      setState(() {
        _isLoadingMore = false;
      });
      _showErrorSnackBar("Failed to load more tickets.");
    }
  }

  Future<void> _refreshTickets() async {
    setState(() {
      _currentPage = 1;
      _hasMoreData = true;
      _isLoading = true;
      _tickets.clear();
    });

    await _loadTickets();
  }

  void _debounceSearch() {
    Future.delayed(Duration(milliseconds: 500), () {
      if (_searchController.text == _searchQuery) {
        setState(() {});
      }
    });
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}