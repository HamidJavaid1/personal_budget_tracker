import 'package:flutter/material.dart';
import 'package:personal_budget_tracker/model/transaction.dart';
import 'package:personal_budget_tracker/sevices.dart/db_helper.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({super.key});

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  TextEditingController title = TextEditingController();
  TextEditingController amount = TextEditingController();

  String type = "expense";
  String category = "Food";

  DBHelper dbHelper = DBHelper();

  Future<void> save() async {
    TransactionModel tx = TransactionModel(
      title: title.text,
      amount: double.parse(amount.text),
      type: type,
      category: category,
      date: DateTime.now().toString(),
    );

    await dbHelper.insert(tx);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Transaction")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: title,
              decoration: InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: amount,
              decoration: InputDecoration(labelText: "Amount"),
            ),
            DropdownButton(
              value: type,
              items: [
                "income",
                "expense",
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => type = val!),
            ),
            ElevatedButton(onPressed: save, child: Text("Save")),
          ],
        ),
      ),
    );
  }
}
