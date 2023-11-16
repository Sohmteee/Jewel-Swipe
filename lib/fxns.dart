import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jewel_swipe/models/block.dart';
import 'package:jewel_swipe/variables.dart';

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

Row buildBlockRow(BuildContext context, {required int stackIndex,
    required List<Map<String, dynamic>> rowBlockInts}) {
  List<Widget> rowBlocks = [];

  List<int> rowNumbers = List.generate(
    rowBlockInts.length,
    (index) => rowBlockInts[index]["blockWidth"],
  );

  for (int i = 0; i < rowBlockInts.length; i++) {
    var block = rowBlockInts[i];
    if (block["blockWidth"] == 0) {
      var rowBlock = Block(
        context,
        rowIndex: i,
        stackIndex: stackIndex,
        rowBlockInts: rowBlockInts,
        height: stackIndex == -1 ? 5.h : null,
        blockWidth: 1,
        color: Colors.transparent,
        mass: BlockMass.empty,
      );
      rowBlock.initializeBlock(blockColor: Colors.transparent);
      rowBlocks.add(rowBlock.blockWidget!);
    } else {
      var rowBlock = Block(
        context,
        rowIndex: i,
        stackIndex: stackIndex,
        rowBlockInts: rowNumbers,
        blockWidth: block["blockWidth"],
        color: block["color"],
        mass: BlockMass.filled,
      );
      rowBlock.initializeBlock(blockColor: block["color"]);
      rowBlocks.add(rowBlock.blockWidget!);
    }
  }

  return Row(children: rowBlocks);
}


