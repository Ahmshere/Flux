// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rates_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RatesModelAdapter extends TypeAdapter<RatesModel> {
  @override
  final int typeId = 0;

  @override
  RatesModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RatesModel(
      rates: (fields[0] as Map).cast<String, double>(),
      timestamp: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RatesModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.rates)
      ..writeByte(1)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RatesModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
