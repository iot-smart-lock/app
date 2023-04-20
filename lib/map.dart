import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app/connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'connection.dart';
import 'package:http/http.dart' as http;

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  final mapController = MapController(); //mapController from imported package
  final apiKey =
      "233b12ac-968b-403a-b505-f1a2383ed99f"; //apiKey from stadiamaps; in example const
  final styleUrl =
      "https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png"; //kein plan was des ist; in example auch const

  LatLng _position = LatLng(48, 9);
  bool requesting = false;

  @override
  void initState() {
    super.initState();
    loop();
  }

  void loop() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      _getposition().then((value) {
        if (!mounted) {
          return;
        }
        setState(() {
          _position = value;
        });
      });
    });
  }

  Future<LatLng> _getposition() async {
    if (requesting) {
      return _position;
    }

    requesting = true;
    try {
      var result = await http
          .get(Uri.http("20.91.204.230:1880", "/eui-70b3d57ed005bc62"));

      requesting = false;
      var decoded = json.decode(result.body);

      return LatLng(decoded['latitude'], decoded["longitude"]);
    } catch (e) {
      print("Not connected to server");
      requesting = false;
      return _position;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(center: LatLng(48, 9), zoom: 10, keepAlive: true),
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
                point: _position,
                builder: (context) => Icon(Icons.location_on)),
          ],
        ),
      ],
    );
  }
}
