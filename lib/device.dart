import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class Device extends StatefulWidget {
  const Device({super.key, required this.device});

  final DiscoveredDevice device;

  @override
  State<Device> createState() => _DeviceState();
}

class _DeviceState extends State<Device> {
  bool locked = false;
  final Uuid characteristicId =
      Uuid.parse("a20086d6-8093-4ef7-90db-f9d33cccd1e2");
  final Uuid serviceId = Uuid.parse("f598b95f-eb8d-4146-b53c-25d79ef69842");

  void lock() {
    setState(() {
      locked = true;
    });
  }

  // async void read(DiscoveredDevice device) {
  //   final characteristic = QualifiedCharacteristic(serviceId: serviceId, characteristicId: characteristicId, deviceId: device.id);
  //   await flutterReactiveBle.writeCharacteristicWithResponse(characteristic, value: [0x00]);
  //   flutterReactiveBle.readCharacteristic(characteristic).listen((value) {
  //     print(value);
  //   });
  // }

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
              onPressed: lock,
              child: const Text("Lock"),
            ),
          ),
        ],
      )),
    );
  }
}
