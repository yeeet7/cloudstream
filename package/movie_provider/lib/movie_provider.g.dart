// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_provider.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovieInfoAdapter extends TypeAdapter<MovieInfo> {
  @override
  final int typeId = 0;

  @override
  MovieInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MovieInfo(
      movie: fields[0] as bool,
      title: fields[1] as String?,
      id: fields[2] as int?,
      year: fields[3] as String?,
      poster: fields[4] as String?,
      desc: fields[6] as String?,
      genres: (fields[7] as List?)?.cast<int>(),
      cast: (fields[8] as List?)?.cast<String?>(),
      rating: fields[9] as num?,
      banner: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MovieInfo obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.movie)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.year)
      ..writeByte(4)
      ..write(obj.poster)
      ..writeByte(5)
      ..write(obj.banner)
      ..writeByte(6)
      ..write(obj.desc)
      ..writeByte(7)
      ..write(obj.genres)
      ..writeByte(8)
      ..write(obj.cast)
      ..writeByte(9)
      ..write(obj.rating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
