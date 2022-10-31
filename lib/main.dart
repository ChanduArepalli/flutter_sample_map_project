import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  double _zoom = 16;
  final MapController mapController = MapController();

  LatLng currentPostion = LatLng(16.5419,80.8050);
   void getCurrentLocation() async {
     final position = await Geolocator();
   }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }
  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
          print(position);
      setState(() => mapController.move(LatLng(position.latitude, position.longitude), 15));
    }).catchError((e) {
      debugPrint(e);
    });
  }
  @override
  void initState(){
    super.initState();
    _getCurrentPosition();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use `MapController` as needed
    });

  }
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(title: Text("Map Screen"),),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.zoom_in_map),
        onPressed: (){_getCurrentPosition();
        },
      ),
      body: Stack(
        children: [

          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: currentPostion,
              zoom: _zoom,
            ),
            children: [


              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'dev.fleaflet.flutter_map.example',
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    color: Colors.green.withOpacity(0.2),
                      borderColor: Colors.green,
                      borderStrokeWidth: 1,
                      point: LatLng(16.5390,80.8045), radius: 100*1)
                ],
              ),

              PolylineLayer(
                polylineCulling: false,
                polylines: [
                  Polyline(
                    points: [
                      LatLng(16.5419,80.8050),
                      LatLng(16.5417,80.8046),
                      LatLng(16.5417,80.8036),
                      LatLng(16.5425,80.80358),
                    ],
                    color: Colors.green,
                    borderStrokeWidth: 2
                  ),
                ],
              ),

              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(16.5390,80.8045),
                    width: 80,
                    height: 80,
                    builder: (context) => Icon(Icons.person, color: Colors.blue, size: 24,),
                  ),

            ],
              ),
              PolygonLayer(
                polygonCulling: false,
                polygons: [
                  Polygon(
                    points: [LatLng(16.5449,80.8080), LatLng(16.5449,80.8050), LatLng(16.5419,80.8050),],
                    borderStrokeWidth: 1,
                    borderColor: Colors.red,
                    isFilled: true,
                    isDotted: true,
                    disableHolesBorder: true,
                    label: "Area 1",
                    labelPlacement: PolygonLabelPlacement.polylabel,
                    color: Colors.red.withOpacity(0.2)

                  ),
                  Polygon(
                      points: [
                        LatLng(16.5449,80.8045),
                        LatLng(16.5459,80.8040),
                        LatLng(16.5439,80.8030),
                        LatLng(16.5425,80.8035),
                      ],
                      label: "Area 2dvvvzv",
                      labelStyle: TextStyle(color: Colors.red, fontSize: 10, overflow: TextOverflow.fade),
                      labelPlacement: PolygonLabelPlacement.polylabel,
                      borderStrokeWidth: 1,
                      borderColor: Colors.red,
                      isFilled: true,
                      color: Colors.red.withOpacity(0.2)

                  ),
                ],
              ),
            ],
          ),

          Positioned(
              right: 0,
              top: 0,
              child: Column(children: [
            IconButton(onPressed: (){
              setState(() {
                _zoom += 0.1;
                mapController.move(currentPostion, _zoom);
              });
            }, icon: Icon(Icons.zoom_in),),
            IconButton(onPressed: (){

              setState(() {
                _zoom -= 0.1;
                mapController.move(currentPostion, _zoom);
              });
            }, icon: Icon(Icons.zoom_out),),
          ],))
        ],
      ),
    );
  }
}

