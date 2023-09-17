import 'dart:async';
import 'dart:io';

String getThisMessage(int i) {
  return "You are currently calculating fibonacci sequence for $i";
}

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
      int e when e == 0 => "${e}s",
      int e when e % 10 == 0 => "${e}s",
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
