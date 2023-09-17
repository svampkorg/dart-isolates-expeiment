import 'dart:io';
import 'dart:isolate';

import 'package:isolates/extensions.dart';
import 'package:isolates/general_functions.dart';
import 'package:isolates/isolate_runner.dart';
import 'package:isolates/kill_message.dart';

void main() async {
  int fibb1 = 48;
  int fibb2 = 49;
  int fibb3 = 50;
  int fibb4 = 51;
  int fibb5 = 52;
  int fibb6 = 53;
  int fibb7 = 54;

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
    // IsolateRunner.run<int, int>(fibonacci, fibb6, null, workerReceivePort.sendPort,
    //     isolateName: "fibonacci calculation for $fibb6:th number"),
    // IsolateRunner.run<int, int>(fibonacci, fibb7, null, workerReceivePort.sendPort,
    //     isolateName: "fibonacci calculation for $fibb7:th number"),
  ];

  Map<String, int> resultMap = {};

  workerReceivePort.listenFor<Map<String, int>>(
      bcStream: bcFromIsolates,
      whileListening: progressPrint,
      whenKilled: () {
        print("\n\nResults are in!");
        printResult(resultMap);
        print("Press any key to exit");
        stdin.first.then((value) => exit(0));
      },
      whenResult: (result, killCommand) {
        resultMap.addAll(result);
        stdout.write("(r${resultMap.length})");
        Function.apply(killCommand, [KillWhen(resultMap.length >= fibbFutures.length)]);
      });
}
