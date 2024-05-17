import 'package:timeago/timeago.dart';

// Override "en" locale messages with custom messages that are more precise and short
// setLocaleMessages('en', ReceiptsCustomMessages())

// my_custom_messages.dart
class ReceiptsCustomMessages implements LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'agora';
  @override
  String aboutAMinute(int minutes) => '$minutes m atrás';
  @override
  String minutes(int minutes) => '$minutes m atrás';
  @override
  String aboutAnHour(int minutes) => '$minutes m atrás';
  @override
  String hours(int hours) => '$hours h atrás';
  @override
  String aDay(int hours) => '$hours h atrás';
  @override
  String days(int days) => '$days d atrás';
  @override
  String aboutAMonth(int days) => '$days d atrás';
  @override
  String months(int months) => '$months meses atrás';
  @override
  String aboutAYear(int year) => '$year ano atrás';
  @override
  String years(int years) => '$years anos atrás';
  @override
  String wordSeparator() => ' ';
}
