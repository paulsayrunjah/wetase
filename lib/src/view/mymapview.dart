import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:wetase/src/model/placematch.dart';

class MyMapView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MyMapViewState();
  }
}

class MyMapViewState extends State<MyMapView> {
  GoogleMapController mapController;
  var _placeMatches;
  List<String> _suggestionList;
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("MapView"),
      ),
      body: new Center(
        child: new Stack(
          children: <Widget>[
            new GoogleMap(
              onMapCreated: _onMapCreated,
            ),
            new Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                child: generateAutoComplete()),
          ],
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
      if (mapController != null) {
        mapController.animateCamera(CameraUpdate.newCameraPosition(
          const CameraPosition(
            bearing: 270.0,
            target: LatLng(51.5160895, -0.1294527),
            tilt: 30.0,
            zoom: 17.0,
          ),
        ));

        
      }
    });
  }

  searchPlaces(searchPlace) async {
    final places =
        new GoogleMapsPlaces(apiKey: "AIzaSyB2Z31DSOmOapplyKPknJMSRDFYm9tAlCw");
    PlacesAutocompleteResponse res = await places.autocomplete(searchPlace);
    var placeMatchs = new Map();
    List<String> listReturn = new List();
    if (res.isOkay) {
      // list autocomplete prediction
      res.predictions.forEach((Prediction p) {
        placeMatchs[p.description] = p.placeId;
        listReturn.add(p.description);
      });

      places.dispose();
    } else {
      print(res.errorMessage);
    }

    return [placeMatchs, listReturn];
  }

  gotoPlace(placeId) async {
    final places =
        new GoogleMapsPlaces(apiKey: "AIzaSyB2Z31DSOmOapplyKPknJMSRDFYm9tAlCw");
    PlacesDetailsResponse details = await places.getDetailsByPlaceId(placeId);

    setState(() {
      
      if (mapController != null) {
        var lat =details.result.geometry.location.lat.toDouble();
        var lng =details.result.geometry.location.lng.toDouble();
  
        mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            
            bearing: 270.0,
            target: LatLng(lat, lng),
            tilt: 30.0,
            zoom: 17.0,
          ),
        ));
      }
    });

    print("\nDetails :");
    print(details.result.formattedAddress);
    print(details.result.geometry.location);
  }

  draggingMap(){

    
    
  }

  generateAutoComplete() {
    SimpleAutoCompleteTextField simpleAutoCompleteTextField;

    simpleAutoCompleteTextField = new SimpleAutoCompleteTextField(
      key: key,
      textSubmitted: (string) async{
        final placeId = _placeMatches[string];
          print(placeId);
          await gotoPlace(placeId);

       
      },
      textChanged: (text) {
        if (text.length > 2) {
          (() async {
            //sleep(const Duration(seconds: 1));
            StreamSubscription dataSub;
            if (dataSub != null) {
              dataSub.cancel();
            }
            dataSub = searchPlaces(text).asStream().listen((result) {
              if (result != null) {
                print(result);
                setState(() {
                  _placeMatches = result[0];
                  var _suggestionList = result[1];
                  simpleAutoCompleteTextField
                      .updateSuggestions(_suggestionList);
                });
              }
            });
          }());
        }
      },
      suggestions: _suggestionList == null ? [] : _suggestionList,
      decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Search',
          border: new OutlineInputBorder(
              borderSide: BorderSide(style: BorderStyle.none, width: 0.0))),
    );

    return simpleAutoCompleteTextField;
  }

  updateAutoComplete(textfield, text) async {}
}
