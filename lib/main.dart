import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Maps by AHSAN',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Map home'),
    );
  }
}

class MyHomePage extends StatefulWidget{
  MyHomePage({Key key,this.title}): super(key: key);
  final String title;

  @override
  _MyHomePageState createState()=> _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage>{
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Marker marker;
  Circle circle;
  GoogleMapController _controller;

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(23.7677,90.4825),
    zoom: 10.0,
  );
  Future<Uint8List> getMarker() async{
    ByteData byteData = await DefaultAssetBundle.of(context).load("assets/dot.png");
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData){
    LatLng latLng= LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("home"),
          position: latLng,
          rotation: newLocalData.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5,0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      circle = Circle(
          circleId: CircleId("you"),
          radius: newLocalData.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latLng,
          fillColor: Colors.blue.withAlpha(70)
      );
    });
  }
  void getCurrentLocation() async{
    try{
      Uint8List imageData = await getMarker();
      var location= await _locationTracker.getLocation();
      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null){
        _locationSubscription.cancel();
      }

      _locationSubscription= _locationTracker.onLocationChanged.listen((newLocalData){
        if(_controller != null){
          _controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
              bearing: 192.8,
              target:LatLng(newLocalData.latitude, newLocalData.longitude),
              tilt: 0,
              zoom: 18.0
          )));
          updateMarkerAndCircle(newLocalData, imageData);

        }
      });
    } on PlatformException catch(e){
      if(e.code == 'PERMISSION_DENIED'){
        debugPrint("permission denied");
      }
    }
  }

  Future<String> createAlertDialog(BuildContext context){

    TextEditingController customController = TextEditingController();
    return showDialog(context: context,builder: (context){
      return AlertDialog(
        title: Text("Type here"),
        content: TextField(
          controller: customController,
        ),
        actions: <Widget>[
          MaterialButton(
            elevation: 5.0,
            child: Text('Submit'),
            onPressed: (){
              Navigator.of(context).pop(customController.text.toString());
            },
          )
        ],
      );
    });
  }



  @override
  void dispose(){
    if(_locationSubscription != null){
      _locationSubscription.cancel();
    }
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simple map'),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: initialLocation,
        markers: Set.of((marker != null) ? [marker] : []),
        circles: Set.of((circle != null) ? [circle] : []),
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.location_searching),
          onPressed: () {
            getCurrentLocation();
            createAlertDialog(context).then((onValue){
              SnackBar mySnackBar = SnackBar(content: Text("Hello $onValue"));
              Scaffold.of(context).showSnackBar(mySnackBar);

            });
          }),
    );

  }
}

// class _MyAppState extends State<MyApp> {
//   GoogleMapController mapController;
//
//   final LatLng _center = const LatLng(45.521563, -122.677433);
//
//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Maps Sample App'),
//           backgroundColor: Colors.green[700],
//         ),
//         body: GoogleMap(
//           onMapCreated: _onMapCreated,
//           initialCameraPosition: CameraPosition(
//             target: _center,
//             zoom: 11.0,
//           ),
//         ),
//       ),
//     );
//   }
// }