import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

TextInputFormatter currencyInputFormatter() {
  return TextInputFormatter.withFunction((oldValue, newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(
        text: '0',
        selection: const TextSelection.collapsed(offset: 1),
      );
    }

    final formatter = NumberFormat.decimalPattern('id');
    int value = int.parse(newValue.text.replaceAll('.', ''));
    String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  });
}
