import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jewel_swipe/variables.dart';

// ignore: must_be_immutable
class Pixel extends StatefulWidget {
  Pixel({
    super.key,
    required this.color,
    this.child,
    this.x,
    this.y,
  });
  Color? color;
  var child;
  double? x, y;

  @override
  State<Pixel> createState() => _PixelState();
}

class _PixelState extends State<Pixel> {
  late Offset _offset;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        final renderBox = context.findRenderObject() as RenderBox;
        _offset = renderBox.globalToLocal(Offset.zero);

        widget.x = (MediaQuery.of(context).size.width + (_offset.dx)) - 30.w;
        widget.y = (MediaQuery.of(context).size.height + (_offset.dy)) - 80.h;
      });

      pixelList.add(widget);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pixelSize = (MediaQuery.of(context).size.width - 48.w) / 8;

    return DragTarget(
      builder: (context, candidateItems, rejectedItems) {
        return Container(
          height: pixelSize,
          width: pixelSize,
          margin: EdgeInsets.all(.25.sp),
          decoration: BoxDecoration(
            color: widget.color ?? Colors.grey[300],
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: widget.child == null
              ? null
              : Center(
                  child: Text(
                    widget.child.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
        );
      },
    );
  }
}
