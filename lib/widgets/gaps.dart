import 'package:flutter/material.dart';

// Simple gap function for vertical spacing
SizedBox gap(double height) {
  return SizedBox(height: height);
}

// Simple gap function for horizontal spacing
SizedBox hGap(double width) {
  return SizedBox(width: width);
}

// Gap with specific height using EdgeInsets
EdgeInsets gapEdgeInsets(double gap) {
  return EdgeInsets.all(gap);
}

// Vertical gap using EdgeInsets
EdgeInsets vGap(double gap) {
  return EdgeInsets.symmetric(vertical: gap);
}

// Horizontal gap using EdgeInsets
EdgeInsets hGapEdgeInsets(double gap) {
  return EdgeInsets.symmetric(horizontal: gap);
}
