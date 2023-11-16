import 'package:flutter/material.dart';
import 'package:jewel_swipe/models/pixel.dart';

List<Row> stackedRowBlocks = [];
List<List<Map<String, dynamic>>> stackedRowBlockInts = [];
List<List<Pixel>> pixelArray = List.generate(
  columnLength,
  (columnIndex) => List.generate(
    rowLength,
    (rowIndex) => Pixel(
      color: Colors.grey[900]!.withOpacity(.2),
      // child: ("$columnIndex, $rowIndex"),
    ),
  ),
);

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

List combinations = [
  [1, 1, 1, 1, 5],
  [1, 1, 1, 2, 4],
  [1, 1, 1, 3, 3],
  [1, 1, 1, 4, 2],
  [1, 1, 1, 5, 1],
  [1, 1, 1, 6],
  [1, 1, 2, 1, 4],
  [1, 1, 2, 2, 3],
  [1, 1, 2, 3, 2],
  [1, 1, 2, 4, 1],
  [1, 1, 2, 5],
  [1, 1, 3, 1, 3],
  [1, 1, 3, 2, 2],
  [1, 1, 3, 3, 1],
  [1, 1, 3, 4],
  [1, 1, 4, 1, 2],
  [1, 1, 4, 2, 1],
  [1, 1, 4, 3],
  [1, 1, 5, 1, 1],
  [1, 1, 5, 2],
  [1, 1, 6, 1],
  [1, 1, 7],
  [1, 2, 1, 1, 4],
  [1, 2, 1, 2, 3],
  [1, 2, 1, 3, 2],
  [1, 2, 1, 4, 1],
  [1, 2, 1, 5],
  [1, 2, 2, 1, 3],
  [1, 2, 2, 2, 2],
  [1, 2, 2, 3, 1],
  [1, 2, 2, 4],
  [1, 2, 3, 1, 2],
  [1, 2, 3, 2, 1],
  [1, 2, 3, 3],
  [1, 2, 4, 1, 1],
  [1, 2, 4, 2],
  [1, 2, 5, 1],
  [1, 2, 6],
  [1, 3, 1, 1, 3],
  [1, 3, 1, 2, 2],
  [1, 3, 1, 3, 1],
  [1, 3, 1, 4],
  [1, 3, 2, 1, 2],
  [1, 3, 2, 2, 1],
  [1, 3, 2, 3],
  [1, 3, 3, 1, 1],
  [1, 3, 3, 2],
  [1, 3, 4, 1],
  [1, 3, 5],
  [1, 4, 1, 1, 2],
  [1, 4, 1, 2, 1],
  [1, 4, 1, 3],
  [1, 4, 2, 1, 1],
  [1, 4, 2, 2],
  [1, 4, 3, 1],
  [1, 4, 4],
  [1, 5, 1, 1, 1],
  [1, 5, 1, 2],
  [1, 5, 2, 1],
  [1, 5, 3],
  [1, 6, 1, 1],
  [1, 6, 2],
  [1, 7, 1],
  [1, 8],
];
