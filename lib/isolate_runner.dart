import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:isolates/kill_message.dart';

class IsolateRunner {
  // INFO: This function takes an argument of T and expecting a return value of R
  // for the given function and it's argument value. It returns a map with the value of R
  // and the name of the isolate completing the computation.
  static Future<Map<String, R>> run<T, R>(Function function, T arg, Stream? killSignalStream, SendPort resultListenerSendPort,
      {String? isolateName, bool withResult = true}) async {
    // INFO: the completer for the future of the isolate spawn
    final futureCompleter = Completer<Map<String, R>>();

    // INFO: The port receiving the messages from the isolate
    final isolateReceive = ReceivePort();

    final isolateId = switch (isolateName) {
      String name => name,
      _ => "isolate_with_argument:$arg",
    };

    final isolate = await Isolate.spawn(_spawnWorkerIsolate<T>, isolateReceive.sendPort, paused: true, debugName: isolateName);

    // INFO: listening for a kill signal from outide
    if (killSignalStream case Stream bc) {
      bc.listen((message) {
        switch (message) {
          case KillWhen(:bool kill) when kill:
            isolate.kill(priority: Isolate.immediate);
        }
      });
    }

    // INFO: Listen to the isolate messages, SendPort for sending isolate its parameters
    // and R for receiving the return value when the isolate has completed its work
    isolateReceive.listen((message) {
      switch (message) {
        case SendPort toIsolateSendPort:
          // INFO: We've got a send port, so send the arguments and the function
          toIsolateSendPort.send(withResult);
          toIsolateSendPort.send(arg);
          toIsolateSendPort.send(function);
        case R result:
          // INFO: Send result back on the SendPort we got from outside.
          isolateReceive.close();
          resultListenerSendPort.send({isolateId: result});
          futureCompleter.complete({isolateId: result});
      }
    });

    // INFO: resume the worker, since it starts in a paused state
    if (isolate.pauseCapability case Capability pauseCapability) {
      isolate.resume(pauseCapability);
      if (isolateName case String isolateName) {
        resultListenerSendPort.send("$isolateName started");
      }
    }

    // INFO: Return the future for the futureComplete
    return futureCompleter.future;
  }

  static void _spawnWorkerIsolate<T>(SendPort sendPort) {
    // INFO: The port receiving messages from "outside"
    final receivePort = ReceivePort();

    // INFO: We got a sendPort from the call to this function
    // we use this now to send this isolates receivers send port
    // so that whoever spawned this isolate can send work data
    sendPort.send(receivePort.sendPort);

    // INFO: Define what properties we use in this isolate.
    Function? function;
    T? arguments;
    bool? withResult;

    // INFO: Start listening for a message sent over the recievePort. We expect an
    // argument of T and a function to run with this argument.
    // we also want a bool to determin if we are to send any result back or not.
    receivePort.listen((message) {
      switch (message) {
        case Function wasFunction:
          function = wasFunction;
        case T wasArguments:
          arguments = wasArguments;
        case bool wasWithResult:
          withResult = wasWithResult;
      }

      // INFO: Match the defined properties to something real (and not null :P)
      // when all match, we got what we need and can start the computation.
      // by applying the function with its arguments. If without result we close
      // the ReceivePort right away.
      switch ((function, arguments, withResult)) {
        case (Function function, T arguments, bool withResult):
          if (!withResult) receivePort.close();
          final result = Function.apply(function, [arguments]);
          sendPort.send(result);
          receivePort.close();
      }
    });
  }
}
