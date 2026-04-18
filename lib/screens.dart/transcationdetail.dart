import 'package:flutter/material.dart';
import 'package:personal_budget_tracker/model/transaction.dart';

class TransactionDetail extends StatelessWidget {
  final TransactionModel item;

  const TransactionDetail({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Details")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(item.title, style: TextStyle(fontSize: 22)),
                SizedBox(height: 10),
                Text("Amount: ${item.amount}"),
                Text("Category: ${item.category}"),
                Text("Type: ${item.type}"),
                Text("Date: ${item.date}"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
