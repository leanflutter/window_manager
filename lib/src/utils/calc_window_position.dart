import 'package:flutter/material.dart';
import 'package:screen_retriever/screen_retriever.dart';

Future<Offset> calcWindowPosition(
  Size windowSize,
  Alignment alignment,
) async {
  Display primaryDisplay = await screenRetriever.getPrimaryDisplay();

  num visibleWidth = primaryDisplay.size.width;
  num visibleHeight = primaryDisplay.size.height;
  num visibleStartX = 0;
  num visibleStartY = 0;

  if (primaryDisplay.visibleSize != null) {
    visibleWidth = primaryDisplay.visibleSize!.width;
    visibleHeight = primaryDisplay.visibleSize!.height;
  }
  if (primaryDisplay.visiblePosition != null) {
    visibleStartX = primaryDisplay.visiblePosition!.dx;
    visibleStartY = primaryDisplay.visiblePosition!.dy;
  }
  Offset position = Offset(0, 0);

  if (alignment == Alignment.topLeft) {
    position = Offset(0, 0);
  } else if (alignment == Alignment.topCenter) {
    position = Offset(
      visibleStartX + (visibleWidth / 2) - (windowSize.width / 2),
      visibleStartY + 0,
    );
  } else if (alignment == Alignment.topRight) {
    position = Offset(
      visibleStartX + visibleWidth - windowSize.width,
      visibleStartY + 0,
    );
  } else if (alignment == Alignment.centerLeft) {
    position = Offset(
      visibleStartX + 0,
      visibleStartY + ((visibleHeight / 2) - (windowSize.height / 2)),
    );
  } else if (alignment == Alignment.center) {
    position = Offset(
      visibleStartX + (visibleWidth / 2) - (windowSize.width / 2),
      visibleStartY + ((visibleHeight / 2) - (windowSize.height / 2)),
    );
  } else if (alignment == Alignment.centerRight) {
    position = Offset(
      visibleStartX + visibleWidth - windowSize.width,
      visibleStartY + ((visibleHeight / 2) - (windowSize.height / 2)),
    );
  } else if (alignment == Alignment.bottomLeft) {
    position = Offset(
      visibleStartX + 0,
      visibleStartY + (visibleHeight - windowSize.height),
    );
  } else if (alignment == Alignment.bottomCenter) {
    position = Offset(
      visibleStartX + (visibleWidth / 2) - (windowSize.width / 2),
      visibleStartY + (visibleHeight - windowSize.height),
    );
  } else if (alignment == Alignment.bottomRight) {
    position = Offset(
      visibleStartX + visibleWidth - windowSize.width,
      visibleStartY + (visibleHeight - windowSize.height),
    );
  }

  return position;
}
