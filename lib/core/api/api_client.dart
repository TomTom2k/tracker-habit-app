import 'package:supabase_flutter/supabase_flutter.dart';
import '../exceptions/exceptions.dart' as app_exceptions;
import '../services/supabase_service.dart';

/// API Client chung cho tất cả các API calls
class ApiClient {
  final SupabaseClient _supabase = SupabaseService.client;

  /// Generic method để xử lý API calls với error handling
  Future<T> _handleRequest<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on app_exceptions.AppAuthException {
      rethrow;
    } on PostgrestException catch (e) {
      throw app_exceptions.ServerException(e.message);
    } on Exception catch (e) {
      throw app_exceptions.NetworkException(e.toString());
    } catch (e) {
      throw app_exceptions.AppException(e.toString());
    }
  }

  /// GET request
  Future<List<Map<String, dynamic>>> get(
    String table, {
    String? filterColumn,
    dynamic filterValue,
    int? limit,
    String? orderBy,
    bool ascending = true,
  }) async {
    return _handleRequest(() async {
      var query = _supabase.from(table).select();
      
      if (filterColumn != null && filterValue != null) {
        query = query.eq(filterColumn, filterValue) as dynamic;
      }
      
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending) as dynamic;
      }
      
      if (limit != null) {
        query = query.limit(limit) as dynamic;
      }
      
      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    });
  }

  /// GET by ID
  Future<Map<String, dynamic>?> getById(String table, String id) async {
    return _handleRequest(() async {
      final response = await _supabase
          .from(table)
          .select()
          .eq('id', id)
          .single();
      return Map<String, dynamic>.from(response);
    });
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String table,
    Map<String, dynamic> data,
  ) async {
    return _handleRequest(() async {
      final response = await _supabase.from(table).insert(data).select().single();
      return Map<String, dynamic>.from(response);
    });
  }

  /// PUT/PATCH request
  Future<Map<String, dynamic>> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    return _handleRequest(() async {
      final response = await _supabase
          .from(table)
          .update(data)
          .eq('id', id)
          .select()
          .single();
      return Map<String, dynamic>.from(response);
    });
  }

  /// DELETE request
  Future<void> delete(String table, String id) async {
    return _handleRequest(() async {
      await _supabase.from(table).delete().eq('id', id);
    });
  }

  /// Get Supabase client for custom queries
  SupabaseClient get client => _supabase;
}

