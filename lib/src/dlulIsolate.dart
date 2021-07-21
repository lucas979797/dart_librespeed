import 'dart:async';

import 'package:dart_librespeed/src/isolateController.dart';

import '../speed_test.dart';
import 'utilities.dart';

class DLULIsolate extends IsolateController
    implements DownloadTest, UploadTest {
  final StreamController<double> _mbpsController = StreamController();
  final StreamController<double> _percentController = StreamController();

  @override
  Stream<double> get mbpsStream => _mbpsController.stream;
  @override
  Stream<double> get percentCompleteStream => _percentController.stream;

  DLULIsolate(
      {required String serverAddress,
      required int updateIntervalMs,
      required int testDurationMs,
      required Future<void> Function(SpawnBundle) task})
      : super(
            serverAddress: serverAddress,
            updateIntervalMs: updateIntervalMs,
            testDurationMs: testDurationMs,
            task: task);

  @override
  void close() {
    _mbpsController.close();
    _percentController.close();
  }

  @override
  Future<void> calculateSpeed() async {
    var totalMegabitsDownloaded = 0.0;
    var startTime = DateTime.now();
    channels.forEach((channel) {
      channel.sink.add(IsolateEvent.start);
      channel.stream.listen((mbits) {
        totalMegabitsDownloaded += mbits;
      });
    });
    while (!abortTest) {
      var elapsedSecs =
          DateTime.now().difference(startTime).inMilliseconds / 1000;
      if ((elapsedSecs * 1000) > testDurationMs) {
        _percentController.add(1.0);
        await abort();
        return;
      }
      _mbpsController.add(totalMegabitsDownloaded / elapsedSecs);
      _percentController.add((elapsedSecs * 1000) / testDurationMs);
      await Future.delayed(Duration(milliseconds: updateIntervalMs));
    }
  }
}
