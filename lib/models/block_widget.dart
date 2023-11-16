// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jewel_swipe/fxns.dart';
import 'package:jewel_swipe/variables.dart';

class BlockWidget extends StatefulWidget {
  BlockWidget({
    super.key,
    required this.rowIndex,
    required this.stackIndex,
    required this.rowBlockInts,
    required this.blockWidth,
    this.color,
    this.height,
    required this.mass,
    this.isBeingDragged,
    this.blockWidget,
  });

  int rowIndex;
  int stackIndex;
  List<Map<String, dynamic>> rowBlockInts;
  int blockWidth;
  Color? color;
  double? height;
  BlockMass mass;
  bool? isBeingDragged;
  Widget? blockWidget;

  @override
  State<BlockWidget> createState() => _BlockWidgetState();
}

class _BlockWidgetState extends State<BlockWidget> {
  double? left;

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
    double height = (MediaQuery.of(context).size.width - 48.w) / rowLength;
    double width = (MediaQuery.of(context).size.width - 48.w) /
            rowLength *
            widget.blockWidth +
        widget.blockWidth -
        1;

    gameLoop(Duration frameRate) {
      /* Timer.periodic(frameRate, (timer) {
      setState(() {
        currentBlock.moveBlock(Directions.down);
      });
    }); */
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

    void activateGravity() {
      // loop through the stack from the bottom
      for (int rowBlockIndex = stackedRowBlockInts.length - 2;
          rowBlockIndex >= 0;
          rowBlockIndex--) {
        List<Map<String, dynamic>> rowBlockInts =
            stackedRowBlockInts[rowBlockIndex];
        int position = 0;

        // loop through each of the blocks in the current row
        for (int blockIndex = 0;
            blockIndex < rowBlockInts.length;
            blockIndex++) {
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
                List<Map<String, dynamic>> rowBlockInts =
                    stackedRowBlockInts[i];

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

    if (widget.mass == BlockMass.filled) {
      return Container(
        height: widget.height ?? height,
        width: width,
        margin: EdgeInsets.all(.25.sp),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (widget.isBeingDragged ?? false)
              Container(
                height: height,
                width: width,
                margin: EdgeInsets.all(.5.sp),
                decoration: BoxDecoration(
                  color: widget.color?.withOpacity(.7),
                  borderRadius: BorderRadius.circular(5.r),
                ),
              ),
            Positioned(
              left: left,
              child: GestureDetector(
                onTap: () {
                  // int leftBlocks = widget.rowIndex;
                  // int rightBlocks = widget.rowBlockInts.length - widget.rowIndex - 1;

                  widget.isBeingDragged = true;
                  int leftBlocks = widget.rowIndex;
                  // int rightBlocks = widget.rowBlockInts.length - widget.rowIndex - 1;

                  double leftSpace = 0, rightSpace = 0;

                  // calculate left and right spaces
                  if (widget.rowIndex == 0) {
                    leftSpace = 0;
                  } else {
                    int count = 0;
                    for (int i = leftBlocks - 1; i >= 0; i--) {
                      if (widget.rowBlockInts[i]["blockWidth"] == 0) {
                        leftSpace +=
                            (MediaQuery.of(context).size.width - 48.w) /
                                rowLength;
                        count += 1;
                      } else {
                        break;
                      }
                    }
                    leftSpace += count - 1 < 0 ? 0 : count - 1;
                  }

                  if (widget.rowIndex == widget.rowBlockInts.length - 1) {
                    rightSpace = 0;
                  } else {
                    int count = 0;
                    for (int i = widget.rowIndex + 1;
                        i <= widget.rowBlockInts.length - 1;
                        i++) {
                      if (widget.rowBlockInts[i]["blockWidth"] == 0) {
                        rightSpace +=
                            (MediaQuery.of(context).size.width - 48.w) /
                                rowLength;
                        count += 1;
                      } else {
                        break;
                      }
                    }
                    rightSpace += count - 1 < 0 ? 0 : count - 1;
                  }

                  print("Left Space: $leftSpace");
                  print("Right Space: $rightSpace");
                },
                onPanUpdate: (details) {
                  setState(() {
                    widget.isBeingDragged = true;
                    int leftBlocks = widget.rowIndex;
                    // int rightBlocks =
                    //     widget.rowBlockInts.length - widget.rowIndex - 1;

                    final box = context.findRenderObject() as RenderBox;
                    final position = box.globalToLocal(details.globalPosition);

                    double leftSpace = 0, rightSpace = 0;

                    // calculate left and right spaces
                    if (widget.rowIndex == 0) {
                      leftSpace = 0;
                    } else {
                      int count = 0;
                      for (int i = leftBlocks - 1; i >= 0; i--) {
                        if (widget.rowBlockInts[i]["blockWidth"] == 0) {
                          leftSpace +=
                              (MediaQuery.of(context).size.width - 48.w) /
                                  rowLength;
                          count += 1;
                        } else {
                          break;
                        }
                        leftSpace += count - 1 < 0 ? 0 : count - 1;
                      }
                    }

                    if (widget.rowIndex == widget.rowBlockInts.length - 1) {
                      rightSpace = 0;
                    } else {
                      int count = 0;
                      for (int i = widget.rowIndex + 1;
                          i <= widget.rowBlockInts.length - 1;
                          i++) {
                        if (widget.rowBlockInts[i]["blockWidth"] == 0) {
                          rightSpace +=
                              (MediaQuery.of(context).size.width - 48.w) /
                                  rowLength;
                          count += 1;
                        } else {
                          break;
                        }
                        rightSpace += count - 1 < 0 ? 0 : count - 1;
                      }
                    }

                    if (position.dx > 0) {
                      if (position.dx < rightSpace) {
                        left = position.dx;
                      } else {
                        left = rightSpace;
                      }
                    } else {
                      if (position.dx.abs() < leftSpace) {
                        left = position.dx;
                      } else {
                        left = -leftSpace;
                      }
                    }

                    print(left);

                    /* // highlight position on pixels
                    int boardPosition = 0;
                    List dropPosition = [];

                    for (int i = 0; i < widget.rowIndex; i++) {
                      boardPosition +=
                          widget.rowBlockInts[i] == 0 ? 1 : widget.rowBlockInts[i];
                    }

                    dropPosition = List.generate(widget.blockWidth, (index) {
                      return boardPosition + index;
                    });

                    for (int i = widget.stackIndex; i >= 0; i--) {
                      for (int j = dropPosition[0];
                          j <= dropPosition[dropPosition.length - 1];
                          j++) {
                        setState(() {
                          pixelArray[i][j] = Pixel(
                            color: Colors.white.withOpacity(.5),
                            // child: ("$columnIndex, $rowIndex"),
                          );
                        });
                      }
                    } */

                    if (position.dx > 0) {
                      if (position.dx < rightSpace) {
                      } else {
                        left = rightSpace;
                      }
                    } else {
                      if (position.dx.abs() < leftSpace) {
                        left = position.dx;
                      } else {
                        left = -leftSpace;
                      }
                    }
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    widget.isBeingDragged = false;

                    left ?? 0;

                    print("Left: $left");
                    print("Width: $height");
                    int shift = (left! / height).round();
                    print(shift);

                    left = shift * height;

                    widget.rowBlockInts.removeAt(widget.rowIndex);
                    widget.rowBlockInts.insert(widget.rowIndex + shift, {
                      "blockWidth": widget.blockWidth,
                      "color": widget.color,
                    });

                    stackedRowBlockInts[widget.stackIndex] =
                        widget.rowBlockInts;

                    stackedRowBlocks = [];
                    for (List<Map<String, dynamic>> rowBlockInts
                        in stackedRowBlockInts) {
                      stackedRowBlocks.add(
                        buildBlockRow(
                          context,
                          stackIndex: stackedRowBlocks.length,
                          rowBlockInts: rowBlockInts,
                        ),
                      );
                    }

                    stackedRowBlocksWidget = Column(children: stackedRowBlocks);

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
                    }
                  });

                  // left = null;
                },
                child: Container(
                  height: height,
                  width: width,
                  margin: EdgeInsets.all(.25.sp),
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: height,
        width: width,
        color: Colors.transparent,
        margin: EdgeInsets.all(.25.sp),
      );
    }
  }
}
