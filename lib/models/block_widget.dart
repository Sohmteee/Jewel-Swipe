// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jewel_swipe/fxns.dart';
import 'package:jewel_swipe/variables.dart';

class BlockWidget extends StatefulWidget {
  BlockWidget({
    super.key,
    required this.rowIndex,
    required this.stackIndex,
    required this.rowInts,
    required this.blockWidth,
    this.color,
    this.height,
    required this.mass,
    this.isBeingDragged,
    this.blockWidget,
  });

  int rowIndex;
  int stackIndex;
  List<int> rowInts;
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

  @override
  Widget build(BuildContext context) {
    double height = (MediaQuery.of(context).size.width - 48.w) / rowLength;
    double width = (MediaQuery.of(context).size.width - 48.w) /
            rowLength *
            widget.blockWidth +
        widget.blockWidth -
        1;

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
                  // int rightBlocks = widget.rowInts.length - widget.rowIndex - 1;

                  widget.isBeingDragged = true;
                  int leftBlocks = widget.rowIndex;
                  // int rightBlocks = widget.rowInts.length - widget.rowIndex - 1;

                  double leftSpace = 0, rightSpace = 0;

                  // calculate left and right spaces
                  if (widget.rowIndex == 0) {
                    leftSpace = 0;
                  } else {
                    int count = 0;
                    for (int i = leftBlocks - 1; i >= 0; i--) {
                      if (widget.rowInts[i] == 0) {
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

                  if (widget.rowIndex == widget.rowInts.length - 1) {
                    rightSpace = 0;
                  } else {
                    int count = 0;
                    for (int i = widget.rowIndex + 1;
                        i <= widget.rowInts.length - 1;
                        i++) {
                      if (widget.rowInts[i] == 0) {
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
                    //     widget.rowInts.length - widget.rowIndex - 1;

                    final box = context.findRenderObject() as RenderBox;
                    final position = box.globalToLocal(details.globalPosition);

                    double leftSpace = 0, rightSpace = 0;

                    // calculate left and right spaces
                    if (widget.rowIndex == 0) {
                      leftSpace = 0;
                    } else {
                      int count = 0;
                      for (int i = leftBlocks - 1; i >= 0; i--) {
                        if (widget.rowInts[i] == 0) {
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

                    if (widget.rowIndex == widget.rowInts.length - 1) {
                      rightSpace = 0;
                    } else {
                      int count = 0;
                      for (int i = widget.rowIndex + 1;
                          i <= widget.rowInts.length - 1;
                          i++) {
                        if (widget.rowInts[i] == 0) {
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
                          widget.rowInts[i] == 0 ? 1 : widget.rowInts[i];
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

                    widget.rowInts.removeAt(widget.rowIndex);
                    widget.rowInts
                        .insert(widget.rowIndex + shift, widget.blockWidth);

                    stackedRowBlockInts[widget.stackIndex] = widget.rowInts
                        .map((rowInt) => {
                              "blockWidth": widget.blockWidth,
                              "color": widget.color,
                            })
                        .toList();

                    /* if (stackedRowBlockInts.length < 12) {
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
                    } */

                    left = null;
                  });
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
