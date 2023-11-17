import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jewel_swipe/fxns.dart';
import 'package:jewel_swipe/models/pixel.dart';
import 'package:jewel_swipe/variables.dart';

class BlockProvider extends ChangeNotifier {
  List<Row> stackedRowBlocks = [];
  List<List<Map<String, dynamic>>> stackedRowBlockValues = [];
  List<Map<String, dynamic>> currentRowBlockInts = [], nextRowBlockInts = [];
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
  int count = 0;

  void animateAddBlocks() {
    Future.delayed(0.milliseconds, () {
      stackedRowBlocks.add(currentRowBlock);
      print(stackedRowBlockValues);
      notifyListeners();
    });
  }

  void onTap(BuildContext context) {
    if (stackedRowBlockValues.length < 12) {
      currentRowBlockInts = nextRowBlockInts;
      currentRowBlock = nextRowBlock;

      animateAddBlocks();
      stackedRowBlocksWidget = Column(children: stackedRowBlocks);

      nextRowBlockInts = generateRowInts();
      nextRowBlock = buildBlockRow(
        context,
        stackIndex: -1,
        rowBlockInts: nextRowBlockInts,
      );

      stackedRowBlockValues.add(currentRowBlockInts);

      print(
          "Stacked Row Block Values: ${List.generate(stackedRowBlockValues.length, (index) => stackedRowBlockValues[index][0])}");

      if (stackedRowBlockValues.length > 1) {
        print("activating gravity");
        activateGravity(context);
      }

      stackedRowBlocksWidget = Column(children: stackedRowBlocks);
    } else {
      startGame(context);
    }
    notifyListeners();
  }

  void activateGravity(BuildContext context) {
    print("activating gravity");

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
          print("continued");
          position += 1;
          continue;
        }

        print("Current position: $position");

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

            // activate gravity again
            activateGravity(context);
          }
        }
      }
    }

    Future.delayed(400.milliseconds, () {
      stackedRowBlocks = [];
      for (List<Map<String, dynamic>> rowBlockInts in stackedRowBlockValues) {
        stackedRowBlocks.add(
          buildBlockRow(
            context,
            stackIndex: stackedRowBlocks.length,
            rowBlockInts: rowBlockInts,
          ),
        );
      }
      stackedRowBlocksWidget = Column(children: stackedRowBlocks);
      notifyListeners();

      // check if a row is complete
      Future.delayed(400.milliseconds, () {
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
            count += 1;

            // activate gravity again
            activateGravity(context);
          }
        }

        for (int i = 0; i < count; i++) {
          if (stackedRowBlockValues.length < 12) {
            Future.delayed(500.milliseconds, () {
              currentRowBlockInts = nextRowBlockInts;
              currentRowBlock = nextRowBlock;

              animateAddBlocks();
              stackedRowBlocksWidget = Column(children: stackedRowBlocks);

              nextRowBlockInts = generateRowInts();
              nextRowBlock = buildBlockRow(
                context,
                stackIndex: -1,
                rowBlockInts: nextRowBlockInts,
              );

              if (stackedRowBlockValues.length > 1) {
                activateGravity(context);
              }
              notifyListeners();
            });
          } else {
            startGame(context);
          }
        }
        count = 0;

        notifyListeners();
      });
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
      print("Can drop");
      return true;
    }
    print("Can't drop");
    return false;
  }

  startGame(BuildContext context) {
    // currentBlock.initializeBlock();
    // currentBlock.rotate(currentBlock);

    currentRowBlockInts = generateRowInts();
    currentRowBlock = buildBlockRow(
      context,
      stackIndex: stackedRowBlocks.length,
      rowBlockInts: currentRowBlockInts,
    );

    nextRowBlockInts = generateRowInts();
    nextRowBlock = buildBlockRow(
      context,
      stackIndex: -1,
      rowBlockInts: nextRowBlockInts,
    );

    stackedRowBlockValues = [];
    stackedRowBlocks = [];

    animateAddBlocks();
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
