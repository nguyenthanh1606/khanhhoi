import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sea_demo01/src/model/shipuser_model.dart';
import 'package:sea_demo01/src/repositories/pin_pill_info.dart';
import 'package:sea_demo01/src/ui/compoment/map_pin_pill.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapGoogle extends StatefulWidget {
  const MapGoogle({Key? key}) : super(key: key);

  @override
  _MapGoogleState createState() => _MapGoogleState();
}

const double CAMERA_ZOOM = 6;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 0;
const LatLng SOURCE_LOCATION = LatLng(10.88790, 106.71819);
const LatLng DEST_LOCATION = LatLng(10.01450, 105.77900);

class _MapGoogleState extends State<MapGoogle> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  List<AllShipByUserId> allShipByUserId = [];
  late String ApiKey;
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPIKey = 'AIzaSyDO5GoIsghz2hD3oi3CuhDxNgKuN3Gz7KE';
  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor destinationIcon;
  double pinPillPosition = -120;
  PinInformation currentlySelectedPin = PinInformation(
    pinPath: 'assets/icons/driving_pin.png',
    avatarPath: 'assets/images/friend1.jpg',
    location: LatLng(0, 0),
    vehicalNumber: 'Start Location',
    labelColor: Colors.grey,
    address: '',
    status: '',
    timeSave: '',
  );
  late PinInformation sourcePinInfo;
  late PinInformation _sourcePinInfo;
  late PinInformation destinationPinInfo;

  Future<void> getAllShipByUserId() async {
    var url = Uri.parse('https://i-sea.khanhhoi.net/api/Ship/getAllship/23');
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('token');
    ApiKey = data.toString().replaceAll('"',"");
    Map<String, String> requestHeaders = {
       'ClientIP': '192.168.2.54',
       'ApiKey': ApiKey,
     };
    var response = await http.get(url,headers:requestHeaders);
    var jsonData = convert.jsonDecode(response.body);
    List<dynamic> body = convert.jsonDecode(response.body);
    allShipByUserId = body.map((dynamic item) => AllShipByUserId.fromJson(item)).toList();
  }

  @override
  void initState() {
    super.initState();
    getAllShipByUserId();
    setSourceAndDestinationIcons();
  }

  void setMapPins() {
    String _status = "";
    _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(allShipByUserId[0].imei),
        position: LatLng(allShipByUserId[0].latitude,allShipByUserId[0].longitude),
        onTap: () {
          setState(() {
            currentlySelectedPin = sourcePinInfo;
            pinPillPosition = 0;
          });
        },
        icon: sourceIcon));

    if(allShipByUserId[0].isActive == true){
      _status = "Hoạt động";
    }else{
      _status = "Mất tín hiệu";
    }

    sourcePinInfo = PinInformation(
      vehicalNumber: allShipByUserId[0].tentau,
      location: LatLng(allShipByUserId[0].latitude,allShipByUserId[0].longitude),
      pinPath: "assets/icons/driving_pin.png",
      avatarPath: "assets/images/friend1.jpg",
      labelColor: Colors.blueAccent,
      address: 'Phường 12, Thành phố Vũng Tầu, Bà Rịa - Vũng Tàu, Việt Nam',
      status: _status,
      timeSave: allShipByUserId[0].dateSave,
    );
    
    _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(allShipByUserId[1].imei),
        position: LatLng(allShipByUserId[1].latitude,allShipByUserId[1].longitude),
        onTap: () {
          setState(() {
            currentlySelectedPin = _sourcePinInfo;
            pinPillPosition = 0;
          });
        },
        icon: sourceIcon));

    if(allShipByUserId[1].isActive == true){
      _status = "Hoạt động";
    }else{
      _status = "Mất tín hiệu";
    }

    _sourcePinInfo = PinInformation(
      vehicalNumber: allShipByUserId[1].tentau,
      location: LatLng(allShipByUserId[1].latitude,allShipByUserId[1].longitude),
      pinPath: "assets/icons/driving_pin.png",
      avatarPath: "assets/images/friend1.jpg",
      labelColor: Colors.blueAccent,
      address: 'Bình Châu, Xuyên Mộc, Bà Rịa - Vũng Tàu, Việt Nam',
      status: _status,
      timeSave: allShipByUserId[1].dateSave,
    );

    // destination pin
    _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId('destPin'),
        position: DEST_LOCATION,
        onTap: () {
          setState(() {
            currentlySelectedPin = destinationPinInfo;
            pinPillPosition = 0;
          });
        },
        icon: destinationIcon));
    
    destinationPinInfo = PinInformation(
      vehicalNumber: "59F1-01121",
      location: DEST_LOCATION,
      pinPath: "assets/icons/destination_map_marker.png",
      avatarPath: "assets/images/friend2.jpg",
      labelColor: Colors.purple,
      address: 'QL 1, Tân Hòa, Tp. Biên Hòa, Đồng Nai',
      status: 'Mất kết nối',
      timeSave: '18:49:50 03-11-2021',
    );
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/icons/driving_pin.png');

    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/icons/destination_map_marker.png');
  }

  void onMapCreated(GoogleMapController controller) {
    //controller.setMapStyle(Utils.mapStyles);
    _controller.complete(controller);
    setMapPins();
    setPolylines();
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialLocation = CameraPosition(
        zoom: CAMERA_ZOOM,
        bearing: CAMERA_BEARING,
        tilt: CAMERA_TILT,
        target: LatLng(16.20088017579864, 105.80583502701335));

    return Scaffold(
        body: Stack(children: <Widget>[
      GoogleMap(
        myLocationEnabled: true,
        compassEnabled: true,
        tiltGesturesEnabled: false,
        markers: _markers,
        polylines: _polylines,
        mapType: MapType.normal,
        initialCameraPosition: initialLocation,
        onMapCreated: onMapCreated,
        onTap: (LatLng location) {
          setState(() {
            pinPillPosition = -120;
          });
        },
      ),
      MapPinPillComponent(
          pinPillPosition: pinPillPosition,
          currentlySelectedPin: currentlySelectedPin)
    ]));
  }

  setPolylines() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPIKey,
        PointLatLng(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude),
        PointLatLng(DEST_LOCATION.latitude, DEST_LOCATION.longitude));

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {
        Polyline polyline = Polyline(
            polylineId: PolylineId("poly"),
            color: Color.fromARGB(255, 40, 122, 198),
            points: polylineCoordinates);
        _polylines.add(polyline);
      });
    }
  }
}

class Utils {
  static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';
}
