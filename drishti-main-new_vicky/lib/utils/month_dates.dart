List<DateTime> getDatesInMonth(int month) {
  DateTime now = DateTime.now();
  // Map of days in each month, considering non-leap years
  Map<int, int> daysInMonth = {
    1: 31,
    2: 28,
    3: 31,
    4: 30,
    5: 31,
    6: 30,
    7: 31,
    8: 31,
    9: 30,
    10: 31,
    11: 30,
    12: 31,
  };

  // Check if it's February and a leap year
  if (month == 2) {
    // Assuming leap years are divisible by 4
    // Leap year condition: year % 4 == 0
    // For simplicity, let's assume year = 2024
    // Adjusting days for February
    daysInMonth[2] = 29;
  }

  List<DateTime> datesInMonth = [];
  for (int day = 1; day <= daysInMonth[month]!; day++) {
    DateTime date = DateTime(2024, month, day);
    // if (date.isAfter(now.subtract(Duration(days: 1)))) {

    // }
    datesInMonth.add(date);
  }
  return datesInMonth;
}
