import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import 'pages/expense_homepage.dart';

// Expense Manager splash screen widget
class ExpenseManager extends StatefulWidget {
  const ExpenseManager({Key? key}) : super(key: key);

  @override
  _ExpenseManagerState createState() => _ExpenseManagerState();
}

class _ExpenseManagerState extends State<ExpenseManager>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // Navigate to HomePage after animation completes
    _controller.forward().whenComplete(() {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ExpenseHomePage()),
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 234, 234),
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: DefaultTextStyle(
            style: const TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 255, 0, 0),
            ),
            child: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText('Expense Manager'),
              ],
              totalRepeatCount: 1,
            ),
          ),
        ),
      ),
    );
  }
}
