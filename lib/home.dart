import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _devices = ["schloss1", "schloss2"]; //connected smartlocks (hardcode at first)
  String _error_msg = "";
  final flutterReactiveBle = FlutterReactiveBle();

  void _search() {
    flutterReactiveBle.scanForDevices(
        withServices: [], scanMode: ScanMode.lowLatency).listen((device) {
      setState(() {
        _devices.add(device.name);
      });
    }, onError: (e) {
      setState(() {
        _error_msg = e.toString(); //code for handling errors
        _devices = [];
      });
    });
  }

/*  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Found devices:',
            ),
            Column(
              children: _devices.map((device) => Text(device)).toList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _search,
        tooltip: 'Search for devices',
        child: const Icon(Icons.search),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}*/


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.1),
        child: AppBar(
          //backgroundColor: FlutterFlowTheme.of(context).secondaryColor,
          automaticallyImplyLeading: false,
          title: Align(
            alignment: AlignmentDirectional(0, 0),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 25, 0, 0),
              child: Text(
                'SmartLock',
                textAlign: TextAlign.center,
                //style: FlutterFlowTheme.of(context).title1,
              ),
            ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2,
        ),
      ),
      body: ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_devices[index]),
            trailing: ElevatedButton(
              onPressed: () {
                // do something when button is pressed
              },
              child: Text('unlock'),
            ),
          );
        },
      ));
      /*body: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              /*Image.asset(
                'images/smartlock.png',
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.4,
                fit: BoxFit.cover,
              ),*/
             ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_devices[index]),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // do something when button is pressed
                    },
                    child: Text('unlock'),
                  ),
                );
              },
            ), 
            ]
        ));*/
      
  }
}