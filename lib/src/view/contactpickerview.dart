import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:wetase/src/util.dart'
    show hasPermission, requestPermission, formatPhoneNumber;
import 'package:wetase/src/model/mycontact.dart';
import 'package:wetase/src/dbhelper.dart';

class ContactPickerView extends StatefulWidget {
  final context;
  ContactPickerView(this.context);

  @override
  State<StatefulWidget> createState() {
    print("object");
    return new ContactPicker(this.context);
  }
}

class ContactPicker extends State<ContactPickerView> {
  var _contactList;
  var _isloading = true;
  var _loadingText = "Please wait....";
  final context;
  ContactPicker(this.context);

  void initState() {
    super.initState();

    (() async {
      var contactList = await getContactsList(this.context);
      setState(() {
        if (contactList != null) {
          _isloading = false;
          _contactList = contactList;
        }
      });
    })();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Contacts"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 2.0,
        onPressed: () async {
          if (_contactList != null && _contactList.length > 0) {
            setState(() {
              _isloading = true;
              _loadingText = "Updating your list....";
            });
            final db = await new DBHelper();
            await db.deleteAll("MyContacts");
            final fields = "name, number";
            for (MyContact myContact in _contactList) {
              if (myContact.isListed) {
                final values =
                    "'" + myContact.name + "'," + "'" + myContact.phone + "'";
                await db.insert("MyContacts", fields, values);
              }
            }

            (() async {
              var contactList = await getContactsList(this.context);
              setState(() {
                _isloading = false;
                _contactList = contactList;
              });
            })();
          }
        },
        tooltip: 'Add something',
      ),
      body: new Center(
        child: _isloading
            ? new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new CircularProgressIndicator(),
                new Text(_loadingText)
              ],
            ) 
            : new Container(
                color: Color(0xFFCCCCCC),
                child: new ListView.builder(
                  itemCount:
                      this._contactList != null ? this._contactList.length : 0,
                  itemBuilder: (context, i) {
                    return new ContactItem(_contactList[i]);
                  },
                ),
              ),
      ),
    );
  }

  getContactsList(context) async {
    // Get all contacts
    final checkPermission = await hasPermission("contacts");
    if (!checkPermission) {
      final res = await requestPermission("contacts", context);
      if (!res) {
        return null;
      }
    }
    final db = await new DBHelper();
    var dbList = await db.getAll("MyContacts");

    Iterable<Contact> contacts = await ContactsService.getContacts();
    List<MyContact> myList = new List();
    for (Contact c in contacts) {
      final phone = (c.phones != null && c.phones.length > 0
          ? formatPhoneNumber(c.phones.first.value)
          : "No Phone number");
      var myContact = new MyContact(c.displayName, phone, false);
      isInList(myContact, dbList);
      myList.add(myContact);
    }
    return myList;
  }

  isInList(contact, list) {
    for (var i = 0; i < list.length; i++) {
      if ((contact.name == list[i]["name"] &&
          contact.phone == list[i]["number"])) {
        contact.isListed = true;
        break;
      }
    }
  }
}

class ContactItem extends StatefulWidget {
  final contact;
  ContactItem(this.contact);

  @override
  State<StatefulWidget> createState() {
    return new ContactItemState(contact);
  }
}

class ContactItemState extends State<ContactItem> {
  final contact;

  List<MyContact> selectedList = new List();

  ContactItemState(this.contact);

  addToSelected() {}

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
      child: new FlatButton(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        color: Colors.white30,
        onPressed: () {
          setState(() {
            this.contact.isListed = !this.contact.isListed;
          });
        },
        child: new Container(
            child: new Row(
          children: <Widget>[
            new Expanded(
              flex: 1,
              child: new Icon(Icons.contact_phone),
            ),
            new Expanded(
              flex: 6,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(
                    this.contact.name,
                    style: new TextStyle(fontSize: 17.0),
                  ),
                  new Container(),
                  new Text(this.contact.phone)
                ],
              ),
            ),
            new Expanded(
              flex: 1,
              child: new Checkbox(
                value: this.contact.isListed,
                onChanged: (bool value) {
                  setState(() {
                    this.contact.isListed = value;
                  });
                },
              ),
            ),
          ],
        )),
      ),
    );
  }
}
