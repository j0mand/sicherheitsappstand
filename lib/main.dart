//import 'dart:async';
//import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:sicherheitsappstand/StatusChecker.dart';
import 'package:sicherheitsappstand/DistanceCalculator.dart';
import 'package:sicherheitsappstand/Enum.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Covid-19 Sicherheitsappstand',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return FindDevicesScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key key, this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state.toString().substring(15)}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatefulWidget {
  @override
  _FindDevicesState createState() => _FindDevicesState();
}

class _FindDevicesState extends State<FindDevicesScreen> {

  List<DeviceIdentifier> uniqueIdentifier = new List<DeviceIdentifier>();
  List<List<ScanResult>> results = new List<List<ScanResult>>();
  DistanceCalculator distanceCalculator = new DistanceCalculator();
  StatusChecker alertManager = new StatusChecker();
  DistanceStatus status = DistanceStatus.STATUS_OK;
  Color bgColor = Colors.green;
  String statusMsg = 'OK';
  IconData icon = Icons.check_circle;

  void initState() {
    super.initState();
    FlutterBlue.instance.scanResults.listen((data) {
      if (mounted) {
        var filteredData = data.where((e) => e.device.type != BluetoothDeviceType.le).toList();
        if(filteredData.isNotEmpty) {
          _checkDistance(filteredData);
        }
      }
    });
  }

  void _checkDistance(List<ScanResult> data) {
    List<int> distanceValues = data.map((f) => distanceCalculator.calculateDistance(f.rssi)).toList();
    int currentDistance = distanceValues.reduce((a,b) => a < b ? a : b);
    DistanceStatus newStatus = alertManager.checkStatus(currentDistance);
    if(newStatus != status) {
      setState(() {
        setDistanceState(newStatus);
      });
    }
  }

  void setDistanceState(DistanceStatus status) {
    this.status = status;
    switch(status) {
      case DistanceStatus.STATUS_OK:
        bgColor = Colors.green;
        icon = Icons.check_circle;
        statusMsg = 'OK';
        FlutterRingtonePlayer.stop();
        break;
      case DistanceStatus.STATUS_WARNING:
        bgColor = Colors.amber;
        icon = Icons.warning;
        statusMsg = 'WARNUNG';
        FlutterRingtonePlayer.playNotification(looping: false);
        Vibration.vibrate(duration: 4000, pattern: [500, 1000, 500, 2000], intensities: [150]);
        break;
      case DistanceStatus.STATUS_ALERT:
        bgColor = Colors.red;
        icon = Icons.error;
        statusMsg = 'ALARM';
        FlutterRingtonePlayer.playAlarm(looping: false);
        Vibration.vibrate(duration: 12000, pattern: [500, 1000, 500, 2000, 500, 1000, 500, 2000, 500, 1000, 500, 2000], intensities: [255]);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Covid-19 Sicherheitsappstand'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
                icon,
                size: 200,
            ),
            Text(
              statusMsg,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 45.0),
            ),
          ],
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.grey,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () => FlutterBlue.instance.startScan());
            /*startScan(timeout: Duration(seconds: 4)));*/
          }
        },
      ),
    );
  }
}