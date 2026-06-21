import 'package:flutter/material.dart';

Size feedbackSizeForHandle(BuildContext context, double tileWidth) {
  RenderBox? box = context.findRenderObject() as RenderBox?;
  while (box != null) {
    final parent = box.parent;
    if (parent is RenderBox &&
        parent.hasSize &&
        parent.size.width >= tileWidth - 2) {
      return Size(tileWidth, parent.size.height);
    }
    box = parent is RenderBox ? parent : null;
  }
  return Size(tileWidth, kMinInteractiveDimension);
}

/// Positions the drag preview so the grab handle stays under the pointer and
/// the rest of the tile extends to the left.
DragAnchorStrategy handleDragAnchorStrategy(double tileWidth) {
  return (Draggable<Object> draggable, BuildContext context, Offset position) {
    final handleBox = context.findRenderObject()! as RenderBox;
    final touchOnHandle = handleBox.globalToLocal(position);
    final feedbackSize = feedbackSizeForHandle(context, tileWidth);

    final anchorX =
        feedbackSize.width - handleBox.size.width + touchOnHandle.dx;
    final anchorY =
        (feedbackSize.height - handleBox.size.height) / 2 + touchOnHandle.dy;

    return Offset(anchorX, anchorY);
  };
}
