import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// BuildContext extensions
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void dismissKeyboard() => FocusScope.of(this).unfocus();
}

// String extensions
extension StringExtensions on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String get titleCase {
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  bool get isValidPhone {
    return RegExp(r'^[+]?[0-9]{9,15}$').hasMatch(replaceAll(' ', ''));
  }

  String get initials {
    final parts = trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return isNotEmpty ? this[0].toUpperCase() : '?';
  }

  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }
}

// DateTime extensions
extension DateTimeExtensions on DateTime {
  String get formatted => DateFormat('MMM d, yyyy').format(this);
  String get formattedWithTime => DateFormat('MMM d, yyyy • hh:mm a').format(this);
  String get timeOnly => DateFormat('hh:mm a').format(this);
  String get dayMonth => DateFormat('d MMM').format(this);
  String get iso => toIso8601String();

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  String get relative {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    return formatted;
  }
}

// Num extensions
extension NumExtensions on num {
  String get currency => NumberFormat.currency(
        symbol: 'K',
        decimalDigits: 2,
      ).format(this);

  String get compact => NumberFormat.compact().format(this);

  String toPercent([int decimals = 0]) => '${toStringAsFixed(decimals)}%';
}

// List extensions
extension ListExtensions<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;

  List<T> separatedBy(T separator) {
    if (isEmpty) return [];
    final result = <T>[];
    for (var i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) result.add(separator);
    }
    return result;
  }
}
