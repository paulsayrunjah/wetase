import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wetase/src/util.dart' show scanImage, gotoView;
import 'contactpickerview.dart';
import 'package:wetase/src/view/mymapview.dart';

class HomeView extends StatefulWidget {
  final context;
  HomeView(this.context);
  @override
  State<StatefulWidget> createState() {
    return new HomeState(this.context);
  }
}

class HomeState extends State<HomeView> {
  final context;
  HomeState(this.context);

  File _image;
  var _licencse_plate = "Not found";
  var txtLicensePlate = new TextEditingController();

  Future getImage(mySource) async {
    var imageSource = (mySource == "gallery") ? ImageSource.gallery : ImageSource.camera;
    var image = await ImagePicker.pickImage(source: imageSource);
    var found_plate = await scanImage(image);
    setState(() {
      this._licencse_plate = (found_plate != null) ? found_plate : "Not found";
      this.txtLicensePlate.text = this._licencse_plate;
    });

    //print(this._licencse_plate);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("wetase"),
      ),
      body: new Center(
          child: new Container(
        padding: new EdgeInsets.all(20.0),
        child: new Column(
          children: <Widget>[
            new TextField(
              controller: txtLicensePlate,
              decoration: new InputDecoration(
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(10.0),
                    ),
                  ),
                  hintText: "Access Code"),
            ),
            new RaisedButton(
              onPressed: () async {
                await getImage("gallery");
              },
              color: Colors.blue,
              child: new Text("Picture Gallery"),
            ),
            new RaisedButton(
              onPressed: () async {
                await getImage("camera");
              },
              color: Colors.blue,
              child: new Text("Picture Camera"),
            ),
            new RaisedButton(
              onPressed: () =>
                  gotoView(context, new ContactPickerView(context)),
              color: Colors.blue,
              child: new Text("Conatcts"),
            ),
            new RaisedButton(
              onPressed: (){
                gotoView(context, new MyMapView());
              },
              child: new Text("Map"),
            ),
            new Text("License plate found: " + this._licencse_plate)
          ],
        ),
      )),
    );
  }
}
