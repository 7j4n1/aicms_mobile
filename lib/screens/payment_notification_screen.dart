import 'package:aicms_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class PaymentNotificationScreen extends StatefulWidget {
  const PaymentNotificationScreen({super.key});

  @override
  State<PaymentNotificationScreen> createState() => _PaymentNotificationScreenState();
}

class _PaymentNotificationScreenState extends State<PaymentNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _depositorNameController = TextEditingController();
  final _referenceController = TextEditingController();
  final _additionalDetailsController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedBank;
  String? _selectedPaymentChannel;
  PlatformFile? _selectedFile;
  bool _isLoading = false;

  final List<String> _banks = [
    'First Bank',
    'UBA',
    'Zenith Bank',
    'Access Bank',
    'GTBank',
    'Ecobank',
    'Fidelity Bank',
    'FCMB'
  ];

  final List<String> _paymentChannels = [
    'Bank deposit',
    'USSD',
    'Internet banking',
    'ATM transfer',
    'POS transfer',
    'Mobile app'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Payment'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form Title
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  'PAYMENT NOTIFICATION FORM',
                  style: AppTheme.subtitle.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount Paid (₦)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the payment amount';
                  }
                  try {
                    double.parse(value);
                  } catch (e) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date Picker
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Payment Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('yyyy-MM-dd').format(_selectedDate),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Time Picker
              InkWell(
                onTap: () => _selectTime(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Payment Time',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(
                    _selectedTime.format(context),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Bank Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Bank Used',
                  prefixIcon: Icon(Icons.account_balance),
                ),
                value: _selectedBank,
                hint: const Text('Select Bank'),
                items: _banks.map((bank) {
                  return DropdownMenuItem(
                    value: bank,
                    child: Text(bank),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBank = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a bank';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Payment Channel Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Payment Channel',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                value: _selectedPaymentChannel,
                hint: const Text('Select Payment Method'),
                items: _paymentChannels.map((channel) {
                  return DropdownMenuItem(
                    value: channel,
                    child: Text(channel),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentChannel = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a payment channel';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Depositor Name
              TextFormField(
                controller: _depositorNameController,
                decoration: const InputDecoration(
                  labelText: 'Depositor Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter depositor name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Reference Number
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Reference/Account #',
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(height: 24),

              // File Upload Button
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(_selectedFile != null
                    ? 'File selected: ${_selectedFile!.name}'
                    : 'Upload Payment Evidence'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 0),
                ),
              ),
              if (_selectedFile != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check_circle, color: AppTheme.success, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'File uploaded successfully',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.success,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedFile = null;
                        });
                      },
                      child: Text(
                        'Remove',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              // Additional Details
              TextFormField(
                controller: _additionalDetailsController,
                decoration: const InputDecoration(
                  labelText: 'Additional Details',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SUBMIT PAYMENT NOTIFICATION'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacementNamed('/dashboard');
              break;
            case 1:
              Navigator.of(context).pushReplacementNamed('/records');
              break;
            case 2:
              Navigator.of(context).pushReplacementNamed('/reports');
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload payment evidence'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));
        
        // Success notification
        setState(() {
          _isLoading = false;
        });
        
        if (!mounted) return;
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Payment Notification Submitted'),
              content: const Text('Your payment notification has been submitted successfully.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        // Handle error
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting payment: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}