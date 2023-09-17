import 'dart:async';
import 'dart:io';

void printResult(Map<String, int> result) {
  result.forEach((key, value) {
    print("$key: $value");
  });
}

void progressPrint(int delay) {
  var elapsed = 0;
  stdout.write("|");
  while (true) {
    sleep(Duration(seconds: delay));
    elapsed++;
    String toPrint = switch (elapsed) {
      int e when e % 60 == 0 => "[${(e / 60).round()} min]",
      int e when e % 30 == 0 => "[${(e / 60).floor()}min 30s]",
      int e when e % 10 == 0 => "|",
      int e when e % 5 == 0 => ":",
      _ => ".",
    };
    stdout.write(toPrint);
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
