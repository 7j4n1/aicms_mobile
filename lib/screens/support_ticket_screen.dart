import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'new_ticket_screen.dart';

class SupportTicketScreen extends StatefulWidget {
  const SupportTicketScreen({super.key});

  @override
  State<SupportTicketScreen> createState() => _SupportTicketScreenState();
}

class _SupportTicketScreenState extends State<SupportTicketScreen> {
  List<dynamic> _tickets = [];
  bool _isLoading = true;
  String _error = '';
  String _searchQuery = '';
  String _filterStatus = 'All';
  String _filterPriority = 'All';

  final List<String> _statusOptions = ['All', 'Open', 'In Progress', 'Resolved'];
  final List<String> _priorityOptions = ['All', 'High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://your-api-base-url.com/api/support-tickets'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _tickets = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load tickets. Please try again later.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _filteredTickets {
    return _tickets.where((ticket) {
      // Apply search query
      final matchesSearch = _searchQuery.isEmpty ||
          ticket['subject'].toLowerCase().contains(_searchQuery.toLowerCase());

      // Apply status filter
      final matchesStatus = _filterStatus == 'All' || ticket['status'] == _filterStatus;

      // Apply priority filter
      final matchesPriority = _filterPriority == 'All' || ticket['priority'] == _filterPriority;

      return matchesSearch && matchesStatus && matchesPriority;
    }).toList();
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusIndicator(String status) {
    Color color;
    switch (status) {
      case 'Open':
        color = Colors.blue;
        break;
      case 'In Progress':
        color = Colors.orange;
        break;
      case 'Resolved':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Tickets'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search tickets...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    ),
                    value: _filterStatus,
                    items: _statusOptions
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _filterStatus = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    ),
                    value: _filterPriority,
                    items: _priorityOptions
                        .map((priority) => DropdownMenuItem(
                              value: priority,
                              child: Text(priority),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _filterPriority = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchTickets,
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      )
                    : _filteredTickets.isEmpty
                        ? const Center(
                            child: Text('No tickets found'),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchTickets,
                            child: ListView.builder(
                              itemCount: _filteredTickets.length,
                              padding: const EdgeInsets.all(16),
                              itemBuilder: (context, index) {
                                final ticket = _filteredTickets[index];
                                return AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  transform: Matrix4.translationValues(
                                      0, index * 10.0 * (1.0 - 1.0), 0.0),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: _getPriorityColor(ticket['priority']),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => NewTicketScreen(
                                              ticketId: ticket['id'],
                                            ),
                                          ),
                                        ).then((_) => _fetchTickets());
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    ticket['subject'],
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                _buildStatusIndicator(ticket['status']),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              ticket['message'] ?? '',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(color: Colors.grey[600]),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.flag,
                                                      size: 16,
                                                      color: _getPriorityColor(ticket['priority']),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      ticket['priority'],
                                                      style: TextStyle(
                                                        color: _getPriorityColor(ticket['priority']),
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  ticket['createdAt'] != null
                                                      ? '${DateTime.parse(ticket['createdAt']).day}/${DateTime.parse(ticket['createdAt']).month}/${DateTime.parse(ticket['createdAt']).year}'
                                                      : 'Unknown date',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
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
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewTicketScreen(),
            ),
          ).then((_) => _fetchTickets());
        },
        icon: const Icon(Icons.add),
        label: const Text('New Ticket'),
      ),
    );
  }
}
