class DistanceCalculator {

  Map<double,int> _rssiDistance = new Map<double,int>();

  DistanceCalculator() {
    _setRssiDistance();
  }

  void _setRssiDistance() {
    Map<double,int> _distanceValues = {
      -63.00: 150,
      -66.00: 200,
      -71.00: 250,
      -77.00: 300,
      -80.00: 350,
    };
    this._rssiDistance.addAll(_distanceValues);
  }

  int calculateDistance(int rssi) {
    List<double> rssiValues = _rssiDistance.keys.toList();
    rssiValues.sort();
    if(rssi < rssiValues.first) {
      return _rssiDistance[rssiValues.first];
    }
    if(rssi > rssiValues.last) {
      return _rssiDistance[rssiValues.last];
    }

    int lo = 0;
    int hi = rssiValues.length-1;

    while (lo <= hi) {
      int mid = ((hi + lo) / 2).toInt();
      if (rssi < rssiValues[mid]) {
        hi = mid - 1;
      } else if (rssi > rssiValues[mid]) {
        lo = mid + 1;
      } else {
        return _rssiDistance[rssiValues[mid]];
      }
    }
    return _rssiDistance[(rssiValues[lo] - rssi) < (rssi - rssiValues[hi]) ? rssiValues[lo] : rssiValues[hi]];
  }
}