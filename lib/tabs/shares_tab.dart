import 'package:aicms_mobile/models/transaction.dart';
import 'package:aicms_mobile/widgets/empty_state_widget.dart';
import 'package:aicms_mobile/widgets/shimmer_loading.dart';
import 'package:aicms_mobile/widgets/transaction_list_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:aicms_mobile/services/records_service.dart';

class SharesTab extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String searchQuery;

  const SharesTab({
    super.key,
    this.startDate,
    this.endDate,
    this.searchQuery = '',
  });

  @override
  State<SharesTab> createState() => SharesTabState();
}

class SharesTabState extends State<SharesTab> with AutomaticKeepAliveClientMixin {
  final RecordsService _recordsService = RecordsService();
  final List<Transaction> _sharesRecords = [];
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = false;
  bool _hasError = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  final int _pageSize = 20;
  String _errorMessage = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 500) {
      if (!_isLoading && _hasMoreData) {
        _loadMoreData();
      }
    }
  }

  Future<void> _loadData() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      _currentPage = 1;
      _sharesRecords.clear();
    });

    try {
      final records = await _recordsService.getSharesRecords(
        startDate: widget.startDate,
        endDate: widget.endDate,
        search: widget.searchQuery.isEmpty ? null : widget.searchQuery,
        page: _currentPage,
        pageSize: _pageSize,
      );
      
      setState(() {
        _sharesRecords.addAll(records);
        _isLoading = false;
        _hasMoreData = records.length == _pageSize;
      });
    } catch (e) {
      if(kDebugMode) print(e);
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMoreData) return;
    
    setState(() {
      _isLoading = true;
      _currentPage++;
    });

    try {
      final records = await _recordsService.getSharesRecords(
        startDate: widget.startDate,
        endDate: widget.endDate,
        search: widget.searchQuery.isEmpty ? null : widget.searchQuery,
        page: _currentPage,
        pageSize: _pageSize,
      );
      
      setState(() {
        _sharesRecords.addAll(records);
        _isLoading = false;
        _hasMoreData = records.length == _pageSize;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
        _currentPage--; // Revert page increment on error
      });
    }
  }

  // Refresh data when date range or search query changes
  Future<void> refreshData(DateTime? startDate, DateTime? endDate, String? searchQuery) async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading && _sharesRecords.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: ShimmerLoading(height: 80),
        ),
      );
    }

    if (_hasError && _sharesRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load shares records',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if(_sharesRecords.isEmpty){
      return EmptyStateWidget(
        icon: Icons.savings_outlined, 
        title: 'No shares records found', 
        message: 'No shares transactions during this period',
        buttonText: 'Refresh',
        onButtonPressed: _loadData,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        itemCount: _sharesRecords.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _sharesRecords.length) {
            final record = _sharesRecords[index];
            return TransactionListItem(
              transaction: record,
              onTap: () {
                // Navigate to transaction details screen
              },
            );
          }

          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )
          );
        },
      ),
    );
  }
}