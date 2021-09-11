import 'package:brew_crew/models/user.dart';
import 'package:brew_crew/services/database.dart';
import 'package:brew_crew/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:brew_crew/shared/constants.dart';
import 'package:provider/provider.dart';

class SettingsForm extends StatefulWidget {

  @override
  _SettingsFormState createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {

  final _formKey = GlobalKey<FormState>();
  final List<String> sugars = ['0', '1', '2', '3', '4'];

  // form values
  String? _currentName;
  String? _currentSugars;
  int? _currentStrength;

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<Users?>(context);

    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user!.uid).userData,
      builder: (context, snapshot) {
        if(snapshot.hasData){// return true or false
          UserData? userData = snapshot.data;
          return Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Text(
                  'Update your brew settings',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  initialValue: userData!.name,
                  decoration: textInputDecoration.copyWith(hintText: 'Name'),
                  validator: (val) =>
                  val!.isEmpty ? 'Please enter a name' : null,
                  onChanged: (val){
                    setState(() {
                      _currentName = val;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                // dropdown => sugars
                DropdownButtonFormField<String>(
                  value: userData.sugars,
                  decoration: textInputDecoration,
                  items: sugars.map((sugar) {
                    return DropdownMenuItem(
                      value: sugar,
                      child: Text('$sugar sugar(s)'),
                    );
                  }).toList(),
                  // if the onChanged callback is null or the list of items is null
                  // then the dropdown button will be disabled
                  onChanged: (val) => setState(() => _currentSugars = val as String),
                ),
                Slider(
                  value: (_currentStrength ?? userData.strength).toDouble(), // initial value
                  min: 100.0,
                  max: 900.0,
                  divisions: 8,
                  onChanged: (val) => setState(() => _currentStrength = val.round()),
                  activeColor: Colors.brown[_currentStrength ?? userData.strength],
                  inactiveColor: Colors.brown[_currentStrength ?? userData.strength],
                ),
                // slider => strength
                // button for saving updates
                SizedBox(height: 20.0),
                RaisedButton(
                    color: Colors.pink[400],
                    child: Text(
                      'Update',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () async{
                      // print(_currentName);
                      // print(_currentSugars);
                      // print(_currentStrength);
                      if(_formKey.currentState!.validate()){
                        await DatabaseService(uid: user.uid).updateUserData(
                          _currentSugars ?? userData.sugars,
                          _currentName ?? userData.name,
                          _currentStrength ?? userData.strength,
                        );
                        // to close the bottom sheet and direct to the home
                        Navigator.pop(context);
                      }
                    }
                ),
              ],
            ),
          );
        } else{
          return Loading();
        }
      }
    );
  }
}
