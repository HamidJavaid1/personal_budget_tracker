import 'package:flutter/material.dart';
import 'package:personal_budget_tracker/model/transaction.dart';
import 'package:personal_budget_tracker/screens.dart/transactionscreen.dart';
import 'package:personal_budget_tracker/sevices.dart/db_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DBHelper dbHelper = DBHelper();
  List<TransactionModel> data = [];

  double income = 0;
  double expense = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    data = await dbHelper.getTransactions();

    income = 0;
    expense = 0;

    for (var item in data) {
      if (item.type == "income") {
        income += item.amount;
      } else {
        expense += item.amount;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double balance = income - expense;

    return Scaffold(
      appBar: AppBar(title: Text("Budget Tracker")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTransaction()),
          );
          loadData();
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Text("Balance: $balance"),
          Text("Income: $income"),
          Text("Expense: $expense"),
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(data[index].title),
                  subtitle: Text(data[index].category),
                  trailing: Text("${data[index].amount}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
