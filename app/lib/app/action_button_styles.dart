import "package:flutter/material.dart";

/// プランクのスタート・一時停止など、主要操作ボタンの共通サイズ。
const double kActionButtonHeight = 56;
const double kActionButtonMinWidth = 140;

const TextStyle kActionButtonTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

Widget actionFilledButton({
  required VoidCallback? onPressed,
  required Widget child,
  double? width,
}) {
  return SizedBox(
    width: width,
    height: kActionButtonHeight,
    child: FilledButton(
      onPressed: onPressed,
      child: child,
    ),
  );
}

Widget actionOutlinedButton({
  required VoidCallback? onPressed,
  required Widget child,
  double? width,
}) {
  return SizedBox(
    width: width,
    height: kActionButtonHeight,
    child: OutlinedButton(
      onPressed: onPressed,
      child: child,
    ),
  );
}
