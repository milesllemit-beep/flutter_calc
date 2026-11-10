import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData.dark(),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _displayVal = "0";
  double? _firstOperand;
  String? _operator;
  bool _clearNext = false;

  void _onDigit(String digit) {
    setState(() {
      if (_displayVal == "0" || _clearNext) {
        _displayVal = digit;
        _clearNext = false;
      } else {
        _displayVal += digit;
      }
    });
  }

  void _onDecimal() {
    setState(() {
      if (_clearNext) {
        _displayVal = "0.";
        _clearNext = false;
        return;
      }
      if (!_displayVal.contains(".")) {
        _displayVal += ".";
      }
    });
  }

  void _onOperator(String op) {
    double currentVal = double.tryParse(_displayVal) ?? 0;

    if (_firstOperand == null) {
      _firstOperand = currentVal;
    } else if (_operator != null && !_clearNext) {
      _firstOperand = _calculate(_firstOperand!, currentVal, _operator!);
      _displayVal = _formatResult(_firstOperand!);
    }

    _operator = op;
    _clearNext = true;
  }

  void _onEquals() {
    if (_operator == null || _firstOperand == null) return;
    double currentVal = double.tryParse(_displayVal) ?? 0;

    double result = _calculate(_firstOperand!, currentVal, _operator!);
    setState(() {
      _displayVal = _formatResult(result);
      _firstOperand = null;
      _operator = null;
      _clearNext = true;
    });
  }

  double _calculate(double n1, double n2, String op) {
    switch (op) {
      case "+":
        return n1 + n2;
      case "-":
        return n1 - n2;
      case "×":
        return n1 * n2;
      case "÷":
        if (n2 == 0) return 0; // Prevent crash, handle division by zero
        return n1 / n2;
      default:
        return n2;
    }
  }

  String _formatResult(double val) {
    if (val == val.toInt()) {
      return val.toInt().toString();
    }
    // Clean up float issues
    return val.toStringAsFixed(6).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
  }

  void _onClear() {
    setState(() {
      _displayVal = "0";
      _firstOperand = null;
      _operator = null;
      _clearNext = false;
    });
  }

  void _onDelete() {
    setState(() {
      if (_clearNext) return;
      if (_displayVal.length > 1) {
        _displayVal = _displayVal.substring(0, _displayVal.length - 1);
      } else {
        _displayVal = "0";
      }
    });
  }

  void _buttonPressed(String text) {
    if (text == "C") {
      _onClear();
    } else if (text == "⌫") {
      _onDelete();
    } else if (text == "+" || text == "-" || text == "×" || text == "÷") {
      _onOperator(text);
    } else if (text == "=") {
      _onEquals();
    } else if (text == ".") {
      _onDecimal();
    } else {
      _onDigit(text);
    }
  }

  Widget _buildButton(String buttonText, Color buttonColor, Color textColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            padding: const EdgeInsets.all(22.0),
          ),
          onPressed: () => _buttonPressed(buttonText),
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calculator")),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 24.0,
              ),
              child: Text(
                _displayVal,
                style: const TextStyle(
                  fontSize: 56.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  _buildButton("C", Colors.grey, Colors.black),
                  _buildButton("⌫", Colors.grey, Colors.black),
                  _buildButton("%", Colors.grey, Colors.black),
                  _buildButton("÷", Colors.orange, Colors.white),
                ],
              ),
              Row(
                children: [
                  _buildButton("7", Colors.grey[850]!, Colors.white),
                  _buildButton("8", Colors.grey[850]!, Colors.white),
                  _buildButton("9", Colors.grey[850]!, Colors.white),
                  _buildButton("×", Colors.orange, Colors.white),
                ],
              ),
              Row(
                children: [
                  _buildButton("4", Colors.grey[850]!, Colors.white),
                  _buildButton("5", Colors.grey[850]!, Colors.white),
                  _buildButton("6", Colors.grey[850]!, Colors.white),
                  _buildButton("-", Colors.orange, Colors.white),
                ],
              ),
              Row(
                children: [
                  _buildButton("1", Colors.grey[850]!, Colors.white),
                  _buildButton("2", Colors.grey[850]!, Colors.white),
                  _buildButton("3", Colors.grey[850]!, Colors.white),
                  _buildButton("+", Colors.orange, Colors.white),
                ],
              ),
              Row(
                children: [
                  _buildButton("0", Colors.grey[850]!, Colors.white),
                  _buildButton(".", Colors.grey[850]!, Colors.white),
                  _buildButton("=", Colors.orange, Colors.white),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}