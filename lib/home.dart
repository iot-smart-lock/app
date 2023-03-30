import 'package:app/connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'connection.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _devices = [
    "schloss1",
    "schloss2",
    "schloss3"
  ]; //connected smartlocks (hardcode at first)
  String _error_msg = "";
  final flutterReactiveBle =
      FlutterReactiveBle(); //BLE instance from imported package
  final mapController = MapController(); //mapController from imported package
  final apiKey =
      "233b12ac-968b-403a-b505-f1a2383ed99f"; //apiKey from stadiamaps; in example const
  final styleUrl =
      "https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png"; //kein plan was des ist; in example auch const
  int _selectedIndex = 0; //index for Navigation Bar
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  //search function to find BLE devices
  void _search() {
    flutterReactiveBle.scanForDevices(
        withServices: [], scanMode: ScanMode.lowLatency).listen((device) {
      if (device.name == "TTGO T-Beam") {
        print(device);
      }
    }, onError: (e) {
      print("Error: $e");
    });
  }

  void _connect() {
    flutterReactiveBle
        .connectToDevice(
      id: '94:B5:55:C7:82:12',
      connectionTimeout: const Duration(seconds: 5),
    )
        .listen((connectionState) {
      print("Connection state: $connectionState");
      // Handle connection state updates
    }, onError: (Object error) {
      // Handle a possible error
    });
  }

  //frontend
  late final List<Widget> _widgetOptions = <Widget>[
    const Connection(),
    FlutterMap(
      options: MapOptions(center: LatLng(48, 9), zoom: 14, keepAlive: true),
      children: <Widget>[
        TileLayer(
          urlTemplate: "$styleUrl?api_key={api_key}",
          additionalOptions: {"api_key": apiKey},
          maxZoom: 20,
          maxNativeZoom: 20,
        ),
        MarkerLayer(
          markers: [
            Marker(
                point: LatLng(48, 9),
                builder: (context) => Icon(Icons.location_on)),
          ],
        ),
      ],
    )
  ];

  //function for navigation bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartLock'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'GeoLocations',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
