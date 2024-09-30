import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

// Custom list tile widget with sliding actions
class ExpenseTile extends StatelessWidget {
  final String title;
  final String trailing;
  final void Function(BuildContext)? onEditPressed;
  final void Function(BuildContext)? onDeletePressed;

  const ExpenseTile({
    super.key,
    required this.title,
    required this.trailing,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: onEditPressed,
              icon: Icons.settings,
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            SlidableAction(
              onPressed: onDeletePressed,
              backgroundColor: Color.fromARGB(255, 253, 85, 82),
              foregroundColor: Colors.white,
              borderRadius: BorderRadius.circular(4),
              icon: Icons.delete,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 254, 226, 226),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            title: Text(title),
            trailing: Text(trailing),
          ),
        ),
      ),
    );
  }
}
