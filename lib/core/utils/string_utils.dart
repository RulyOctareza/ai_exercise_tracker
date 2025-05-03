class StringUtils {
  static String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String truncateWithEllipsis(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String getInitials(String fullName) {
    if (fullName.isEmpty) return '';

    List<String> names = fullName.split(' ');
    String initials = '';

    for (var name in names) {
      if (name.isNotEmpty) {
        initials += name[0];
      }
    }

    return initials.toUpperCase();
  }

  static String formatRepetitions(int count) {
    return '$count ${count == 1 ? 'rep' : 'reps'}';
  }

  static String getFeedbackMessage(int current, int? previous) {
    if (previous == null) {
      return "First Time! Keep Going!";
    } else if (current > previous) {
      return "Awesome Progress!";
    } else if (current == previous) {
      return "Good Job, Keep Consistent!";
    } else {
      return "Need More Effort!";
    }
  }
}
