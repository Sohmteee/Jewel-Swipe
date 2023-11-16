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

    Column buildStackedRowBlocks(List<Row> stackedRowBlocks) {
      return Column(children: stackedRowBlocks);
    }

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
                  buildStackedRowBlocks(stackedRowBlocks)
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
