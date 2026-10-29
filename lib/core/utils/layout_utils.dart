import 'package:flutter/widgets.dart';

const double _captionGap = 10;
const double _titleLine = 20;
const double _subtitleLine = 18;
const double _cellSlack = 4;

// Padding for a scrolling list on a shell tab. The shell reports the floating
// mini player and nav bar as bottom padding, so the last item clears them.
EdgeInsets tabListPadding(BuildContext context, double horizontal) {
  return EdgeInsets.fromLTRB(
      horizontal, 4, horizontal, 8 + MediaQuery.paddingOf(context).bottom);
}

// Height of a grid cell holding a square cover with a title and a subtitle
// line under it. The text lines follow the system text scale so large text
// doesn't overflow the cell.
double coverGridCellExtent(BuildContext context, double coverSize) {
  final scaler = MediaQuery.textScalerOf(context);
  return coverSize +
      _captionGap +
      scaler.scale(_titleLine) +
      scaler.scale(_subtitleLine) +
      _cellSlack;
}
