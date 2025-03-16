import 'dart:async';

import 'package:aicms_mobile/tabs/loans_tab.dart';
import 'package:aicms_mobile/tabs/savings_tab.dart';
import 'package:aicms_mobile/tabs/shares_tab.dart';
import 'package:flutter/material.dart';
import 'package:aicms_mobile/theme/app_theme.dart';
import 'package:aicms_mobile/widgets/date_range_filter.dart';
import 'package:intl/intl.dart';

class RecordsScreen extends StatefulWidget {
  final int initialTabIndex;
  
  const RecordsScreen({
    super.key, 
    this.initialTabIndex = 0 // Default to first tab (savings)
  });

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3, 
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    
    // Set default date range (last 30 days)
    _endDate = DateTime.now();
    _startDate = _endDate!.subtract(const Duration(days: 30));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchQuery = '';
        _searchController.clear();
      } else {
        // Focus the search field when activated
        Future.delayed(const Duration(milliseconds: 100), () {
          if(!mounted) return;

          FocusScope.of(context).requestFocus(FocusNode());
        });
      }
    });
  }

  void _onDateRangeChanged(DateTime? start, DateTime? end) {
    setState(() {
      _startDate = start;
      _endDate = end;
    });
    
    // Refresh current tab data
    final currentTabIndex = _tabController.index;
    _refreshTabData(currentTabIndex);
  }

  void _refreshTabData(int tabIndex) {
    // Each tab has a GlobalKey that we can use to access the tab's state
    switch (tabIndex) {
      case 0:
        if (_savingsTabKey.currentState != null) {
          _savingsTabKey.currentState!.refreshData(_startDate, _endDate, _searchQuery);
        }
        break;
      case 1:
        if (_sharesTabKey.currentState != null) {
          _sharesTabKey.currentState!.refreshData(_startDate, _endDate, _searchQuery);
        }
        break;
      case 2:
        if (_loansTabKey.currentState != null) {
          _loansTabKey.currentState!.refreshData(_startDate, _endDate, _searchQuery);
        }
        break;
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    // Debounce search to avoid too many API calls
    _debounceSearch?.cancel();
    _debounceSearch = Timer(const Duration(milliseconds: 500), () {
      _refreshTabData(_tabController.index);
    });
  }

  Timer? _debounceSearch;

  final GlobalKey<SavingsTabState> _savingsTabKey = GlobalKey();
  final GlobalKey<SharesTabState> _sharesTabKey = GlobalKey();
  final GlobalKey<LoansTabState> _loansTabKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearchActive 
          ? TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Records...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey.shade400),
              ),
              style: const TextStyle(color: AppTheme.textPrimary),
              autofocus: true,
              onChanged: _onSearchChanged,
            )
          : const Text('Records'),
        actions: [
          IconButton(
            icon: Icon(_isSearchActive ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final result = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => DateRangeFilter(
                  startDate: _startDate,
                  endDate: _endDate,
                ),
              );
              
              if (result != null && result is Map<String, DateTime?>) {
                _onDateRangeChanged(result['start'], result['end']);
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            // Refresh the tab data when switching tabs
            _refreshTabData(index);
          },
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.backgroundColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Savings'),
            Tab(text: 'Shares'),
            Tab(text: 'Loans'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Date Range Display
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.date_range,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_startDate != null ? DateFormat('MMM dd, yyyy').format(_startDate!) : 'Any'}'
                  ' to '
                  '${_endDate != null ? DateFormat('MMM dd, yyyy').format(_endDate!) : 'Now'}',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SavingsTab(
                  key: _savingsTabKey,
                  startDate: _startDate,
                  endDate: _endDate,
                  searchQuery: _searchQuery,
                ),
                SharesTab(
                  key: _sharesTabKey,
                  startDate: _startDate,
                  endDate: _endDate,
                  searchQuery: _searchQuery,
                ),
                LoansTab(
                  key: _loansTabKey,
                  startDate: _startDate,
                  endDate: _endDate,
                  searchQuery: _searchQuery,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacementNamed('/dashboard');
              break;
            case 1:
              // Already on records screen
              // Navigator.of(context).pushReplacementNamed('/records');
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
}