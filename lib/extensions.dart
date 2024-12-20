import 'dart:async';
import 'dart:io' as io;
import 'dart:isolate';

import 'package:isolates/isolate_runner.dart';
import 'package:isolates/kill_message.dart';
import 'package:mansion/mansion.dart';

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
          io.stdout.writeAnsi(SetStyles(Style.foreground(Color.brightGreen)));
          // io.stdout.write("\b\b• ");
          io.stdout.write("\b\b󰇵 ");
          io.stdout.writeAnsi(SetStyles.reset);
          whenResult?.call(value, killCommand);
        case KillWhen(:bool kill) when kill:
          close();
          whenKilled?.call();
      }
    });
    if (whileListening case Function whileListening) {
      IsolateRunner.run(whileListening, 50, bcStream, sendPort,
          isolateName: "\nTime line dot-printer '•' for a completed result. '[#m]' minute and half, '¡' & '|' every 5th & 10th sec.\n",
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
