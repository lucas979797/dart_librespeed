import 'package:dart_librespeed/speed_test.dart';

void main() async {
  var dlTest =
      DownloadTest(serverAddress: 'http://speedtest.wessexinternet.com');
  dlTest.mbpsStream.listen((event) {
    print(event);
  });
  await dlTest.start();

  var ulTest = UploadTest(serverAddress: 'http://speedtest.wessexinternet.com');
  ulTest.mbpsStream.listen(print);
  await ulTest.start();

  var pingTest =
      PingJitterTest(serverAddress: 'http://speedtest.wessexinternet.com');
  pingTest.pingStream.listen((event) {
    print('${event.toStringAsFixed(2)}ms ping');
  });
  pingTest.jitterStream.listen((event) {
    print('${event.toStringAsFixed(2)}ms jitter');
  });
  await pingTest.start();
}
