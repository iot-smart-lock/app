import 'dart:async';

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

  // Search for devices with the name "SmartLock" or "TTGO T-Beam"
  void search() {
    if (searching) {
      print("Already searching");
      return;
    }
    setState(() {
      devices = [];
      searching = true;
    });

    print("Making new search");
    // start scanning for devices
    StreamSubscription sub = flutterReactiveBle.scanForDevices(
        withServices: [], scanMode: ScanMode.lowLatency).listen((device) {
      if (device.name == "SmartLock" || device.name == "TTGO T-Beam") {
        bool found = false;

        // check if device is already in list
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    });

    Timer(const Duration(seconds: 30), () {
      sub.cancel();
      if (!mounted) {
        return;
      }
      setState(() {
        searching = false;
      });
    });
  }

  void connect(DiscoveredDevice device) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => Device(device: device)));
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
