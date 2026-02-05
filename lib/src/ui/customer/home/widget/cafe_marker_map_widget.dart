import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/ui/customer/home/bloc/customer_home_bloc.dart';
import 'package:soloseaters/src/utils/data/auth_session_manager.dart';
import 'package:soloseaters/src/utils/data/sign_out.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

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
      markerImageBytes = await getImages(markerImage, 100);
    }
  }

  static const CameraPosition _kDefaultPosition = CameraPosition(
    target: LatLng(-40.9006, 174.8860),
    zoom: 6,
  );

  Future<void> _updateMarkersFromCafes(List<CafeLocation> cafeLocations) async {
    await _loadMarkerIcon();

    _markers.clear();

    // Filter out cafes with invalid coordinates (0.0, 0.0)
    final validCafes =
        cafeLocations.where((cafe) {
          final isValid = cafe.latitude != 0.0 && cafe.longitude != 0.0;
          if (!isValid) {
            debugPrint(
              'Skipping cafe marker "${cafe.name}" with invalid coordinates: (${cafe.latitude}, ${cafe.longitude})',
            );
          }
          return isValid;
        }).toList();

    debugPrint('Total cafes received: ${cafeLocations.length}');
    debugPrint('Valid cafes with coordinates: ${validCafes.length}');

    for (int i = 0; i < validCafes.length; i++) {
      final cafe = validCafes[i];
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

    if (validCafes.isNotEmpty) {
      _centerMapOnUserLocation();
    } else if (_mapInitialized) {
      // If no valid cafes, zoom to user's location or NZ default at country-level
      final GoogleMapController controller = await _controller.future;
      final LatLng referencePoint = _userLocation ?? _kDefaultPosition.target;
      controller.animateCamera(CameraUpdate.newLatLngZoom(referencePoint, 6));

      // Show message if we received cafes but none had valid coordinates
      if (cafeLocations.isNotEmpty) {
        Fluttertoast.showToast(
          fontSize: 14.sp,
          backgroundColor: AppColors.primaryWhiteColor,
          textColor: AppColors.appRedColor,
          gravity: ToastGravity.BOTTOM,
          msg:
              "Search returned ${cafeLocations.length} cafe(s), but none have valid location coordinates.",
        );
      }
    }
    setState(() {});
  }

  void _onMarkerTapped(CafeLocation cafe) {
    print('Cafe tapped: ${cafe.name}');
  }

  Future<void> _centerMapOnUserLocation() async {
    if (!_mapInitialized) {
      debugPrint('⚠️ Camera update skipped - map not initialized yet');
      return;
    }

    debugPrint(
      '📍 Keeping camera focused on user location at country-level zoom',
    );

    // Small delay to ensure map is ready for camera updates
    await Future.delayed(const Duration(milliseconds: 100));

    final GoogleMapController controller = await _controller.future;

    // Use user location if available, otherwise default to New Zealand
    final LatLng targetLocation = _userLocation ?? _kDefaultPosition.target;

    debugPrint(
      '�️ Zooming to ${_userLocation != null ? "user location" : "New Zealand"} at country-level zoom (6)',
    );

    // Always zoom to user's location (or NZ default) at country-level zoom
    controller.animateCamera(CameraUpdate.newLatLngZoom(targetLocation, 6));
  }

  void _handleLocationState(CustomerHomeState state) async {
    if (state is LocationLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        setState(() {
          _hasLocationPermission = true;
          _userLocation = LatLng(state.latitude, state.longitude);
        });

        // Move camera to user's location when location is loaded
        if (_mapInitialized) {
          final GoogleMapController controller = await _controller.future;
          controller.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(state.latitude, state.longitude),
              6, // Country-level zoom
            ),
          );
        }
      });
    }

    if (state is LocationError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _hasLocationPermission = false;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // _checkLocationPermission();
    _loadMarkerIcon();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerHomeBloc>().add(
        FetchLocationEvent(context: context),
      );
    });
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
                if ((state.response.message!.contains("Unauthorized") ||
                        state.response.message!.contains(
                          "status code of 401",
                        )) &&
                    AuthSessionManager.consumeRefreshFailureFlag()) {
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

            // Handle location state changes in the listener
            _handleLocationState(state);
          },
          builder: (context, state) {
            if (_userLocation == null &&
                (state is LocationLoading || state is CustomerHomeInitial)) {
              EasyLoading.show();
            }

            return GoogleMap(
              padding: EdgeInsets.only(
                bottom:
                    Platform.isIOS || Platform.isAndroid
                        ? kBottomNavigationBarHeight + 80.0
                        : 0.0,
              ),
              mapToolbarEnabled: true,
              zoomControlsEnabled: false,
              initialCameraPosition: _kDefaultPosition,
              markers: Set<Marker>.of(_markers),
              mapType: MapType.normal,
              myLocationEnabled: _hasLocationPermission,
              myLocationButtonEnabled: _hasLocationPermission,
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
