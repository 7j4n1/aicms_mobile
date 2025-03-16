import 'package:aicms_mobile/models/transaction.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class RecordsService {
  final Dio _dio;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  
  RecordsService() : _dio = Dio(BaseOptions(
    baseUrl: 'https://api.aicms.org/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  
  // Helper method to format date for API
  String? _formatDateForApi(DateTime? date) {
    if (date == null) return null;
    return _dateFormat.format(date);
  }
  
  // Helper method to build query parameters
  Map<String, dynamic> _buildQueryParams({
    DateTime? startDate, 
    DateTime? endDate,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) {
    final Map<String, dynamic> params = {
      'page': page,
      'pageSize': pageSize,
    };
    
    if (startDate != null) {
      params['startDate'] = _formatDateForApi(startDate);
    }
    
    if (endDate != null) {
      params['endDate'] = _formatDateForApi(endDate);
    }
    
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }
    
    return params;
  }
  
  // Fetch savings records
  Future<List<Transaction>> getSavingsRecords({
    DateTime? startDate,
    DateTime? endDate,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/savings',
        queryParameters: _buildQueryParams(
          startDate: startDate,
          endDate: endDate,
          search: search,
          page: page,
          pageSize: pageSize,
        ),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((item) => Transaction.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load savings records');
      }
    } catch (e) {
      throw Exception('Failed to load savings records: $e');
    }
  }
  
  // Fetch shares records
  Future<List<Transaction>> getSharesRecords({
    DateTime? startDate,
    DateTime? endDate,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/shares',
        queryParameters: _buildQueryParams(
          startDate: startDate,
          endDate: endDate,
          search: search,
          page: page,
          pageSize: pageSize,
        ),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((item) => Transaction.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load shares records');
      }
    } catch (e) {
      throw Exception('Failed to load shares records: $e');
    }
  }
  
  // Fetch loan repayments
  Future<List<Transaction>> getLoanRepayments({
    DateTime? startDate,
    DateTime? endDate,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/loan-repayments',
        queryParameters: _buildQueryParams(
          startDate: startDate,
          endDate: endDate,
          search: search,
          page: page,
          pageSize: pageSize,
        ),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((item) => Transaction.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load loan repayments');
      }
    } catch (e) {
      throw Exception('Failed to load loan repayments: $e');
    }
  }
}