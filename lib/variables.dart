import 'package:jewel_swipe/models/pixel.dart';

int rowLength = 8;
int columnLength = 12;

enum Directions {
  left,
  right,
  down,
}

enum PieceLength {
  one,
  two,
  three,
  four,
}

enum BlockMass {
  empty,
  filled,
}

List<Pixel> pixelList = [];
