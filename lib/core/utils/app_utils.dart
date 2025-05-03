
import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  static String formatDateWithDay(DateTime dateTime) {
    return DateFormat('EEEE, dd MMM yyyy').format(dateTime);
  }

  static DateTime startOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static DateTime endOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59);
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static DateTime previousMonth(DateTime dateTime) {
    if (dateTime.month == 1) {
      return DateTime(dateTime.year - 1, 12, dateTime.day);
    } else {
      return DateTime(dateTime.year, dateTime.month - 1, dateTime.day);
    }
  }

  static DateTime nextMonth(DateTime dateTime) {
    if (dateTime.month == 12) {
      return DateTime(dateTime.year + 1, 1, dateTime.day);
    } else {
      return DateTime(dateTime.year, dateTime.month + 1, dateTime.day);
    }
  }
}
