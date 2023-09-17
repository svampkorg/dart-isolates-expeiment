import 'dart:async';
import 'dart:io';

void printResult(Map<String, int> result) {
  result.forEach((key, value) {
    print("$key: $value");
  });
}

// delay in milliseconds
void progressPrint(int delay) {
  final cursorChars = ['-', '\\', '|', '/'];
  var cursorIndex = 0;
  var elapsed = 0;
  final multiple = 1000 / delay;
  stdout.write("|");
  while (true) {
    sleep(Duration(milliseconds: delay));
    elapsed++;
    String toPrint = switch (elapsed) {
      int e when e % (60 * multiple) == 0 => "[${(e / 60 * multiple).round()}m] ",
      int e when e % (30 * multiple) == 0 => "[${(e / 60 * multiple).floor()}m 30s] ",
      int e when e % (10 * multiple) == 0 => "|",
      int e when e % (5 * multiple) == 0 => ":",
      int e when e % (1 * multiple) == 0 => ".",
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

int fibonacci(int n) {
  if (n == 0 || n == 1) {
    return n;
  }
  return fibonacci(n - 1) + fibonacci(n - 2);
}
