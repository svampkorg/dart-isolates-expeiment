import 'dart:async';
import 'dart:isolate';

import 'package:isolates/kill_message.dart';

class IsolateRunner {
  // INFO: This function takes an argument of T and expecting a return value of R
  // for the given function and it's argument value
  // static Future<R> run<T, R>(Function function, T arg, SendPort port) async {
  static Future<Map<String, R>> run<T, R>(Function function, T arg, Stream? killSignalStream, SendPort resultListenerSendPort,
      {String? isolateName, bool withResult = true}) async {
    // INFO: the completer for the future of the isolate spawn, with type R as the complete future
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
          case KillMessage(:bool kill) when kill:
            isolate.kill(priority: Isolate.immediate);
        }
      });
    }

    // INFO: Listen to the isolate messages, SendPort for sending it its parameters
    // and R for receiving the return value when the isolate has completed its work
    isolateReceive.listen((message) {
      switch (message) {
        case SendPort toIsolateSendPort:
          // INFO: We've got a send port, so send the arguments and the function
          toIsolateSendPort.send(withResult);
          toIsolateSendPort.send(arg);
          toIsolateSendPort.send(function);
        case R result:
          // INFO: Send result back on the SendPort we got from upstream.
          isolateReceive.close();
          resultListenerSendPort.send({isolateId: result});
          futureCompleter.complete({isolateId: result});
      }
    });

    // INFO: resume the worker
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
    // INFO: The port receiving messages from another isolate
    final receivePort = ReceivePort();

    // INFO: We got a sendPort from the call to this function from another isolate
    // Use it to let the other isolate know we're got a SendPort and are ready to
    // listen for inputs.
    sendPort.send(receivePort.sendPort);

    // INFO: Define what properties we use in this isolate.
    Function? function;
    T? arguments;
    bool? withResult;

    // INFO: Start listening for a message sent over the recievePort. We expect an
    // argument of T and a function to run with this argument.
    receivePort.listen((message) {
      switch (message) {
        case Function wasFunction:
          // print("got function");
          function = wasFunction;
        case T wasArguments:
          // print("got arguments $wasArguments");
          arguments = wasArguments;
        case bool wasWithResult:
          // print("sending results: $withResult");
          withResult = wasWithResult;
      }

      // print("function: $function");
      // print("arguments: $arguments");
      // print("withResult: $withResult");

      // INFO: Match the defined properties to something real (and not null :P)
      switch ((function, arguments, withResult)) {
        case (Function function, T arguments, bool withResult):
          // INFO: run the function with it's argument and send it back.. once done.. it could take a while :)
          // print("all info aquired! function $arguments $withResult");
          if (!withResult) receivePort.close();
          final result = Function.apply(function, [arguments]);
          sendPort.send(result);
          receivePort.close();
      }
    });
  }
}
