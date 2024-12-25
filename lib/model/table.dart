import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TableModel {
  final String id;
  final int tableNumber;
  final int capacity;
  final String restaurantId;

  TableModel({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    required this.restaurantId,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['_id'],
      tableNumber: json['tableNumber'],
      capacity: json['capacity'],
      restaurantId: json['restaurantId'],
    );
  }
}


class TableProvider with ChangeNotifier {
  final TableService _tableService = TableService();

  List<TableModel> _tables = [];
  bool _isLoading = false;
  bool _noAvailableTables = false;
  TableModel? _selectedTable;

  List<TableModel> get tables => _tables;
  bool get isLoading => _isLoading;
  bool get noAvailableTables => _noAvailableTables;
  TableModel? get selectedTable => _selectedTable;

  Future<void> fetchTables(String restaurantId) async {
    _isLoading = true;
    _noAvailableTables = false;
    notifyListeners();

    try {
      final fetchedTables = await _tableService.fetchTables(restaurantId);
      if (fetchedTables.isEmpty) {
        _noAvailableTables = true;
      } else {
        _tables = fetchedTables;
      }
    } catch (e) {
      _noAvailableTables = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectTable(TableModel table) {
    _selectedTable = table;
    notifyListeners();
  }
}



class TableService {
  static const String baseUrl ='https://restaurant-reservation-sys.vercel.app';

  Future<List<TableModel>> fetchTables(String restaurantId) async {
    final url = '$baseUrl/tables/restaurant/$restaurantId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print(response.body);
        final data = jsonDecode(response.body);
        if (data['data'] == null || data['data'].isEmpty) {
          return [];
        }

        return List<TableModel>.from(
          data['data'].map((table) => TableModel.fromJson(table)),
        );
      } else {
        print(response.body);
        throw Exception('Failed to load tables');
      }
    } catch (e) {
      throw Exception('Error fetching tables: $e');
    }
  }
}
