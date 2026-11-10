
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Calculator',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3F4F8),
      ),
      home: const Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String display = '0';
  double? firstNumber;
  String? operator;
  bool newNumber = false;

  final List<List<String>> buttons = [
    ['C', '⌫', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['0', '.', '='],
  ];

  void clear() {
    display = '0';
    firstNumber = null;
    operator = null;
    newNumber = false;
  }

  String formatNumber(double number) {
    if (!number.isFinite) return 'Error';
    if (number == 0) return '0';

    if (number.abs() < 1e15 &&
        number == number.truncateToDouble()) {
      return number.toInt().toString();
    }

    return number
        .toStringAsFixed(8)
        .replaceFirst(RegExp(r'\.?0+$'), '');
  }

  void calculate() {
    if (firstNumber == null || operator == null) return;

    final secondNumber = double.tryParse(display);
    if (secondNumber == null) return;

    double result;

    switch (operator) {
      case '+':
        result = firstNumber! + secondNumber;
        break;
      case '-':
        result = firstNumber! - secondNumber;
        break;
      case '×':
        result = firstNumber! * secondNumber;
        break;
      case '÷':
        if (secondNumber == 0) {
          display = 'Error';
          firstNumber = null;
          operator = null;
          newNumber = true;
          return;
        }
        result = firstNumber! / secondNumber;
        break;
      case '%':
        result = firstNumber! * secondNumber / 100;
        break;
      default:
        return;
    }

    display = formatNumber(result);
    firstNumber = null;
    operator = null;
    newNumber = true;
  }

  void pressedButton(String value) {
    setState(() {
      // Clear everything.
      if (value == 'C') {
        clear();
        return;
      }

      // Recover from an error.
      if (display == 'Error') {
        if (RegExp(r'^[0-9]$').hasMatch(value)) {
          clear();
        } else {
          return;
        }
      }

      // Enter digits.
      if (RegExp(r'^[0-9]$').hasMatch(value)) {
        if (newNumber || display == '0') {
          display = value;
          newNumber = false;
        } else if (display.length < 15) {
          display += value;
        }
        return;
      }

      // Delete the last digit.
      if (value == '⌫') {
        if (newNumber) return;

        if (display.length > 1) {
          display = display.substring(0, display.length - 1);
        } else {
          display = '0';
        }
        return;
      }

      // Enter a decimal point.
      if (value == '.') {
        if (newNumber) {
          display = '0.';
          newNumber = false;
        } else if (!display.contains('.')) {
          display += '.';
        }
        return;
      }

      // Convert the current number to a percentage.
      if (value == '%') {
        final number = double.tryParse(display);
        if (number != null && !newNumber) {
          display = formatNumber(number / 100);
        }
        return;
      }

      // Choose an arithmetic operator.
      if (['+', '-', '×', '÷'].contains(value)) {
        if (firstNumber != null &&
            operator != null &&
            !newNumber) {
          calculate();

          if (display == 'Error') return;
        }

        firstNumber = double.tryParse(display);
        operator = value;
        newNumber = true;
        return;
      }

      // Calculate the answer.
      if (value == '=' &&
          firstNumber != null &&
          operator != null &&
          !newNumber) {
        calculate();
      }
    });
  }

  Widget buildButton(String value) {
    final isOperator = ['+', '-', '×', '÷'].contains(value);
    final isEquals = value == '=';
    final isUtility = ['C', '⌫', '%'].contains(value);

    Color backgroundColor = Colors.white;
    Color textColor = Colors.black87;

    if (isOperator) {
      backgroundColor = const Color(0xFFDCE5FF);
      textColor = const Color(0xFF4338CA);
    } else if (isEquals) {
      backgroundColor = const Color(0xFF4F46E5);
      textColor = Colors.white;
    } else if (isUtility) {
      backgroundColor = const Color(0xFFE5E7EB);
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: SizedBox.expand(
          child: FilledButton(
            onPressed: () => pressedButton(value),
            style: FilledButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: textColor,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F4F8),
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('Simple Calculator'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  alignment: Alignment.bottomRight,
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      display,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: display.length > 12 ? 36 : 56,
                        fontWeight: FontWeight.bold,
                        color: display == 'Error'
                            ? Colors.red
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    for (final row in buttons)
                      Expanded(
                        child: Row(
                          children: [
                            for (final button in row)
                              buildButton(button),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
