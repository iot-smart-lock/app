import 'package:app/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class Connection extends StatefulWidget {
  const Connection({super.key});

  @override
  State<Connection> createState() => _ConnectionState();
}

class _ConnectionState extends State<Connection> {
  final flutterReactiveBle = FlutterReactiveBle();
  List<DiscoveredDevice> devices = [];
  bool searching = false;

  void search() {
    if (searching) {
      return;
    }

    flutterReactiveBle.scanForDevices(
        withServices: [], scanMode: ScanMode.lowLatency).listen((device) {
      if (device.name == "SmartLock" || device.name == "TTGO T-Beam") {
        bool found = false;
        for (var d in devices) {
          if (d.id == device.id) {
            found = true;
          }
        }

        if (!found) {
          devices.add(device);
          setState(() {
            searching = true;
            devices = devices;
          });
        }
      }
    }, onError: (e) {
      print("Error: $e");
    });
  }

  void connect(DiscoveredDevice device) {
    flutterReactiveBle
        .connectToDevice(
      id: device.id,
      connectionTimeout: const Duration(seconds: 5),
    )
        .listen((connectionState) {
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => Device(device: device)));
      } else {
        print("Connection state: $connectionState");
      }
      // Handle connection state updates
    }, onError: (Object error) {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ElevatedButton(
          onPressed: () {
            search();
          },
          child: searching ? const Text("Searching") : const Text("Search"),
        ),
        ...devices.map((device) => ListTile(
              title: Text(device.name),
              subtitle: Text(device.id),
              onTap: () {
                connect(device);
              },
            ))
      ],
    );
  }
}
