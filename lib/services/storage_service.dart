import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';

class StorageService {
  static const String _transactionKey = 'spendwise_transactions';
  static const String _nameKey = 'spendwise_name';
  static const String _emailKey = 'spendwise_email';
  static const String _phoneKey = 'spendwise_phone';

  static Future<List<TransactionModel>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_transactionKey);

    if (data == null) return [];

    try {
      final List decoded = jsonDecode(data);
      return decoded
          .map((item) => TransactionModel.fromJson(
        Map<String, dynamic>.from(item),
      ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveTransactions(
      List<TransactionModel> transactions,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final data = transactions.map((e) => e.toJson()).toList();

    await prefs.setString(
      _transactionKey,
      jsonEncode(data),
    );
  }

  static Future<void> addTransaction(
      TransactionModel transaction,
      ) async {
    final transactions = await getTransactions();
    transactions.insert(0, transaction);
    await saveTransactions(transactions);
  }

  static Future<void> updateTransaction(
      TransactionModel transaction,
      ) async {
    final transactions = await getTransactions();

    final index = transactions.indexWhere(
          (item) => item.id == transaction.id,
    );

    if (index != -1) {
      transactions[index] = transaction;
      await saveTransactions(transactions);
    }
  }

  static Future<void> deleteTransaction(String id) async {
    final transactions = await getTransactions();

    transactions.removeWhere((item) => item.id == id);

    await saveTransactions(transactions);
  }

  static Future<void> saveProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_phoneKey, phone);
  }

  static Future<Map<String, String>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'name': prefs.getString(_nameKey) ?? 'SpendWise User',
      'email': prefs.getString(_emailKey) ?? 'user@example.com',
      'phone': prefs.getString(_phoneKey) ?? '',
    };
  }
}