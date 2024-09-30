import 'package:expensetracker/bar%20graph/bar_graph.dart';
import 'package:expensetracker/components/expense_tile.dart';
import 'package:expensetracker/database/expense_database.dart';
import 'package:expensetracker/helper/helper_functions.dart';
import 'package:expensetracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Home page widget displaying expense data and actions
class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({super.key});

  @override
  State<ExpenseHomePage> createState() => _HomePageState();
}

class _HomePageState extends State<ExpenseHomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  Future<Map<String, double>>? _monthlyTotalsFuture;
  Future<double>? _calculateCurrentMonthTotal;

  @override
  void initState() {
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();

    refreshData();

    super.initState();
  }

  // Refreshes data displayed on the page
  void refreshData() {
    _monthlyTotalsFuture = Provider.of<ExpenseDatabase>(context, listen: false)
        .calculateMonthlyTotals();
    _calculateCurrentMonthTotal =
        Provider.of<ExpenseDatabase>(context, listen: false)
            .calculateCurrentMonthTotal();
  }

  // Opens a dialog to add a new expense
  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Name"),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(hintText: "Amount"),
            ),
          ],
        ),
        actions: [_cancelButton(), _createNewExpenseButton()],
      ),
    );
  }

  // Opens a dialog to edit an existing expense
  void openEditBox(Expense expense) {
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: existingName),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(hintText: existingAmount),
            ),
          ],
        ),
        actions: [
          _cancelButton(),
          _editExpenseButton(expense),
        ],
      ),
    );
  }

  // Opens a dialog to confirm deletion of an expense
  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Expense"),
        actions: [
          _cancelButton(),
          _deleteExpenseButton(expense.id),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
      builder: (context, value, child) {
        int startMonth = value.getStartMonth();
        int startYear = value.getStartYear();
        int currentMonth = DateTime.now().month;
        int currentYear = DateTime.now().year;

        int monthCount = calculateMonthCount(
            startYear, startMonth, currentYear, currentMonth);

        List<Expense> currentMonthExpenses = value.allExpense.where((expense) {
          return expense.date.year == currentYear &&
              expense.date.month == currentMonth;
        }).toList();

        return Scaffold(
          backgroundColor: Color.fromARGB(255, 248, 234, 234),
          floatingActionButton: FloatingActionButton(
            onPressed: openNewExpenseBox,
            backgroundColor: Color.fromARGB(255, 240, 52, 52),
            child: Icon(Icons.add, color: Colors.white),
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: FutureBuilder<double>(
              future: _calculateCurrentMonthTotal,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\Rs. ${snapshot.data!.toStringAsFixed(2)}'),
                      Text(
                        getCurrentMonthName(),
                      ),
                    ],
                  );
                } else {
                  return const Text("Loading..");
                }
              },
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  child: FutureBuilder(
                    future: _monthlyTotalsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        Map<String, double> monthlyTotals = snapshot.data ?? {};

                        List<double> monthlySummary = List.generate(
                          monthCount,
                          (index) {
                            int year =
                                startYear + (startMonth + index - 1) ~/ 12;
                            int month = (startMonth + index - 1) % 12 + 1;

                            String yearMonthKey = '$year-$month';
                            return monthlyTotals[yearMonthKey] ?? 0.0;
                          },
                        );

                        return MyBarGraph(
                            monthlySummary: monthlySummary,
                            startMonth: startMonth);
                      } else {
                        return const Center(
                          child: Text("Loading.."),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 25),
                Expanded(
                  child: ListView.builder(
                    itemCount: currentMonthExpenses.length,
                    itemBuilder: (context, index) {
                      int reversedIndex =
                          currentMonthExpenses.length - 1 - index;

                      Expense individualExpense =
                          currentMonthExpenses[reversedIndex];

                      return ExpenseTile(
                        title: individualExpense.name,
                        trailing: formatAmount(individualExpense.amount),
                        onEditPressed: (context) =>
                            openEditBox(individualExpense),
                        onDeletePressed: (context) =>
                            openDeleteBox(individualExpense),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget for cancel button in dialogs
  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        Navigator.pop(context);
        nameController.clear();
        amountController.clear();
      },
      child: const Text('Cancel'),
    );
  }

  // Widget for save button in new expense dialog
  Widget _createNewExpenseButton() {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          Navigator.pop(context);

          Expense newExpense = Expense(
            name: nameController.text,
            amount: convertStringToDouble(amountController.text),
            date: DateTime.now(),
          );

          await context.read<ExpenseDatabase>().createNewExpense(newExpense);

          refreshData();

          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text('Save'),
    );
  }

  // Widget for save button in edit expense dialog
  Widget _editExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          Navigator.pop(context);

          Expense updatedExpense = Expense(
            name: nameController.text.isNotEmpty
                ? nameController.text
                : expense.name,
            amount: amountController.text.isNotEmpty
                ? convertStringToDouble(amountController.text)
                : expense.amount,
            date: DateTime.now(),
          );

          int existingId = expense.id;
          await context
              .read<ExpenseDatabase>()
              .updateExpense(existingId, updatedExpense);

          refreshData();
        }
      },
      child: const Text("Save"),
    );
  }

  // Widget for delete button in delete expense dialog
  Widget _deleteExpenseButton(int id) {
    return MaterialButton(
      onPressed: () async {
        Navigator.pop(context);

        await context.read<ExpenseDatabase>().deleteExpense(id);

        refreshData();
      },
      child: const Text("Delete"),
    );
  }
}
