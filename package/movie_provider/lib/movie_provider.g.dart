// GENERATED CODE - DO NOT MODIFY BY HAND

part of movie_provider;

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
      title: fields[0] as String?,
      url: fields[1] as String?,
      year: fields[2] as String?,
      image: fields[3] as Image?,
    );
  }

  @override
  void write(BinaryWriter writer, MovieInfo obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.year)
      ..writeByte(3)
      ..write(obj.image);
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
