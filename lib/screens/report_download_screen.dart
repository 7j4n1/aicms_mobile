import 'package:aicms_mobile/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportDownloadScreen extends StatefulWidget {
  const ReportDownloadScreen({super.key});

  @override
  State<ReportDownloadScreen> createState() => ReportDownloadScreenState();
}

class ReportDownloadScreenState extends State<ReportDownloadScreen> {
  // Form state
  String _selectedReportType = 'shares'; // Default selected
  String _selectedFormat = 'pdf'; // Default format
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  
  // Download state
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _errorMessage;
  
  // List of recent downloads (optional feature)
  final List<Map<String, dynamic>> _recentDownloads = [];

  // Report type options
  final List<Map<String, String>> _reportTypes = [
    {'value': 'savings', 'label': 'Savings'},
    {'value': 'shares', 'label': 'Shares'},
    {'value': 'loans', 'label': 'Loan Repayments'},
  ];

  // Format options
  final List<Map<String, String>> _formatOptions = [
    {'value': 'pdf', 'label': 'PDF'},
    {'value': 'excel', 'label': 'Excel'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DOWNLOAD REPORTS',
                style: AppTheme.heading2,
              ),
              const SizedBox(height: 24),
              
              // Report Type Selection
              Text(
                'SELECT REPORT TYPE',
                style: AppTheme.subtitle,
              ),
              const SizedBox(height: 8),
              _buildReportTypeSelection(),
              const SizedBox(height: 24),
              
              // Date Range Selection
              Text(
                'SELECT DATE RANGE',
                style: AppTheme.subtitle,
              ),
              const SizedBox(height: 8),
              _buildDateRangeSelection(),
              const SizedBox(height: 24),
              
              // Format Selection
              Text(
                'SELECT FORMAT',
                style: AppTheme.subtitle,
              ),
              const SizedBox(height: 8),
              _buildFormatSelection(),
              const SizedBox(height: 32),
              
              // Download Button
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ElevatedButton(
                    onPressed: _isDownloading ? null : _downloadReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.buttonPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isDownloading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2.0,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'DOWNLOADING... ${(_downloadProgress * 100).toInt()}%',
                                style: AppTheme.subtitle.copyWith(color: Colors.white),
                              ),
                            ],
                          )
                        : Text(
                            'DOWNLOAD REPORT',
                            style: AppTheme.subtitle.copyWith(color: Colors.white),
                          ),
                  ),
                ),
              ),
              
              // Error Message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.error),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: AppTheme.bodyText.copyWith(color: AppTheme.error),
                    ),
                  ),
                ),
              
              // Recent Downloads (Optional)
              if (_recentDownloads.isNotEmpty) ...[
                const SizedBox(height: 32),
                Text(
                  'RECENT DOWNLOADS',
                  style: AppTheme.subtitle,
                ),
                const SizedBox(height: 8),
                ..._recentDownloads.map((download) => _buildDownloadHistoryItem(download)),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacementNamed('/dashboard');
              break;
            case 1:
              Navigator.of(context).pushReplacementNamed('/records');
              break;
            case 2:
              // Navigator.of(context).pushReplacementNamed('/reports');
              break;
            case 3:
              Navigator.of(context).pushReplacementNamed('/more');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }

  Widget _buildReportTypeSelection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: _reportTypes.map((type) {
          return RadioListTile<String>(
            title: Text(type['label']!),
            value: type['value']!,
            groupValue: _selectedReportType,
            onChanged: (value) {
              setState(() {
                _selectedReportType = value!;
              });
            },
            activeColor: AppTheme.primaryColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            dense: true,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateRangeSelection() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Column(
      children: [
        // From Date
        GestureDetector(
          onTap: () => _selectDate(true),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: AppTheme.cardShadow,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                const Text('From: '),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(_startDate),
                  style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.primaryColor),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // To Date
        GestureDetector(
          onTap: () => _selectDate(false),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: AppTheme.cardShadow,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                const Text('To:   '),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(_endDate),
                  style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.primaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormatSelection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: _formatOptions.map((format) {
          return RadioListTile<String>(
            title: Text(format['label']!),
            value: format['value']!,
            groupValue: _selectedFormat,
            onChanged: (value) {
              setState(() {
                _selectedFormat = value!;
              });
            },
            activeColor: AppTheme.primaryColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            dense: true,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDownloadHistoryItem(Map<String, dynamic> download) {
    final IconData formatIcon = download['format'] == 'pdf' ? Icons.picture_as_pdf : Icons.table_chart;
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(formatIcon, color: AppTheme.primaryColor),
      ),
      title: Text(
        '${download['type']} Report',
        style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${download['date']}',
        style: AppTheme.caption,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.download_rounded),
        onPressed: () {
          // Re-download functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Re-downloading report...')),
          );
        },
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Ensure end date is not before start date
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          // Ensure start date is not after end date
          if (_startDate.isAfter(_endDate)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  Future<void> _downloadReport() async {
    // Validate date range
    if (_endDate.isBefore(_startDate)) {
      setState(() {
        _errorMessage = 'End date cannot be before start date';
      });
      return;
    }
    
    // Clear previous error
    setState(() {
      _errorMessage = null;
      _isDownloading = true;
      _downloadProgress = 0.0;
    });
    
    // Simulate API call and download process
    try {
      // Prepare request parameters
      final Map<String, dynamic> params = {
        'type': _selectedReportType,
        'start_date': DateFormat('yyyy-MM-dd').format(_startDate),
        'end_date': DateFormat('yyyy-MM-dd').format(_endDate),
        'format': _selectedFormat,
      };
      
      // For demo: print the API request that would be sent
      if (kDebugMode) {
        print('API Request to /api/download-report');
      }
      if (kDebugMode) {
        print('Parameters: $params');
      }
      
      // Simulate download progress
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 300));
        setState(() {
          _downloadProgress = i / 10;
        });
      }
      
      // Add to recent downloads
      final downloadDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
      _recentDownloads.insert(0, {
        'type': _reportTypes.firstWhere((t) => t['value'] == _selectedReportType)['label'],
        'format': _selectedFormat.toUpperCase(),
        'date': downloadDate,
      });
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedReportType.toUpperCase()} report downloaded successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to download report. Please try again later.';
      });
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }
}
