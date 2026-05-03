import 'package:hive/hive.dart';

part 'history_model.g.dart';

@HiveType(typeId: 1)
class HistoryEntry extends HiveObject {
  @HiveField(0)
  final String fromCode;

  @HiveField(1)
  final String toCode;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final double result;

  @HiveField(4)
  final double rate;

  @HiveField(5)
  final int timestamp; // Unix ms

  HistoryEntry({
    required this.fromCode,
    required this.toCode,
    required this.amount,
    required this.result,
    required this.rate,
    required this.timestamp,
  });

  DateTime get dateTime =>
      DateTime.fromMillisecondsSinceEpoch(timestamp);
}
