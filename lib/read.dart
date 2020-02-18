import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

const List<int> READ_DATE = [
  0x80,
  0x0F,
  0xF0,
  0x04,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00
];

const List<int> READ_DEVICE_ID = [
  0x80,
  0x0F,
  0xF0,
  0x0C,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00
];

const List<int> COUNT_DATA = [
  0x80,
  0x0F,
  0xF0,
  0x01,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00
];

const List<int> READ_ONE_DATA = [
  0x80,
  0x0F,
  0xF0,
  0x02,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00
];

class ReadScreen extends StatefulWidget {
  @override
  _ReadScreenState createState() => _ReadScreenState();
}

class _ReadScreenState extends State<ReadScreen> {
  List<BluetoothService> services;
  BluetoothDevice device;
  BluetoothService notifyService;
  BluetoothService writeService;
  BluetoothCharacteristic notifyCaracteristic;
  BluetoothCharacteristic writeCaracteristic;
  List<int> receivedData;

  var _loadedInitData = false;
  var _isReadingDateTime = false;

  @override
  void didChangeDependencies() async {
    if (!_loadedInitData) {
      final routeArgs =
          ModalRoute.of(context).settings.arguments as Map<String, dynamic>;

      services = routeArgs['services'];
      device = routeArgs['device'];

      notifyService = services.firstWhere((element) =>
          element.uuid.toString() == '0000ffe0-0000-1000-8000-00805f9b34fb');

      writeService = services.firstWhere((element) =>
          element.uuid.toString() == '0000ffe5-0000-1000-8000-00805f9b34fb');

      notifyCaracteristic = notifyService.characteristics.firstWhere(
          (element) =>
              element.uuid.toString() ==
              '0000ffe4-0000-1000-8000-00805f9b34fb');

      writeCaracteristic = writeService.characteristics.firstWhere((element) =>
          element.uuid.toString() == '0000ffe9-0000-1000-8000-00805f9b34fb');

      await notifyCaracteristic.setNotifyValue(true);

      notifyCaracteristic.value.listen((value) {
        print('====================================');
        print(value);
        print('====================================');

        receivedData = value;
      });

      _loadedInitData = true;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await device.disconnect();
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Choose Action'),
        ),
        body: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                color: Colors.blue,
                child: Text(
                  _isReadingDateTime
                      ? 'Stop Reading Date/Time'
                      : 'Start Reading Date/Time',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  _isReadingDateTime = !_isReadingDateTime;

                  setState(() {});

                  while (_isReadingDateTime) {
                    writeCaracteristic.write(READ_DATE);
                    await Future.delayed(Duration(seconds: 1));
                  }
                },
              ),
              RaisedButton(
                color: Colors.blue,
                child: Text(
                  'Read Device ID',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  writeCaracteristic.write(READ_DEVICE_ID);
                },
              ),
              RaisedButton(
                color: Colors.blue,
                child: Text(
                  'Read Number of Records',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  writeCaracteristic.write(COUNT_DATA);
                },
              ),
              RaisedButton(
                color: Colors.blue,
                child: Text(
                  'Read One Data',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  writeCaracteristic.write(READ_ONE_DATA);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
