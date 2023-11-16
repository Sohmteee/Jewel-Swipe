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
        rowInts: rowNumbers,
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
        rowInts: rowNumbers,
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

void activateGravity() {
  // loop through the stack from the bottom
  for (int rowBlockIndex = stackedRowBlockInts.length - 2;
      rowBlockIndex >= 0;
      rowBlockIndex--) {
    List<Map<String, dynamic>> rowBlockInts =
        stackedRowBlockInts[rowBlockIndex];
    int position = 0;

    // loop through each of the blocks in the current row
    for (int blockIndex = 0; blockIndex < rowBlockInts.length; blockIndex++) {
      int rowBlockInt = rowBlockInts[blockIndex]["blockWidth"];

      // go to the next block if it's an empty one
      if (rowBlockInt == 0) {
        print("continued");
        position += 1;
        continue;
      }

      print("Current position: $position");

      // find the block right under the current block
      List<Map<String, dynamic>> bottomRowBlockInts =
          stackedRowBlockInts[rowBlockIndex + 1];

      int bottomBlock = 0;
      int bottomBlockIndex = 0;
      int bottomPosition = 0;

      for (int i = 0; i < bottomRowBlockInts.length; i++) {
        if (bottomPosition +
                (bottomRowBlockInts[i]["blockWidth"] == 0
                    ? 1
                    : bottomRowBlockInts[i]["blockWidth"]) <=
            position) {
          bottomPosition += bottomRowBlockInts[i]["blockWidth"] == 0
              ? 1
              : int.parse(bottomRowBlockInts[i]["blockWidth"].toString());
        } else {
          bottomBlockIndex = i;
          break;
        }
      }

      print("Bottom Block Index: $bottomBlockIndex");

      // calculate the position of the row block int
      position += (rowBlockInt == 0) ? 1 : rowBlockInt;

      bottomBlock = bottomRowBlockInts[bottomBlockIndex]["blockWidth"];

      // check if the pixel under it is empty
      if (bottomBlock == 0) {
        print("Bottom is empty");

        //check if the block can drop
        bool canDrop = checkCanDrop(
          rowBlockInt: rowBlockInt,
          bottomBlock: bottomBlock,
          bottomBlockIndex: bottomBlockIndex,
          bottomRowBlockInts: bottomRowBlockInts,
        );

        if (canDrop) {
          // drop the block
          print("Dropping block");
          Map<String, dynamic> droppingBlock = rowBlockInts[blockIndex];

          //replace the remaning parts of the block with zeros
          rowBlockInts[blockIndex] = {
            "blockWidth": 0,
            "color": Colors.transparent
          };
          for (int i = 0; i < droppingBlock["blockWidth"] - 1; i++) {
            rowBlockInts.insert(
                blockIndex, {"blockWidth": 0, "color": Colors.transparent});
          }

          // update the bottom row block ints
          for (int i = bottomBlockIndex;
              i < bottomBlockIndex + droppingBlock["blockWidth"];
              i++) {
            bottomRowBlockInts.removeAt(bottomBlockIndex);
          }
          bottomRowBlockInts.insert(bottomBlockIndex, droppingBlock);

          print(stackedRowBlockInts);

          // activate gravity again
          activateGravity();
        }
      }
    }
  }

  Future.delayed(400.milliseconds, () {
    setState(() {
      stackedRowBlocks = [];
      for (List<Map<String, dynamic>> rowBlockInts in stackedRowBlockInts) {
        stackedRowBlocks.add(
          buildBlockRow(
            context,
            stackIndex: stackedRowBlocks.length,
            rowBlockInts: rowBlockInts,
          ),
        );
      }

      // check if a row is complete
      Future.delayed(400.milliseconds, () {
        setState(() {
          int count = 0;

          // loop through the stack from the bottom
          for (int i = stackedRowBlockInts.length - 1; i >= 0; i--) {
            List<Map<String, dynamic>> rowBlockInts = stackedRowBlockInts[i];

            // check if the row contains any empty pixel
            // if it doesn't, remove the row and activate gravity again
            if (rowBlockInts.any((element) => element["blockWidth"] == 0)) {
              continue;
            } else {
              // remove the row
              stackedRowBlockInts.removeAt(i);
              stackedRowBlocks.removeAt(i);
              count += 1;

              // activate gravity again
              activateGravity();
            }
          }

          for (int i = 0; i < count; i++) {
            if (stackedRowBlockInts.length < 12) {
              Future.delayed(500.milliseconds, () {
                setState(() {
                  currentRowBlockInts = nextRowBlockInts;
                  currentRowBlock = nextRowBlock;

                  stackedRowBlockInts.add(currentRowBlockInts);
                  animateAddBlocks();
                  print(stackedRowBlockInts);

                  nextRowBlockInts = generateRowInts();
                  nextRowBlock = buildBlockRow(
                    context,
                    stackIndex: -1,
                    rowBlockInts: nextRowBlockInts,
                  );

                  if (stackedRowBlockInts.length > 1) {
                    activateGravity();
                  }
                });
              });
            } else {
              startGame();
            }
          }
        });
      });
    });
  });
}

