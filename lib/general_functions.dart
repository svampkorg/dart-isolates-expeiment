import 'dart:async';
import 'dart:io';

void printResult(Map<String, int> result) {
  result.forEach((key, value) {
    print("$key: $value");
  });
}

/// delay in milliseconds
void progressPrint(int delay) {
  final cursorChars = ['-', '\\', '|', '/', '-', '\\', '|', '/'];
  var cursorIndex = 0;
  var elapsed = 0;
  final multiple = 1000 / delay;
  stdout.write("[ ");
  while (true) {
    sleep(Duration(milliseconds: delay));
    elapsed++;
    String toPrint = switch (elapsed) {
      int e when e % (60 * multiple) == 0 => "\b[${(e / (60 * multiple)).round()}m] ",
      int e when e % (30 * multiple) == 0 => "\b[${switch ((e / (60 * multiple)).floor()) { int e when e >= 1 => e, _ => "" }}½m] ",
      int e when e % (10 * multiple) == 0 => "\b| ",
      int e when e % (5 * multiple) == 0 => "\b¡ ",
      int e when e % (1 * multiple) == 0 => "\b. ",
      _ => "\b${cursorChars[cursorIndex]}",
    };
    stdout.write(toPrint);
    cursorIndex = (cursorIndex + 1) % cursorChars.length;
  }
}

Completer<T> wrapInCompleter<T>(Future<T> future) {
  final completer = Completer<T>();
  future.then(completer.complete).catchError(completer.completeError);
  return completer;
}

int fibonacci(int n) => n < 2 ? n : fibonacci(n - 1) + fibonacci(n - 2);
