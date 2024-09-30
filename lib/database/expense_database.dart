import 'package:expensetracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

// Database management class for expenses
class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar; // Isar instance for database operations
  List<Expense> _allExpenses = []; // List to hold all expenses

  // Initialize the database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

  // Getter for all expenses
  List<Expense> get allExpense => _allExpenses;

  // Create a new expense record
  Future<void> createNewExpense(Expense newExpense) async {
    await isar.writeTxn(() => isar.expenses.put(newExpense));
    readExpenses();
  }

  // Read all expenses from the database
  Future<void> readExpenses() async {
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();
    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpenses);
    notifyListeners();
  }

  // Update an existing expense record
  Future<void> updateExpense(int id, Expense updatedExpense) async {
    updatedExpense.id = id;
    await isar.writeTxn(() => isar.expenses.put(updatedExpense));
    await readExpenses();
  }

  // Delete an expense record
  Future<void> deleteExpense(int id) async {
    await isar.writeTxn(() => isar.expenses.delete(id));
    await readExpenses();
  }

  // Calculate monthly totals of expenses
  Future<Map<String, double>> calculateMonthlyTotals() async {
    await readExpenses();

    Map<String, double> monthlyTotals = {};

    for (var expense in _allExpenses) {
      String yearMonth =
          expense.date.year.toString() + '-' + expense.date.month.toString();
      if (!monthlyTotals.containsKey(yearMonth)) {
        monthlyTotals[yearMonth] = 0;
      }
      monthlyTotals[yearMonth] = monthlyTotals[yearMonth]! + expense.amount;
    }
    return monthlyTotals;
  }

  // Calculate total expenses for the current month
  Future<double> calculateCurrentMonthTotal() async {
    await readExpenses();

    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    List<Expense> currentMonthExpenses = _allExpenses.where((expense) {
      return expense.date.month == currentMonth &&
          expense.date.year == currentYear;
    }).toList();

    double total =
        currentMonthExpenses.fold(0, (sum, expense) => sum + expense.amount);

    return total;
  }

  // Get the starting month from the earliest expense record
  int getStartMonth() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().month;
    }

    _allExpenses.sort(
      (a, b) => a.date.compareTo(b.date),
    );
    return _allExpenses.first.date.month;
  }

  // Get the starting year from the earliest expense record
  int getStartYear() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().year;
    }

    _allExpenses.sort(
      (a, b) => a.date.compareTo(b.date),
    );
    return _allExpenses.first.date.year;
  }
}
