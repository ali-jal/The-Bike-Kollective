import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:the_bike_kollective/Maps/directions_model.dart';
import 'package:the_bike_kollective/Maps/directions_repository.dart';
import 'package:the_bike_kollective/Maps/mapwidgets/bike_modal_bottom.dart';
import 'package:the_bike_kollective/models.dart';
import 'package:the_bike_kollective/requests.dart';
import 'package:the_bike_kollective/Maps/mapwidgets/haversine.dart';

List<Bike> listofBikes1 = [];
List<Marker> _markers = <Marker>[];

// information/instructions: user opens google maps and finds
// markers which display location of nearby bikes. User can select a bike
// and start a route to it. Once user reaches bike, user can begin check-out
// @params: Bike List
// @return: none
// bugs: none
// 1. Fix having to return to previous screen, then re-enter maps screen to show markers
// TODO:
// 1. Implement & connect bike check-out
class MapsView extends StatefulWidget {
  @override
  _MapsView createState() => _MapsView();
}

class _MapsView extends State<MapsView> {
  LatLng _initialcameraposition = LatLng(40.738380, -73.988426);
  late GoogleMapController _googleMapController;
  Position? _currentPosition;
  LatLng? _endLocation;
  LatLng? _userLocation;
  Directions? _info = null;
  Future<BikeListModel> currentList = getBikeList();

  @override
  void initState() {
    fetchAndSetBikes();
    _setMarkers();
    super.initState();
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Bike Kollective'),
        actions: [
          if (_info != null)
            TextButton(
              onPressed: () => _showNearBikeDialog(),
              style: TextButton.styleFrom(
                primary: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text('Go Near Bike'),
            ),
          if (_info != null)
            TextButton(
              onPressed: () => _showDestinationDialog(),
              style: TextButton.styleFrom(
                primary: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text('Go to Bike'),
            ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: _initialcameraposition),
              mapType: MapType.normal,
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              markers: Set<Marker>.of(_markers),
              polylines: {
                if (_info != null)
                  Polyline(
                    polylineId: const PolylineId('overview_polyline'),
                    color: Colors.red,
                    width: 5,
                    points: _info!.polylinePoints
                        .map((e) => LatLng(e.latitude, e.longitude))
                        .toList(),
                  ),
              },
            ),
            if (_info != null)
              Positioned(
                top: 20.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.yellowAccent,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 6.0,
                      )
                    ],
                  ),
                  child: Text(
                    '${_info?.totalDistance}, ${_info?.totalDuration}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

// information/instructions: instantiates google map cntlr 
// and calls functions to set up markers
// @params: Google Map Controller 
// @return: nothing returned
// bugs: none
// TODO: none
  void _onMapCreated(GoogleMapController _cntlr) {
    _googleMapController = _cntlr;
    fetchAndSetBikes();
    _setMarkers();
    _getCurrentLocation();
  }

// information/instructions: get bike list
// and set to variable for easy access
// @params: none
// @return: none
// bugs: none
// TODO: none
  void fetchAndSetBikes() async {
    Future<BikeListModel> bikeList = getBikeList();
    bikeList.then((listData) {
      List<Bike> bikes = listData.getBikes();
      setState(() {
        listofBikes1 = bikes;
      });
    });
  }
  

// information/instructions: get's the mobile device's current location and adjusts camera position accordingly
// requires user's permission to provide location to app
// @params: none
// @return: none
// bugs: none
// TODO: none
  _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _currentPosition = position;

    _googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 13),
      ),
    );
  }

// information/instructions: sets bike markers and obtains
// information from bike list
// @params: none
// @return: none
// bugs: none
// TODO: none
  Future<void> _setMarkers() async {
    _markers.clear();

    for (var element in listofBikes1) {
      double lat = element.locationLat.toDouble();
      double long = element.locationLong.toDouble();

      final Marker marker = Marker(
        markerId: MarkerId(element.name),
        position: LatLng(long, lat),
        infoWindow: InfoWindow(
          title: element.name,
          onTap: () {
            _openBikeInfoDialog(element);
          },
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        onTap: () {
          _openBikeInfoDialog(element);
        },
      );
      setState(() {
        _markers.add(marker);
      });
    }
  }

// information/instructions: opens modal bottom sheet
// and calls directions function to get directions 
// @params: none
// @return: none
// bugs: none
// TODO: none
  void _openBikeInfoDialog(element) async {
    final result = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BikeTrackDialog(
          bikeData: element,
          onTrack: () {
            Get.back();
            _getDirection(element);
          },
        );
      },
    );
  }

