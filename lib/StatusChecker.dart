import 'package:sicherheitsappstand/Enum.dart';

class StatusChecker {
  int _alertDistance = 150;
  int _warningDistance = 250;

  StatusChecker();

  DistanceStatus checkStatus(int distance) {
    if(distance <= _alertDistance) {
      return DistanceStatus.STATUS_ALERT;
    } else if(distance <= _warningDistance) {
      return DistanceStatus.STATUS_WARNING;
    } else {
      return DistanceStatus.STATUS_OK;
    }
  }

}