import 'dart:async';
import 'dart:io' as io;

import 'package:mansion/mansion.dart';

void printResult(Map<String, int> result) {
  io.stdout.writeAnsi(SetStyles(Style.foreground(Color.red)));
  result.forEach((key, value) {
    print("$key: $value");
  });
  io.stdout.writeAnsi(SetStyles.reset);
}

void printIntermediate(Map<String, int> result) {
  io.stdout.writeAnsi(CursorPosition.save);
  io.stdout.writeAnsi(CursorPosition.moveDown(result.length));
  io.stdout.writeAnsi(CursorPosition.resetColumn);
  io.stdout.writeAnsi(SetStyles(Style.foreground(Color.green)));
  io.stdout.write("${result.keys.last}:");
  io.stdout.writeAnsi(SetStyles(Style.foreground(Color.white)));
  io.stdout.write(" ${result.values.last}");
  io.stdout.writeAnsi(SetStyles.reset);
  io.stdout.writeAnsi(CursorPosition.restore);
}

/// delay in milliseconds
void progressPrint(int delay) {
  // final cursorChars = ['-', '\\', '|', '/', '-', '\\', '|', '/'];
  final cursorChars = ['󱑖', '󱑋', '󱑌', '󱑍', '󱑎', '󱑏', '󱑐', '󱑑', '󱑒', '󱑓', '󱑔', '󱑕'];
  var cursorIndex = 0;
  var elapsed = 0;
  final multiple = 1000 / delay;
  io.stdout.writeAnsi(SetStyles(Style.foreground(Color.blue)));
  io.stdout.write("[ ");
  io.stdout.writeAnsi(SetStyles.reset);
  while (true) {
    io.sleep(Duration(milliseconds: delay));
    elapsed++;
    final ({String toPrint, Color color}) output = switch (elapsed) {
      int e when e % (60 * multiple) == 0 => (toPrint: "\b[${(e / (60 * multiple)).round()}m] ", color: Color.brightYellow),
      int e when e % (30 * multiple) == 0 => (
          toPrint: "\b[${switch ((e / (60 * multiple)).floor()) { int e when e >= 1 => e, _ => "" }}½m] ",
          color: Color.brightYellow
        ),
      int e when e % (10 * multiple) == 0 => (toPrint: "\b| ", color: Color.brightBlue),
      int e when e % (5 * multiple) == 0 => (toPrint: "\b¡ ", color: Color.blue),
      int e when e % (1 * multiple) == 0 => (toPrint: "\b. ", color: Color.yellow),
      _ => (toPrint: "\b${cursorChars[cursorIndex]}", color: Color.brightMagenta),
    };
    io.stdout.writeAnsi(SetStyles(Style.foreground(Color.blue)));
    io.stdout.write("]\b");
    io.stdout.writeAnsi(SetStyles(Style.foreground(output.color)));
    io.stdout.write(output.toPrint);
    io.stdout.writeAnsi(SetStyles.reset);
    cursorIndex = (cursorIndex + 1) % cursorChars.length;
  }
}

Completer<T> wrapInCompleter<T>(Future<T> future) {
  final completer = Completer<T>();
  future.then(completer.complete).catchError(completer.completeError);
  return completer;
}

int fibonacci(int n) => n < 2 ? n : fibonacci(n - 1) + fibonacci(n - 2);
