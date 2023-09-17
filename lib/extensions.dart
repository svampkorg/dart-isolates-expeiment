import 'dart:async';
import 'dart:io';
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
          stdout.write("\b*");
          whenResult?.call(value, killCommand);
        case KillWhen(:bool kill) when kill:
          close();
          whenKilled?.call();
      }
    });
    if (whileListening case Function whileListening) {
      IsolateRunner.run(whileListening, 100, bcStream, sendPort,
          isolateName:
              "Time line dot-printer '*' for a completed result. '[#min #s]' every half and minute, ':' & '|' every 5th & 10th sec.",
          withResult: false);
    }
  }
}

// extension FutureExtension<T> on Future<T> {
//   bool isCompleted() {
//     // Completer<T> isCompleted() {
//     final completer = Completer<T>();
//     then(completer.complete).catchError(completer.completeError);
//     return completer.isCompleted;
//     // return completer;
//   }
// }
