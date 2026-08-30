// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GradeAdapter extends TypeAdapter<Grade> {
  @override
  final int typeId = 9;

  @override
  Grade read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Grade(
      id: fields[0] as String,
      courseId: fields[1] as String,
      title: fields[2] as String,
      type: fields[3] as GradeType,
      score: fields[4] as double?,
      maxScore: fields[5] as double?,
      weight: fields[6] as double,
      date: fields[7] as DateTime,
      notes: fields[8] as String?,
      createdAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Grade obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.courseId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.score)
      ..writeByte(5)
      ..write(obj.maxScore)
      ..writeByte(6)
      ..write(obj.weight)
      ..writeByte(7)
      ..write(obj.date)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GradeTypeAdapter extends TypeAdapter<GradeType> {
  @override
  final int typeId = 8;

  @override
  GradeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GradeType.exam;
      case 1:
        return GradeType.quiz;
      case 2:
        return GradeType.homework;
      case 3:
        return GradeType.project;
      case 4:
        return GradeType.participation;
      case 5:
        return GradeType.other;
      default:
        return GradeType.exam;
    }
  }

  @override
  void write(BinaryWriter writer, GradeType obj) {
    switch (obj) {
      case GradeType.exam:
        writer.writeByte(0);
        break;
      case GradeType.quiz:
        writer.writeByte(1);
        break;
      case GradeType.homework:
        writer.writeByte(2);
        break;
      case GradeType.project:
        writer.writeByte(3);
        break;
      case GradeType.participation:
        writer.writeByte(4);
        break;
      case GradeType.other:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
