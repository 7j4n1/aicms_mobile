import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:aicms_mobile/theme/app_theme.dart';
import 'package:aicms_mobile/widgets/empty_state_widget.dart';
import 'package:aicms_mobile/widgets/shimmer_loading.dart';

class NewTicketScreen extends StatefulWidget {
  final String? ticketId;

  const NewTicketScreen({super.key, this.ticketId});

  @override
  State<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends State<NewTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();

  String _selectedPriority = 'Medium';
  List<PlatformFile> _attachments = [];
  bool _isLoading = false;
  bool _isSending = false;
  String _error = '';
  Map<String, dynamic>? _ticketData;
  List<dynamic> _messages = [];
  bool _isExpandedStatus = false;

  @override
  void initState() {
    super.initState();
    if (widget.ticketId != null) {
      _loadTicketDetails();
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _loadTicketDetails() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://your-api-base-url.com/api/support-tickets/${widget.ticketId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _ticketData = data;
          _messages = data['messages'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load ticket details. Please try again later.';
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

  Future<void> _createTicket() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSending = true;
      _error = '';
    });

    try {
      // Prepare request body
      final Map<String, dynamic> body = {
        'subject': _subjectController.text,
        'message': _messageController.text,
        'priority': _selectedPriority,
      };

      // Handle attachments if needed
      // This is a simplified version - in a real app, you would use multipart request
      if (_attachments.isNotEmpty) {
        body['attachments'] = _attachments.map((file) => file.name).toList();
      }

      final response = await http.post(
        Uri.parse('https://your-api-base-url.com/api/support-tickets'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        // Successfully created
        Navigator.pop(context);
      } else {
        setState(() {
          _error = 'Failed to create ticket. Please try again later.';
          _isSending = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred: $e';
        _isSending = false;
      });
    }
  }

  Future<void> _sendReply() async {
    if (_replyController.text.isEmpty) {
      return;
    }

    setState(() {
      _isSending = true;
      _error = '';
    });

    try {
      final Map<String, dynamic> body = {
        'message': _replyController.text,
      };

      final response = await http.post(
        Uri.parse('https://your-api-base-url.com/api/support-tickets/${widget.ticketId}/messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        _replyController.clear();
        _loadTicketDetails();
      } else {
        setState(() {
          _error = 'Failed to send message. Please try again later.';
          _isSending = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred: $e';
        _isSending = false;
      });
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _attachments = [..._attachments, ...result.files];
        });
      }
    } catch (e) {
      // Handle file picking error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting files: $e')),
      );
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
        return Colors.blue;
      case 'In Progress':
        return Colors.orange;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
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

  Widget _buildStatusHistory() {
    final List<dynamic> history = _ticketData?['statusHistory'] ?? [];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isExpandedStatus ? (history.length * 50.0) : 0,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          return ListTile(
            dense: true,
            leading: Icon(
              Icons.history,
              color: _getStatusColor(item['status']),
            ),
            title: Text(
              'Changed to ${item['status']}',
              style: const TextStyle(fontSize: 14),
            ),
            subtitle: Text(
              item['date'] != null
                  ? DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(item['date']))
                  : '',
              style: const TextStyle(fontSize: 12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewTicketForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _subjectController,
            decoration: const InputDecoration(
              labelText: 'Subject',
              hintText: 'Enter ticket subject',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a subject';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Priority',
            ),
            value: _selectedPriority,
            items: ['Low', 'Medium', 'High']
                .map((priority) => DropdownMenuItem(
                      value: priority,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getPriorityColor(priority),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(priority),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedPriority = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Message',
              hintText: 'Describe your issue',
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a message';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickFiles,
            icon: const Icon(Icons.attach_file),
            label: const Text('Attach Files'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
          if (_attachments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attachments:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      _attachments.length,
                      (index) => Chip(
                        label: Text(
                          _attachments[index].name,
                          style: const TextStyle(fontSize: 12),
                        ),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => _removeAttachment(index),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSending ? null : _createTicket,
            child: _isSending
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit Ticket'),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingTicketView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: EdgeInsets.zero,
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _ticketData?['subject'] ?? '',
                        style: AppTheme.heading1.copyWith(fontSize: 20),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(_ticketData?['status'] ?? '').withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getStatusColor(_ticketData?['status'] ?? '')),
                      ),
                      child: Text(
                        _ticketData?['status'] ?? '',
                        style: TextStyle(
                          color: _getStatusColor(_ticketData?['status'] ?? ''),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.flag,
                      size: 16,
                      color: _getPriorityColor(_ticketData?['priority'] ?? ''),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _ticketData?['priority'] ?? '',
                      style: TextStyle(
                        color: _getPriorityColor(_ticketData?['priority'] ?? ''),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      _ticketData?['createdAt'] != null
                          ? DateFormat('dd MMM yyyy').format(
                              DateTime.parse(_ticketData!['createdAt']),
                            )
                          : '',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                if (_ticketData?['statusHistory'] != null) ...[
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isExpandedStatus = !_isExpandedStatus;
                      });
                    },
                    child: Row(
                      children: [
                        const Text(
                          'Status History',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Icon(
                          _isExpandedStatus
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusHistory(),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _messages.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.chat_bubble_outline,
                  title: 'No Messages',
                  message: 'There are no messages in this ticket yet.',
                )
              : ListView.builder(
                  itemCount: _messages.length,
                  reverse: true,
                  padding: const EdgeInsets.only(bottom: 16),
                  itemBuilder: (context, index) {
                    final message = _messages[_messages.length - 1 - index];
                    final isUser = message['isUser'] ?? false;

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? AppTheme.primaryColor : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isUser ? 'You' : 'Support Agent',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isUser ? Colors.white : AppTheme.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  message['createdAt'] != null
                                      ? DateFormat('HH:mm').format(
                                          DateTime.parse(message['createdAt']),
                                        )
                                      : '',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isUser ? Colors.white70 : AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message['content'] ?? '',
                              style: TextStyle(
                                color: isUser ? Colors.white : AppTheme.textPrimary,
                              ),
                            ),
                            if (message['attachments'] != null &&
                                (message['attachments'] as List).isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: List.generate(
                                  (message['attachments'] as List).length,
                                  (attIndex) => InkWell(
                                    onTap: () {
                                      // Handle attachment viewing
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.attach_file, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            message['attachments'][attIndex]['name'] ?? 'File',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (_ticketData?['status'] != 'Resolved')
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: const InputDecoration(
                      hintText: 'Type a reply...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isSending ? null : _sendReply,
                  icon: _isSending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ticketId == null ? 'New Support Ticket' : 'Ticket Details'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading && widget.ticketId != null
              ? Column(
                  children: [
                    ShimmerLoading(height: 100),
                    const SizedBox(height: 16),
                    ShimmerLoading(height: 50),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: ShimmerLoading(height: 80),
                        ),
                      ),
                    ),
                  ],
                )
              : _error.isNotEmpty
                  ? EmptyStateWidget(
                      icon: Icons.error_outline,
                      title: 'Error',
                      message: _error,
                      buttonText: 'Try Again',
                      onButtonPressed: widget.ticketId != null ? _loadTicketDetails : null,
                    )
                  : widget.ticketId == null
                      ? _buildNewTicketForm()
                      : _buildExistingTicketView(),
        ),
      ),
    );
  }
}
