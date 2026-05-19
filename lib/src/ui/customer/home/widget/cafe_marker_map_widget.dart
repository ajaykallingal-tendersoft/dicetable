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

  Future<void> _updateMarkersFromCafes(
    List<CafeLocation> cafeLocations, {
    bool isFilterResult = false,
    String searchQuery = '',
  }) async {
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
          anchor: const Offset(0.5, 1.0),
          onTap: () {
            _onMarkerTapped(cafe);
          },
        ),
      );
    }

    if (validCafes.isNotEmpty && _mapInitialized) {
      final GoogleMapController controller = await _controller.future;
      await Future.delayed(const Duration(milliseconds: 300));

      if (isFilterResult) {
        // Filter result: fit all markers in view
        if (validCafes.length == 1) {
          controller.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(validCafes.first.latitude, validCafes.first.longitude),
              14,
            ),
          );
        } else {
          controller.animateCamera(
            CameraUpdate.newLatLngBounds(_buildBounds(validCafes), 80.0),
          );
        }
      } else if (searchQuery.isNotEmpty) {
        // Text search: animate camera to the searched venue
        controller.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(validCafes.first.latitude, validCafes.first.longitude),
            14,
          ),
        );
      } else {
        // Initial load / clear filter: centre on user location
        _centerMapOnUserLocation();
      }
    } else if (_mapInitialized && validCafes.isEmpty) {
      // No valid cafes — fall back to user location or NZ default
      final GoogleMapController controller = await _controller.future;
      final LatLng referencePoint = _userLocation ?? _kDefaultPosition.target;
      controller.animateCamera(CameraUpdate.newLatLngZoom(referencePoint, 6));

      if (cafeLocations.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Search returned ${cafeLocations.length} cafe(s) but they don't have valid coordinates.", style: TextStyle(color: AppColors.appRedColor)),
        backgroundColor: AppColors.primaryWhiteColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
      }
    }
    setState(() {});
  }

  /// Computes a LatLngBounds that encapsulates all [cafes].
  LatLngBounds _buildBounds(List<CafeLocation> cafes) {
    double minLat = cafes.first.latitude;
    double maxLat = cafes.first.latitude;
    double minLng = cafes.first.longitude;
    double maxLng = cafes.first.longitude;

    for (final c in cafes) {
      if (c.latitude < minLat) minLat = c.latitude;
      if (c.latitude > maxLat) maxLat = c.latitude;
      if (c.longitude < minLng) minLng = c.longitude;
      if (c.longitude > maxLng) maxLng = c.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _onMarkerTapped(CafeLocation cafe) {
    print('Cafe tapped: ${cafe.name}');
  }

  Future<void> _centerMapOnUserLocation() async {
    if (!_mapInitialized) {
      return;
    }


    // Small delay to ensure map is ready for camera updates
    await Future.delayed(const Duration(milliseconds: 100));

    final GoogleMapController controller = await _controller.future;

    // Use user location if available, otherwise default to New Zealand
    final LatLng targetLocation = _userLocation ?? _kDefaultPosition.target;

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
              _updateMarkersFromCafes(
                state.cafeLocations,
                isFilterResult: state.isFilterResult,
                searchQuery: state.searchQuery,
              );
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
                    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Your session has expired. Please sign in again.", style: TextStyle(color: AppColors.appRedColor)),
        backgroundColor: AppColors.primaryWhiteColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
                  });
                }
              }
            }
            if (state is CafeSearchSuccess) {
              if (state.response.cafes!.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("No Cafes Found.", style: TextStyle(color: AppColors.appRedColor)),
        backgroundColor: AppColors.primaryWhiteColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
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
  bottom: Platform.isIOS 
      ? kBottomNavigationBarHeight + 250.0
      : Platform.isAndroid 
          ? 80.0 
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
