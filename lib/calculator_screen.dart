import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math; // Import the dart:math library

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _previousExpression = '';
  bool _swipeOccurred = false;
  final int _maxDisplayDigits =
      5; // Maximum number of digits to display before using scientific notation

  void _appendToExpression(String value) {
    setState(() {
      if (value == '×') {
        _expression += '*'; // Use '*' for multiplication
      } else if (value == '÷') {
        _expression += '/'; // Use '/' for division
      } else {
        _expression += value;
      }
    });
  }

  void _clearExpression() {
    setState(() {
      _expression = '';
    });
  }

  void _calculateExpression() {
    try {
      Parser p = Parser();
      Expression exp = p.parse(_expression);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      setState(() {
        _previousExpression = _expression;
        _expression = _formatResult(result);
      });
    } catch (e) {
      setState(() {
        _expression = 'Error';
      });
    }
  }

  String _formatResult(double result) {
    // Convert result to scientific notation if it exceeds the maximum display digits
    if (result.abs() >= math.pow(10, _maxDisplayDigits)) {
      double exponent = math.log(result.abs()) / math.log(10);
      int truncatedExponent = exponent.truncate();
      double mantissa = result / math.pow(10, truncatedExponent);
      return '${mantissa.toStringAsFixed(2)} * 10^$truncatedExponent';
    } else {
      return result.toString();
    }
  }

  void _recoverPreviousExpression() {
    setState(() {
      _expression = _previousExpression;
    });
  }

  void _clearLastEntry() {
    if (_swipeOccurred && _expression.isNotEmpty) {
      setState(() {
        _expression = _expression.substring(0, _expression.length - 1);
        _swipeOccurred = false;
      });
    }
  }

  void _calculatePercentage() {
    try {
      Parser p = Parser();
      Expression exp = p.parse(_expression);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm) / 100;
      setState(() {
        _expression = result.toString();
      });
    } catch (e) {
      setState(() {
        _expression = 'Error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragStart: (_) {
          _swipeOccurred = true;
        },
        onHorizontalDragEnd: (_) {
          _swipeOccurred = false;
        },
        onHorizontalDragUpdate: (_) {
          _clearLastEntry();
        },
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 0) {
            _recoverPreviousExpression();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Colors.black,
                padding: EdgeInsets.only(
                    top: 16.0, bottom: 8.0, right: 16.0, left: 16.0),
                alignment: Alignment.centerRight,
                child: Text(
                  _expression,
                  style: TextStyle(
                      fontSize: 60.0,
                      color: Color.fromARGB(255, 255, 255, 255)),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildButtonRow(['7', '8', '9', '+'], Colors.blueGrey),
                  _buildButtonRow(['4', '5', '6', '-'], Colors.blueGrey),
                  _buildButtonRow(['1', '2', '3', '×'],
                      Colors.blueGrey), // Changed '*' to '×'
                  _buildButtonRow(
                      ['', '0', '.', '÷'],
                      Colors
                          .blueGrey), // Changed '/' to '÷', replaced 'C' with empty string
                ],
              ),
            ),
            SizedBox(
                height:
                    8.0), // Add some space between button rows and the bottom row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton('AC', _clearExpression, Colors.red),
                _buildButton('=', _calculateExpression, Colors.green),
                _buildButton('%', _calculatePercentage, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonRow(List<String> buttons, Color color) {
    return Expanded(
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.start, // Adjusted to MainAxisAlignment.start
        children: buttons
            .map(
              (text) => text.isEmpty
                  ? SizedBox()
                  : _buildButton(
                      text,
                      () => _appendToExpression(text),
                      color,
                      width: text == '' ? 90.0 : 70.0,
                    ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildButton(String text, Function() onPressed, Color color,
      {double width = 70.0}) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: TextButton(
          onPressed: onPressed != null ? onPressed : () {},
          child: Text(
            text,
            style: TextStyle(
              fontSize:
                  text == '0' ? 35.0 : 36.0, // Increased font size for '0'
              color: Colors.white,
            ),
          ),
          style: TextButton.styleFrom(
            backgroundColor: color,
            padding: EdgeInsets.all(16.0), // Adjust the padding here
            minimumSize: Size(width, 70.0), // Set minimum size for the button
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(70.0),
            ),
          ),
        ),
      ),
    );
  }
}
