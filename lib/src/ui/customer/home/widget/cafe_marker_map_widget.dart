import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;

class CafeMarkerMapWidget extends StatefulWidget {
  const CafeMarkerMapWidget({super.key});

  @override
  State<CafeMarkerMapWidget> createState() => _CafeMarkerMapWidgetState();
}

class _CafeMarkerMapWidgetState extends State<CafeMarkerMapWidget> {
  final Completer<GoogleMapController> _controller = Completer();
  Uint8List? marketImages;
  final String markerImage = 'assets/png/map-pin@2x.png';
  final List<Marker> _markers = <Marker>[];
  final List<LatLng> _latLen = <LatLng>[
    LatLng(40.7590, -73.9845),
    LatLng(40.7128, -74.0060),
    LatLng(40.6892, -74.0445),
    LatLng(40.7646, -73.9799),
    LatLng(40.7306, -73.9352),
    LatLng(40.7431, -73.9424),
  ];

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetHeight: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
  }

  static final CameraPosition _kGoogle = const CameraPosition(
    target: LatLng(40.7128, -74.0060),
    zoom: 15,
  );

  Future<void> loadMarkers() async {
    final Uint8List iconBytes = await getImages('assets/png/map-pin.png', 100);

    for (int i = 0; i < _latLen.length; i++) {
      _markers.add(
        Marker(
          markerId: MarkerId(i.toString()),
          icon: BitmapDescriptor.fromBytes(iconBytes),
          position: _latLen[i],
          infoWindow: InfoWindow(title: 'Location $i'),
        ),
      );
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(

      mapToolbarEnabled: true,
      zoomControlsEnabled: true,
      // liteModeEnabled: true,
      // given camera position
      initialCameraPosition: _kGoogle,
      // set markers on google map
      markers: Set<Marker>.of(_markers),
      // on below line we have given map type
      mapType: MapType.normal,
      // on below line we have enabled location
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      // on below line we have enabled compass
      compassEnabled: true,
      zoomGesturesEnabled: true,
      // tiltGesturesEnabled: true,
      // rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      // below line displays google map in our app
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }
}
