import 'dart:io' as io;
import 'dart:isolate';

import 'package:isolates/extensions.dart';
import 'package:isolates/general_functions.dart';
import 'package:isolates/isolate_runner.dart';
import 'package:isolates/kill_message.dart';
import 'package:mansion/mansion.dart';

void main() async {
  int fibb1 = 47;
  int fibb2 = 48;
  int fibb3 = 49;
  int fibb4 = 50;
  int fibb5 = 51;

  List<Future<Map<String, int>>> fibbFutures;

  ReceivePort workerReceivePort = ReceivePort();

  // INFO: broadcast for multiple listeners
  var bcFromIsolates = workerReceivePort.asBroadcastStream();

  fibbFutures = [
    IsolateRunner.run<int, int>(fibonacci, fibb1, null, workerReceivePort.sendPort,
        isolateName: "fibonacci calculation for $fibb1:th number"),
    IsolateRunner.run<int, int>(fibonacci, fibb2, null, workerReceivePort.sendPort,
        isolateName: "fibonacci calculation for $fibb2:th number"),
    IsolateRunner.run<int, int>(fibonacci, fibb3, null, workerReceivePort.sendPort,
        isolateName: "fibonacci calculation for $fibb3:th number"),
    IsolateRunner.run<int, int>(fibonacci, fibb4, null, workerReceivePort.sendPort,
        isolateName: "fibonacci calculation for $fibb4:th number"),
    IsolateRunner.run<int, int>(fibonacci, fibb5, null, workerReceivePort.sendPort,
        isolateName: "fibonacci calculation for $fibb5:th number"),
  ];

  Map<String, int> resultMap = {};

  io.stdout.writeAnsi(Clear.all);
  io.stdout.writeAnsi(CursorPosition.reset);
  io.stdout.write('\x1b[?25l'); // Hide cursor
  workerReceivePort.listenFor<Map<String, int>>(
      bcStream: bcFromIsolates,
      whileListening: progressPrint,
      whenKilled: () {
        io.stdout.write("\b] ");
        io.stdout.writeAnsi(SetStyles(Style.foreground(Color.green)));
        io.stdout.writeAnsi(SetStyles.reset);
        io.stdout.writeAnsi(CursorPosition.moveDown(resultMap.length + 1));
        io.stdout.writeAnsi(CursorPosition.resetColumn);
        print("That's it!");
        // printResult(resultMap);
        print("Press any key to exit");
        io.stdout.write('\x1b[?25h'); // Show cursor
        io.stdin.first.then((value) => io.exit(0));
      },
      whenResult: (Map<String, int> result, Function killCommand) {
        resultMap.addAll(result);
        printIntermediate(resultMap);
        Function.apply(killCommand, [KillWhen(resultMap.length >= fibbFutures.length)]);
      });
}
