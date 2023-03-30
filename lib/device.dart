import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class Device extends StatefulWidget {
  const Device({super.key, required this.device});

  final DiscoveredDevice device;

  @override
  State<Device> createState() => _DeviceState();
}

class _DeviceState extends State<Device> {
  late StreamSubscription<ConnectionStateUpdate> _connection;
  bool locked = false;
  bool connected = false;
  final flutterReactiveBle = FlutterReactiveBle();
  final Uuid characteristicId =
      Uuid.parse("f598b95f-eb8d-4146-b53c-25d79ef69842");
  final Uuid serviceId = Uuid.parse("a20086d6-8093-4ef7-90db-f9d33cccd1e2");

  @override
  void initState() {
    // Start connection with timeout of 5 seconds
    _connection = flutterReactiveBle
        .connectToDevice(id: widget.device.id)
        .listen((event) {
      if (event.connectionState == DeviceConnectionState.connected) {
        connected = true;
        read(widget.device);
      }
      print(event);
    }, onError: (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    });

    // Define Timeout
    Timer(const Duration(seconds: 5), () {
      if (connected) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connection timed out"),
        ),
      );
      Navigator.pop(context);
    });
    super.initState();
  }

  // Lock the device
  Future<void> lock(device) async {
    final characteristic = QualifiedCharacteristic(
        serviceId: serviceId,
        characteristicId: characteristicId,
        deviceId: device.id);
    await flutterReactiveBle
        .writeCharacteristicWithResponse(characteristic, value: [0x01]);
    setState(() {
      locked = true;
    });
  }

  // Unlock the device
  Future<void> unlock(device) async {
    final characteristic = QualifiedCharacteristic(
        serviceId: serviceId,
        characteristicId: characteristicId,
        deviceId: device.id);
    await flutterReactiveBle
        .writeCharacteristicWithResponse(characteristic, value: [0x00]);
    setState(() {
      locked = false;
    });
  }

  // Read the status of the device
  Future<void> read(DiscoveredDevice device) async {
    final characteristic = QualifiedCharacteristic(
        serviceId: serviceId,
        characteristicId: characteristicId,
        deviceId: device.id);
    var status = await flutterReactiveBle.readCharacteristic(characteristic);
    setState(() {
      print(status);
      locked = status[0] == 0x01;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ListView(
        children: <Widget>[
          ListTile(
            title: Text("Device: ${widget.device.name}"),
          ),
          ListTile(
            title: Text("Locked: $locked"),
          ),
          ListTile(
            title: ElevatedButton(
              onPressed: () {
                locked ? unlock(widget.device) : lock(widget.device);
              },
              child: locked ? const Text("Unlock") : const Text("Lock"),
            ),
          ),
        ],
      )),
    );
  }

  @override
  void dispose() {
    _connection.cancel();
    print('Dispose used');
    super.dispose();
  }
}