// information/instructions: calls google direction api to 
//obtain location and time (walking) from two points
// @params: one bike
// @return: none
// bugs: none
// TODO: none
  void _getDirection(element) async {
    if (_currentPosition == null) {
      return Future.error('Current Location not found');
    }

    _userLocation =
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    _endLocation = LatLng(element.locationLong, element.locationLat);

    final directions = await DirectionsRepository()
        .getDirections(origin: _userLocation, destination: _endLocation);

    setState(() => _info = directions);
  }

// information/instructions: when user arrives near the bike
// the user is presented option to check-out bike
// @params: none
// @return: none
// bugs: none
// TODO: none
  void _showDestinationDialog() async {
    LatLng _finalLocation = _endLocation!;

    _googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _finalLocation, zoom: 15.5, tilt: 50.0),
      ),
    );

    // information/instructions: bike details are displayed in modal bottom
    // provides user option to check-out bike
    final result = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("You have arrived at the bike."),
              //BIKE IS SEEN
              ElevatedButton(
                onPressed: () {
                  //To DO: IMPLEMENT REDIRECT TO PROFILE PAGE W/BIKE INFO + LOCK COMBO
                  Get.back();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                    primary: Colors.blue, elevation: 0),
                child: const Text("Proceed to Bike Check-out"),
              ),
              //BIKE IS MISSING
              ElevatedButton(
                onPressed: () {
                  //To DO: SEND REQUET TO BACK_END TO MARK BIKE AS MISSING
                  Get.back();
                  Get.back();
                },
                style:
                    ElevatedButton.styleFrom(primary: Colors.red, elevation: 0),
                child: const Text("Report Bike Missing"),
              ),
              const Text(
                  "Bike will be reported missing to The Bike Kollective."),
              const Text(
                  "You will be redirected to the bike page to find a new bike."),
            ],
          ),
        );
      },
    );
  }

// information/instructions: revised modal bottom to show 
// if bike is not within vicinity to meet check-in criteria 
// utilizes Haversine formula to obtain distnace between two points
// @params: none
// @return: none
// bugs: none
// TODO: none
  void _showNearBikeDialog() async {
    num distance;
    LatLng _finalLocation = _endLocation!;

    _googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _finalLocation, zoom: 14.5, tilt: 50.0),
      ),
    );

    //calls haversine formula
    distance = GreatCircleDistance(
            latitude1: _userLocation!.latitude,
            longitude1: _userLocation!.longitude,
            latitude2: _finalLocation.latitude,
            longitude2: _finalLocation.longitude)
        .distance();

    print("DISTANCE");
    print(distance);

  //if distance is greater than 0.5m, does not meet criteria for check-out and
  // shows modal bottom to continue routing to bike
    if (distance > 0.5) {
      final result = await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) {
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    "You are still more than 0.5 miles away from the bike."),
                const Text(
                    "Please move closer to the bike to begin bike check-out."),
                //BIKE IS SEEN
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blue, elevation: 0),
                  child: const Text("Return to Route"),
                ),
              ],
            ),
          );
        },
      );
  //if distance is less than 0.5m, meets criteria for check-out and
  // shows modal bottom to proceed to bike check-out
    } else {
      final result = await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) {
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("You have arrived at the bike."),
                //BIKE IS SEEN
                ElevatedButton(
                  onPressed: () {
                    //To DO: IMPLEMENT REDIRECT TO PROFILE PAGE W/BIKE INFO + LOCK COMBO
                    Get.back();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blue, elevation: 0),
                  child: const Text("Proceed to Bike Check-out"),
                ),
                //BIKE IS MISSING
                ElevatedButton(
                  onPressed: () {
                    //To DO: SEND REQUET TO BACK_END TO MARK BIKE AS MISSING
                    Get.back();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Colors.red, elevation: 0),
                  child: const Text("Report Bike Missing"),
                ),
                const Text(
                    "Bike will be reported missing to The Bike Kollective."),
                const Text(
                    "You will be redirected to the bike page to find a new bike."),
              ],
            ),
          );
        },
      );
    }
  }
}
