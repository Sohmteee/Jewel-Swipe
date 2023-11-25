import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jewel_swipe/variables.dart';

import '../fxns.dart';
import '../models/block_widget.dart';
import '../models/pixel.dart';

class BlockProvider extends ChangeNotifier {
  List<Row> stackedRowBlocks = [];
  List<List<Map<String, dynamic>>> stackedRowBlockValues = [];
  List<Map<String, dynamic>> currentRowBlockValues = [], nextRowBlockInts = [];
  Row currentRowBlock = const Row(), nextRowBlock = const Row();
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

  late Column stackedRowBlocksWidget;

  // int count = 0;

  void animateAddBlocks(BuildContext context) {
    double height = (MediaQuery.of(context).size.width - 48.w) / rowLength;
    List<Row> stackedRowBlocksAsList = [];

    for (int stackIndex = 0;
        stackIndex < stackedRowBlockValues.length;
        stackIndex++) {
      List<Map<String, dynamic>> rowBlockValues =
          stackedRowBlockValues[stackIndex];
      List<Widget> rowBlockAsList = [];

      for (int rowIndex = 0; rowIndex < rowBlockValues.length; rowIndex++) {
        var blockValues = rowBlockValues[rowIndex];

        final blockWidget = Block(
          rowIndex: rowIndex,
          stackIndex: stackIndex,
          rowBlockValues: rowBlockValues,
          blockWidth: blockValues["blockWidth"],
          mass: blockValues["blockWidth"] == 0
              ? BlockMass.empty
              : BlockMass.filled,
          color: blockValues["color"],
        ).animate().moveY(
              begin: 0,
              end: height,
              duration: 200.milliseconds,
              curve: Curves.easeInOut,
            );

        rowBlockAsList.add(blockWidget);
      }

      stackedRowBlocksAsList.add(
        Row(
          children: rowBlockAsList,
        ),
      );
    }

    stackedRowBlocks = List.generate(
      stackedRowBlocksAsList.length,
      (index) => stackedRowBlocksAsList[index],
    );

    Future.delayed(200.milliseconds, () {
      stackedRowBlockValues.add(currentRowBlockValues);
      stackedRowBlocks.add(currentRowBlock);
      if (kDebugMode) {
        print(
          List.generate(
            stackedRowBlockValues.length,
            (i) => List.generate(
              stackedRowBlockValues[i].length,
              (j) => stackedRowBlockValues[i][j]["blockWidth"],
            ),
          ),
        );
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void onTap(BuildContext context) {
    if (stackedRowBlockValues.length < 12) {
      currentRowBlockValues = nextRowBlockInts;
      currentRowBlock = nextRowBlock;

      animateAddBlocks(context);
      stackedRowBlocksWidget = Column(children: stackedRowBlocks);

      nextRowBlockInts = generateRowInts();
      nextRowBlock = buildBlockRow(
        context,
        stackIndex: -1,
        rowBlockInts: nextRowBlockInts,
      );

      if (kDebugMode) {
        print(
            "Stacked Row Block Values: ${List.generate(stackedRowBlockValues.length, (i) => List.generate(stackedRowBlockValues[i].length, (j) => stackedRowBlockValues[i][j]["blockWidth"]))}");
      }

      if (stackedRowBlockValues.length > 1) {
        if (kDebugMode) {
          print("activating gravity");
        }
        activateGravity(context);
      }

      stackedRowBlocksWidget = Column(children: stackedRowBlocks);
    } else {
      startGame(context);
    }
    notifyListeners();
  }

  void activateGravity(BuildContext context) {
    if (kDebugMode) {
      print("activating gravity");
    }

    // loop through the stack from the bottom
    for (int rowBlockIndex = stackedRowBlockValues.length - 2;
        rowBlockIndex >= 0;
        rowBlockIndex--) {
      List<Map<String, dynamic>> rowBlockInts =
          stackedRowBlockValues[rowBlockIndex];
      int position = 0;

      // loop through each of the blocks in the current row
      for (int blockIndex = 0; blockIndex < rowBlockInts.length; blockIndex++) {
        int rowBlockInt = rowBlockInts[blockIndex]["blockWidth"];

        // go to the next block if it's an empty one
        if (rowBlockInt == 0) {
          /*if (kDebugMode) {
            print("continued");
          }*/
          position += 1;
          continue;
        }

        /*if (kDebugMode) {
          print("Current position: $position");
        }*/

        // find the block right under the current block
        List<Map<String, dynamic>> bottomRowBlockInts =
            stackedRowBlockValues[rowBlockIndex + 1];

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

        /*if (kDebugMode) {
          print("Bottom Block Index: $bottomBlockIndex");
        }*/

        // calculate the position of the row block int
        position += (rowBlockInt == 0) ? 1 : rowBlockInt;

        bottomBlock = bottomRowBlockInts[bottomBlockIndex]["blockWidth"];

        // check if the pixel under it is empty
        if (bottomBlock == 0) {
          /*if (kDebugMode) {
            print("Bottom is empty");
          }*/

          //check if the block can drop
          bool canDrop = checkCanDrop(
            rowBlockInt: rowBlockInt,
            bottomBlock: bottomBlock,
            bottomBlockIndex: bottomBlockIndex,
            bottomRowBlockInts: bottomRowBlockInts,
          );

          if (canDrop) {
            // drop the block
            /*if (kDebugMode) {
              print("Dropping block");
            }*/
            Map<String, dynamic> droppingBlock = rowBlockInts[blockIndex];

            //replace the remaining parts of the block with zeros
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

            // activate gravity again
            activateGravity(context);
          }
        }
      }
    }

    stackedRowBlocks = [];
    for (List<Map<String, dynamic>> rowBlockInts in stackedRowBlockValues) {
      if (rowBlockInts.every((rowBlockInt) => rowBlockInt["blockWidth"] == 0)) {
        stackedRowBlockValues.remove(rowBlockInts);
      } else {
        stackedRowBlocks.add(
          buildBlockRow(
            context,
            stackIndex: stackedRowBlocks.length,
            rowBlockInts: rowBlockInts,
          ),
        );
      }
    }

    stackedRowBlocksWidget = Column(children: stackedRowBlocks);
    notifyListeners();

    // check if a row is complete
    Future.delayed(200.milliseconds, () {
      // loop through the stack from the bottom
      for (int i = stackedRowBlockValues.length - 1; i >= 0; i--) {
        List<Map<String, dynamic>> rowBlockInts = stackedRowBlockValues[i];

        // check if the row contains any empty pixel
        // if it doesn't, remove the row and activate gravity again
        if (rowBlockInts.any((element) => element["blockWidth"] == 0)) {
          continue;
        } else {
          // remove the row
          stackedRowBlockValues.removeAt(i);
          stackedRowBlocks.removeAt(i);
          // count += 1;

          // activate gravity again
          activateGravity(context);
        }
      }

      notifyListeners();
    });

    notifyListeners();
  }

  bool checkCanDrop({
    required int rowBlockInt,
    required int bottomBlock,
    required int bottomBlockIndex,
    required List<Map<String, dynamic>> bottomRowBlockInts,
  }) {
    // if it's an empty pixel, check if the remaining parts of the block
    // have a clear bottom to land
    // we can do this by checking how many zeros recurred after the current
    // 0 in the bottom row
    int count = 1;

    while (bottomBlockIndex + count < bottomRowBlockInts.length &&
        bottomRowBlockInts[bottomBlockIndex + count]["blockWidth"] == 0) {
      int index = bottomBlockIndex + count;
      if (bottomRowBlockInts[index]["blockWidth"] == 0) {
        count += 1;
      } else {
        break;
      }
    }

    notifyListeners();

    if (count >= rowBlockInt) {
      /*if (kDebugMode) {
        print("Can drop");
      }*/
      return true;
    }
    // if (kDebugMode) {
    //   print("Can't drop");
    // }
    return false;
  }

  startGame(BuildContext context) {
    // currentBlock.initializeBlock();
    // currentBlock.rotate(currentBlock);

    currentRowBlockValues = generateRowInts();
    currentRowBlock = buildBlockRow(
      context,
      stackIndex: stackedRowBlocks.length,
      rowBlockInts: currentRowBlockValues,
    );

    nextRowBlockInts = generateRowInts();
    nextRowBlock = buildBlockRow(
      context,
      stackIndex: -1,
      rowBlockInts: nextRowBlockInts,
    );

    stackedRowBlockValues = [];
    stackedRowBlocks = [];

    animateAddBlocks(context);
    stackedRowBlocksWidget = Column(children: stackedRowBlocks);

    notifyListeners();
    // stackedRowBlocks.add(currentRowBlock);

    // final frameRate = 800.milliseconds;
    // gameLoop(frameRate);
  }

/* gameLoop(Duration frameRate) {
    /* Timer.periodic(frameRate, (timer) {
      setState(() {
        currentBlock.moveBlock(Directions.down);
      });
    }); */
  } */
}
