import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jewel_swipe/providers/block.dart';
import 'package:provider/provider.dart';

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

    final blockProvider = Provider.of<BlockProvider>(context, listen: false);

    blockProvider.stackedRowBlocksWidget =
        Column(children: blockProvider.stackedRowBlocks);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      blockProvider.startGame(context);
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
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[600],
        elevation: 0,
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.arrow_back_ios),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Consumer<BlockProvider>(builder: (context, blockProvider, _) {
            return Column(
              children: [
                const Spacer(),
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Column(
                      children: List.generate(
                        blockProvider.pixelArray.length,
                        (i) => Row(
                          children: List.generate(
                            blockProvider.pixelArray[i].length,
                            (j) => blockProvider.pixelArray[i][j],
                          ),
                        ),
                      ),
                    ),
                    blockProvider.stackedRowBlocksWidget,
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
                        child: blockProvider.nextRowBlock,
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
                /* Row(
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
                              blockProvider.onTap(context);
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
               */
              ],
            );
          }),
        ),
      ),
    );
  }
}
