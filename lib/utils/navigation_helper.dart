import 'package:flutter/cupertino.dart';

/// Shared route factory for consistent, smooth horizontal page transitions.
Route<T> appRoute<T>(Widget page) {
  return CupertinoPageRoute<T>(
    builder: (_) => page,
  );
}
