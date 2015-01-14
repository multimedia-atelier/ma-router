import 'package:logging/logging.dart' as logging;

logging.Logger _maLog = new logging.Logger("ma");
bool _loggingInitialized = false;

logging.Logger get maLog {
  initLogging();
  return _maLog;
}

void initLogging() {
  if (!_loggingInitialized) {
    _maLog.level = logging.Level.ALL;
    _maLog.onRecord.listen((logging.LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    });
    _maLog.fine("Logging initialized");
    _loggingInitialized = true;
  }
}