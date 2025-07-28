import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/ui/customer/home/bloc/customer_home_bloc.dart';
import 'package:soloseaters/src/utils/data/sign_out.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';

class CafeMarkerMapWidget extends StatefulWidget {
  const CafeMarkerMapWidget({super.key});

  @override
  State<CafeMarkerMapWidget> createState() => _CafeMarkerMapWidgetState();
}

class _CafeMarkerMapWidgetState extends State<CafeMarkerMapWidget> {
  final Completer<GoogleMapController> _controller = Completer();
  Uint8List? markerImageBytes;
  final String markerImage = 'assets/png/marker_3x.png';
  final List<Marker> _markers = <Marker>[];
  LatLng? _userLocation;
  bool _mapInitialized = false;
  bool _hasLocationPermission = false; 

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
  }

  Future<void> _loadMarkerIcon() async {
    if (markerImageBytes == null) {
      markerImageBytes = await getImages(markerImage, 120);
    }
  }

  static const CameraPosition _kDefaultPosition = CameraPosition(
    target: LatLng(-40.9006, 174.8860),
    zoom: 6,
  );

  Future<void> _updateMarkersFromCafes(List<CafeLocation> cafeLocations) async {
    await _loadMarkerIcon();

    _markers.clear();

    for (int i = 0; i < cafeLocations.length; i++) {
      final cafe = cafeLocations[i];
      _markers.add(
        Marker(
          markerId: MarkerId(cafe.id.toString()),
          icon: BitmapDescriptor.fromBytes(markerImageBytes!),
          position: LatLng(cafe.latitude, cafe.longitude),
          infoWindow: InfoWindow(
            title: cafe.name,
            snippet: cafe.description ?? 'Cafe Location',
          ),
          // Added anchor to position the marker's bottom-center at the coordinates
          anchor: const Offset(0.5, 1.0),
          onTap: () {
            _onMarkerTapped(cafe);
          },
        ),
      );
    }

    if (cafeLocations.isNotEmpty) {
      _updateCameraToShowAllMarkers(cafeLocations);
    }
    setState(() {});
  }

  void _onMarkerTapped(CafeLocation cafe) {
    print('Cafe tapped: ${cafe.name}');
  }

  Future<void> _updateCameraToShowAllMarkers(
    List<CafeLocation> cafeLocations,
  ) async {
    final GoogleMapController controller = await _controller.future;

    if (cafeLocations.length == 1) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            double.parse(cafeLocations.first.latitude.toString()),
            double.parse(cafeLocations.first.longitude.toString()),
          ),
          16,
        ),
      );
      return;
    }

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final cafe in cafeLocations) {
      final lat = double.parse(cafe.latitude.toString());
      final lng = double.parse(cafe.longitude.toString());

      minLat = lat < minLat ? lat : minLat;
      maxLat = lat > maxLat ? lat : maxLat;
      minLng = lng < minLng ? lng : minLng;
      maxLng = lng > maxLng ? lng : maxLng;
    }

    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;

    if (latDiff < 0.005 && lngDiff < 0.005) {
      final centerLat = (minLat + maxLat) / 2;
      final centerLng = (minLng + maxLng) / 2;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(centerLat, centerLng), 16),
      );
    } else {
      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80.0), // 80px padding
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLocationPermission(); 
    _loadMarkerIcon();
  }
void _checkLocationPermission() async {
    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocConsumer<CustomerHomeBloc, CustomerHomeState>(
          listener: (context, state) {
            if (state is CafeSearchError) {
              EasyLoading.dismiss();
            }
            if (state is CafeSearchSuccess) {
              EasyLoading.dismiss();
              _updateMarkersFromCafes(state.cafeLocations);
            } else if (state is CafeSearchInitial) {
              setState(() {
                _markers.clear();
              });
            }
            if (state is CafeSearchSuccess) {
              if (state.response.status == false) {
                if (state.response.message!.contains("Unauthorized") ||
                    state.response.message!.contains("status code of 401")) {
                  EasyLoading.dismiss();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    SignOut().logout(context);
                    Fluttertoast.showToast(
                      fontSize: 14.sp,
                      backgroundColor: AppColors.primaryWhiteColor,
                      textColor: AppColors.appRedColor,
                      gravity: ToastGravity.BOTTOM,
                      msg: "Your session has expired. Please sign in again.",
                    );
                  });
                }
              }
            }
            if (state is CafeSearchSuccess) {
              if (state.response.cafes!.isEmpty) {
                Fluttertoast.showToast(
                  fontSize: 14.sp,
                  backgroundColor: AppColors.primaryWhiteColor,
                  textColor: AppColors.appRedColor,
                  gravity: ToastGravity.BOTTOM,
                  msg: "No Cafes Found.",
                );
              }
            }
          },
          builder: (context, state) {
             if (state is LocationLoaded) {
              setState(() {
                _hasLocationPermission = true;
                _userLocation = LatLng(state.latitude, state.longitude);
              });
            }
            
            if (state is LocationError) {
              setState(() {
                _hasLocationPermission = false;
              });
            }
            if (_userLocation == null &&
                (state is LocationLoading || state is CustomerHomeInitial)) {
              EasyLoading.show();
            }

            return GoogleMap(
              mapToolbarEnabled: true,
              zoomControlsEnabled: true,
              initialCameraPosition: _kDefaultPosition,
              markers: Set<Marker>.of(_markers),
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: _hasLocationPermission,
              compassEnabled: true,
              zoomGesturesEnabled: true,
              scrollGesturesEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                setState(() {
                  _mapInitialized = true;
                });
              },
            );
          },
        ),
      ],
    );
  }
}
