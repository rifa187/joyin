import 'package:flutter/services.dart';

// Pindahkan class CreditCardNumberFormatter ke sini
class CreditCardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length > 16) {
      digitsOnly = digitsOnly.substring(0, 16);
    }

    final StringBuffer newText = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i % 4 == 0 && i > 0) {
        newText.write(' ');
      }
      newText.write(digitsOnly[i]);
    }

    final String formattedText = newText.toString();

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}