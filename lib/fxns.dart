import 'dart:math';

import 'package:flutter/material.dart';

List<Map<String, dynamic>> generateRowInts() {
  List<Map<String, dynamic>> row = [];
  List rowNumbers = [];
  int availableSpace = 8;

  final List<Color> colors = [
    Colors.red[300]!,
    Colors.blue[300]!,
    Colors.green[300]!,
    Colors.yellow[300]!,
    Colors.grey[300]!,
    Colors.orange[300]!,
    Colors.pink[300]!,
  ];

  Color generateColor() {
    int index = Random().nextInt(colors.length);
    return colors[index];
  }

  while (availableSpace > 0) {
    if (availableSpace <= 4) {
      if (rowNumbers.contains(0)) {
        int blockWidth = Random().nextInt(availableSpace + 1);
        Color color = generateColor();
        row.add({"blockWidth": blockWidth, "color": color});
        rowNumbers.add(blockWidth);
        availableSpace -= blockWidth == 0 ? 1 : blockWidth;
      } else {
        int blockWidth = 0;
        Color color = Colors.transparent;
        row.add({"blockWidth": blockWidth, "color": color});
        rowNumbers.add(blockWidth);
        availableSpace -= 1;
      }
    } else {
      int blockWidth = Random().nextInt(5);
      Color color = generateColor();
      row.add({"blockWidth": blockWidth, "color": color});
      rowNumbers.add(blockWidth);
      availableSpace -= blockWidth == 0 ? 1 : blockWidth;
    }
  }

  // print("Row: $row");
  return row;
}
