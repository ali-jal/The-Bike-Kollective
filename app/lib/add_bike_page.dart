import 'package:flutter/material.dart';
import 'package:the_bike_kollective/global_values.dart';
import 'package:the_bike_kollective/profile_view.dart';
import 'package:the_bike_kollective/style.dart';
import 'models.dart';
import 'MenuDrawer.dart';
import 'requests.dart';
import 'style.dart';
import 'global_values.dart';
import 'package:checkbox_formfield/checkbox_formfield.dart';

// information/instructions:
// @params:
// @return:
// bugs: no known bugs

// information/instructions: This class creates an object that
// is passed to AddBikePage when navigating to that page.
// That route contains a function which can access it. It seems
// weird because the AddBikePage class doesn't take an argument
// according to the class declaration, but you pass it anyway,
// and it is accessed in the build method as an argument.
// The object contains an image file encoded in base 64.
// @params: none
// @return: none
// bugs: no known bugs
class BikeFormArgument {
  final String imageStringBase64;
  BikeFormArgument(this.imageStringBase64);
}

// information/instructions: This page view has a form that users
// fill out with bike data. When they submit it, a new bike is
// added to the database.
// @params: User
// @return: Page with form.
// bugs: no known bugs
class AddBikePage extends StatelessWidget {
  AddBikePage({
    Key? key,
  }) : super(key: key);
  static const routeName = '/new-bike-form';
  final Future<User> currentUser = getUser(getCurrentUserIdentifier());

  @override
  Widget build(BuildContext context){
    final args = ModalRoute.of(context)!
    .settings.arguments as BikeFormArgument;
    return Scaffold( 
        appBar: AppBar(
          title: const Text('The Bike Kollective'),
          leading:
              (ModalRoute.of(context)?.canPop ?? false) ? BackButton() : null,
        ),
        endDrawer: const MenuDrawer(),
        body: FutureBuilder(
          future: currentUser,
          builder: (context, AsyncSnapshot<User> snapshot) {
            if (snapshot.hasData) {
              return  AddBikeForm(
                user: snapshot.data!, 
                imageStringBase64: args.imageStringBase64
              );
            } else {
              return const CircularProgressIndicator();
            }
          }
        )
    );
  }
}

// information/instructions: This is the form that is rendered inside
// of the newBike page view.
// @params: User(), the same user supplied to the page view is passed
// to this widget
// @return: form for usker to fill out. When user taps submit, the
// input is validated, converted to JSON and sent to the database.
// bugs: no known bugs
class AddBikeForm extends StatefulWidget {
  const AddBikeForm(
      {Key? key, required this.user, required this.imageStringBase64})
      : super(key: key);
  final User user;
  final String imageStringBase64;
  @override
  State<AddBikeForm> createState() => _AddBikeFormState();
}

// State object that goes with AddBikeForm.
class _AddBikeFormState extends State<AddBikeForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();
  var bikeData = {};
  bool isChecked = false;
  List randomCoord = [];
  String type = 'Choose a Type';
  String size = 'Choose a Size';
  String releaseOfInterestFormText =
    'If, God forbid, your bike is damaged, stolen, or goes missing, it sucks to be you. By checking this box, you are agreeing not to sue us.';

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: ListView(
        
        children: <Widget>[
          // Bike Name Field
          TextFormField(
            // The validator receives the text that the user has entered.
            decoration: const InputDecoration(
              icon: Icon(Icons.pedal_bike),
              hintText: '[Give the bike a name.]',
              labelText: 'Name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please give the bike a name. (example: "Big Red" ';
              }
              return null;
            },
            onSaved: (String? value) {
              //save value of 'Name' field.
              bikeData["name"] = value;
            },
          ),  
          // Type Drop Down 
          DropdownButton<String>(
            value: type,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            style: TextStyle(color: dropdownStyle['textColor']),
            underline: Container(
              height: 2,
              color: dropdownStyle['textColor'],
            ),
            onChanged: (String? newType) {
              setState(() {
                type = newType!; 
                bikeData['type'] = newType;
              });
            },
            items: <String>['Choose a Type', 'Road', 'Mountain']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
    
          // Size Drop Down
          DropdownButton<String>(
            value: size,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            style: TextStyle(color: dropdownStyle['textColor']),
            underline: Container(
              height: 2,
              color: dropdownStyle['textColor'],
            ),
            onChanged: (String? newSize) {
              setState(() {
                size = newSize!; 
                bikeData['size'] = newSize;
              });
            },
            items: <String>['Choose a Size', 'Small', 'Medium', 'Large']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),

          // Lock Combination Field
          TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.lock),
              hintText: '[Enter the lock combination.]',
              labelText: 'Lock Combination',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the lock combination. (example: "102259" ';
              }
              return null;
            },
            onSaved: (String? value) {
              bikeData["lock_combination"] = int.parse(value!);
            },
          ),
          
          // Release Form
          Text("Release of Interest",
           style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.5)
          ),

          Container(
            //height: 150,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: Text(releaseOfInterestFormText,
              style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.25),
            ),
          ),
            
          // CheckBox Agree to Release Form
          CheckboxListTileFormField(
            title: const Text('I Agree'),
            onSaved: (bool? value) {
              print(value);
            },
            validator: (bool? value) {
              if (value == false ) {
                return 'Required';
              }
              return null;
            },
            
            contentPadding: EdgeInsets.all(1),
          ),
                 
          ElevatedButton(
            onPressed: () {
              // Validate returns true if the form is valid, or false otherwise.
              if (_formKey.currentState!.validate()) {
                _formKey.currentState?.save();
                Future imageLink =
                    getImageDownloadLink(widget.imageStringBase64);
                imageLink.then((value) {
                  bikeData['image'] = value;
                  createBike(bikeData);
                  Navigator.pushNamed(context, ProfileView.routeName);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Adding bike to the database.')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
