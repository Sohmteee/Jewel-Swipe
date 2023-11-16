import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jewel_swipe/fxns.dart';
import 'package:jewel_swipe/models/block.dart';
import 'package:jewel_swipe/variables.dart';
import 'package:velocity_x/velocity_x.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // late Block currentBlock;
  double? x, y;

  @override
  void initState() {
    super.initState();
    /* currentBlock = Block(
      context,
      blockWidth: Random().nextInt(4) + 1,
      mass: BlockMass.filled,
    ); */

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      startGame();
    });
  }

  startGame() {
    // currentBlock.initializeBlock();
    // currentBlock.rotate(currentBlock);

    setState(() {
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

      stackedRowBlockInts = [];
      stackedRowBlocks = [];
      stackedRowBlockInts.add(currentRowBlockInts);
      animateAddBlocks();
      // stackedRowBlocks.add(currentRowBlock);
    });

    final frameRate = 800.milliseconds;
    gameLoop(frameRate);
  }

  gameLoop(Duration frameRate) {
    /* Timer.periodic(frameRate, (timer) {
      setState(() {
        currentBlock.moveBlock(Directions.down);
      });
    }); */
  }

  void animateAddBlocks() {
    /* stackedRowBlocks.animate().moveY(
          begin: 0,
          end: (MediaQuery.of(context).size.blockWidth - 48.w) / rowLength,
          duration: 400.milliseconds,
          curve: Curves.easeIn,
        ); */
    Future.delayed(0.milliseconds, () {
      setState(() {
        stackedRowBlocks.add(currentRowBlock);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // currentBlock.rotate();
    // currentBlock.initializeBlock();

    /* bool isBlockOverPixel() {
      if (x == null || y == null) {
        return false; // The piece is not being dragged
      }

      List<int> pixelPosition = [];

      // Iterate through the pixels in your game grid
      for (int index = 0; index < pixelList.length; index++) {
        final pixelX = pixelList[index].x!; // Get the x position of the pixel
        final pixelY = pixelList[index].y!; // Get the y position of the pixel
        final pixelSize =
            (MediaQuery.of(context).size.blockWidth - 35.h) / rowLength;

        // Check if the piece overlaps with the current pixel
        if (x! <= pixelX && x! > (pixelX + pixelSize) ||
            y! <= pixelY && y! > (pixelY + pixelSize)) {
          setState(() {
            pixelList[index].color = currentBlock.color;
            pixelPosition.add(index);
          });
          return true; // The piece is over this pixel
        }

        setState(() {
          pixelList[index].color = Colors.grey[900]!.withOpacity(.2);
        });
      }

      print("Pixel position: $pixelPosition");

      return false; // The piece is not over any pixel
    } */

    stackedRowBlocksWidget = Column(children: stackedRowBlocks);

    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Column(
                    children: List.generate(
                      pixelArray.length,
                      (index) => Row(
                        children: List.generate(
                          pixelArray[index].length,
                          (index) => pixelArray[index][index],
                        ),
                      ),
                    ),
                  ),
                  stackedRowBlocksWidget,
                ],
              ),
              SizedBox(height: 5.h),
              SizedBox(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 7.h,
                      width: double.maxFinite,
                      child: nextRowBlock,
                    ),
                    Container(
                      height: 7.h,
                      width: double.maxFinite,
                      color: Colors.transparent,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    /* onPanUpdate: (details) {

                      //move the current piece to the board
                      setState(() {
                        currentBlock.isBeingDragged = true;
                        currentBlock.buildBlock();

                        final box = context.findRenderObject() as RenderBox;
                        final position =
                            box.globalToLocal(details.globalPosition);

                        y = MediaQuery.of(context).size.height - (position.dy);
                        x = MediaQuery.of(context).size.width - (position.dx);

                        print("Block coordinate: $x, $y");

                        isBlockOverPixel();
                      });
                    },
                    onPanEnd: (details) {
                      setState(() {
                        x = null;
                        y = null;

                        currentBlock.isBeingDragged = false;
                        currentBlock.buildBlock();
                      });
                    }, */
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (stackedRowBlockInts.length < 12) {
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
                            } else {
                              startGame();
                            }
                          },
                          child: Container(
                            width: 100.sp,
                            height: 100.sp,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple[800],
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

    if (count >= rowBlockInt) {
      print("Can drop");
      return true;
    }
    print("Can't drop");
    return false;
  }
}
