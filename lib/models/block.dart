import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jewel_swipe/models/block_widget.dart';
import 'package:jewel_swipe/variables.dart';

class Block {
  Block(
    this.context, {
    required this.rowIndex,
    required this.stackIndex,
    required this.rowInts,
    required this.blockWidth,
    this.color,
    this.height,
    required this.mass,
    this.isBeingDragged,
  });

  BuildContext context;
  int rowIndex;
  int stackIndex;
  List<int> rowInts;
  int blockWidth;
  // List<int> position = [];
  Color? color;
  double? height;
  BlockMass mass;
  bool? isBeingDragged = false;
  Widget? blockWidget;

  void initializeBlock({required Color blockColor}) {
    color = blockColor;
    buildBlock();

    /* switch (pieceLength) {
      
    } */
  }

  /* Widget enlargedBlockWidget() {
    isBeingDragged = true;
    buildBlock();

    return Block(
      width: width,
      isBeingDragged: true,
      mass: BlockMass.filled,
      color: color,
    );
  } */

  void buildBlock() {

   blockWidget = BlockWidget(
      rowIndex: rowIndex,
      stackIndex: stackIndex,
      rowInts: rowInts,
      height: height,
      blockWidth: blockWidth,
      color: color,
      mass: mass,
    );
  }

  void moveBlock(Directions direction) {
    /* switch (direction) {
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
    } */
  }
}
