import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jewel_swipe/variables.dart';

class Block {
  int pieceWidth;
  BuildContext context;

  Block(
    this.context, {
    required this.pieceWidth,
    this.color,
    required this.mass,
    this.isBeingDragged,
  });

  List<int> position = [];
  Color? color = Colors.yellow;
  BlockMass mass;
  bool? isBeingDragged = false;
  Widget? pieceWidget;

  final List<Color> _colors = [
    Colors.red[300]!,
    Colors.blue[300]!,
    Colors.green[300]!,
    Colors.yellow[300]!,
    Colors.grey[300]!,
    Colors.orange[300]!,
    Colors.pink[300]!,
  ];

  Color generateColor() {
    int index = Random().nextInt(_colors.length);
    return _colors[index];
  }

  void initializeBlock({Color? blockColor}) {
    color = blockColor ?? generateColor();
    buildBlock();

    /* switch (pieceLength) {
      
    } */
  }

  /* Widget enlargedBlockWidget() {
    isBeingDragged = true;
    buildBlock();

    return Block(
      width: pieceWidth,
      isBeingDragged: true,
      mass: BlockMass.filled,
      color: color,
    );
  } */

  void buildBlock() {
    
    double height = (MediaQuery.of(context).size.width - 48.w) / rowLength;
    double width =
        (MediaQuery.of(context).size.width - 48.w) / rowLength * pieceWidth +
            pieceWidth -
            1;

    pieceWidget = (mass == BlockMass.filled)
        ? Container(
            height: height,
            width: width,
            margin: EdgeInsets.all(.5.sp),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5.r),
            ),
          )
        : Container(
            height: height,
            width: width,
            color: Colors.transparent,
            margin: EdgeInsets.all(.5.sp),
          );
  }

  void moveBlock(Directions direction) {
    switch (direction) {
      case Directions.down:
        for (int i = 0; i < position.length; i++) {
          position[i] += rowLength;
        }
        break;
      case Directions.left:
        for (int i = 0; i < position.length; i++) {
          position[i] -= 1;
        }
        break;
      case Directions.right:
        for (int i = 0; i < position.length; i++) {
          position[i] += 1;
        }
        break;

      default:
    }
  }
}
