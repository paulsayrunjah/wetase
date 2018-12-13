library wetaseutil;

import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'dart:async';
import 'dart:io';
import 'package:permission/permission.dart';
import 'package:fluttertoast/fluttertoast.dart';

gotoView(context, view) {
  Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => view,
      ));
}

Future<String> scanImage(File imageFile) async {
  String text = null;
  final FirebaseVisionImage visionImage =
      FirebaseVisionImage.fromFile(imageFile);

  final FirebaseVisionDetector textDetect =
      FirebaseVision.instance.textRecognizer();

  final dynamic results =
      await textDetect.detectInImage(visionImage) ?? <dynamic>[];

  List list = new List();
  for (TextBlock textBlock in results.blocks) {
    print(textBlock.text);
    if (isLicensePlate(textBlock.text)) {
      list.add(textBlock.text);
    }
  }

  if (list.length > 0) {
    text = list[0];
  }

  return text;
  //print(list);
}

listLicensePlates(list) {
  return list;
}

isLicensePlate(text) {
  RegExp regExp = new RegExp(r"^u[a-zA-z]{2}");
  return (regExp.hasMatch(text));
}

formatPhoneNumber(number){
  RegExp regExp = new RegExp(r"[a-zA-Z\s-()+]");
  var replaced = number.replaceAll(regExp,'');
  RegExp reg256 = new RegExp(r"^256");
  return (replaced.substring(0,3) == "256") ? replaced.replaceAll(reg256, "0") : replaced;
}

Future<bool> hasPermission(requestedPermission) async {
  var allPermissions = {
    "location" : PermissionName.Location,
    "contacts" : PermissionName.Contacts,
    "stogare" : PermissionName.Storage
  };
  var hasPermission = false;
  List<Permissions> permissions =
      await Permission.getPermissionStatus([allPermissions[requestedPermission]]);
  permissions.forEach((permission) {
    if (permission.permissionStatus.toString() == "PermissionStatus.allow") {
      hasPermission = true;
    }
  });

  return hasPermission;
}

Future<bool> requestPermission(requestedPermission, context) async {
  var allPermissions = {
    "location" : PermissionName.Location,
    "contacts" : PermissionName.Contacts,
    "stogare" : PermissionName.Storage
  };

  final res = await Permission.requestSinglePermission(allPermissions[requestedPermission]);
  return res.toString() == "PermissionStatus.allow";
}

alert(context, title, content, onAction) {
    showDialog(
      context:context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: content,
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Ok"),
              onPressed: onAction,
            ),
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  class DialogContent extends StatelessWidget {

  final text;
  DialogContent(this.text);

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Text(this.text),
    );
  }
}
