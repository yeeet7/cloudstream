
import 'package:vidsrc_extractor/vidsrc_extractor.dart' as vidsrc;

void main() async {

  int tmdbId = 573435;
  int? season;
  int? episode;

  print(vidsrc.vidsrc(tmdbId.toString(), season, episode));

}