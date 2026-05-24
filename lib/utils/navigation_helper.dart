import 'package:flutter/cupertino.dart';

Route<T> appRoute<T>(Widget page) {
  return CupertinoPageRoute<T>(
    builder: (_) => page,
  );
}
