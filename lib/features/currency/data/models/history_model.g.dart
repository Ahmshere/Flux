// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: flutter pub run build_runner build

part of 'history_model.dart';

class HistoryEntryAdapter extends TypeAdapter<HistoryEntry> {
  @override
  final int typeId = 1;

  @override
  HistoryEntry read(BinaryReader reader) {
    final n = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < n; i++) reader.readByte(): reader.read(),
    };
    return HistoryEntry(
      fromCode:  fields[0] as String,
      toCode:    fields[1] as String,
      amount:    fields[2] as double,
      result:    fields[3] as double,
      rate:      fields[4] as double,
      timestamp: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)..write(obj.fromCode)
      ..writeByte(1)..write(obj.toCode)
      ..writeByte(2)..write(obj.amount)
      ..writeByte(3)..write(obj.result)
      ..writeByte(4)..write(obj.rate)
      ..writeByte(5)..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
