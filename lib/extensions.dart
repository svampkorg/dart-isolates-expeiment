import 'dart:async';
import 'dart:isolate';

import 'package:isolates/isolate_runner.dart';
import 'package:isolates/kill_message.dart';

extension ReceivePortExtension on ReceivePort {
  listenFor<T>({
    required Stream bcStream,
    Function? whileListening,
    Function? whenKilled,
    Function? whenResult,
  }) {
    killCommand(arg) => sendPort.send(arg);
    bcStream.listen((message) {
      switch (message) {
        case String s:
          print(s);
        case T value:
          whenResult?.call(value, killCommand);
        case KillMessage(:bool kill) when kill:
          close();
          whenKilled?.call();
      }
    });
    if (whileListening case Function whileListening) {
      IsolateRunner.run(whileListening, 1, bcStream, sendPort, isolateName: "dot-printer", withResult: false);
    }
  }
}

extension FutureExtension<T> on Future<T> {
  /// Checks if the future has returned a value, using a Completer.
  bool isCompleted() {
    // Completer<T> isCompleted() {
    final completer = Completer<T>();
    then(completer.complete).catchError(completer.completeError);
    return completer.isCompleted;
    // return completer;
  }
}
