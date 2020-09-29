import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:stacked/stacked.dart';
import 'login_viewmodel.dart';

import '../../../core/shared/constants.dart';

import '../../../core/widgets/ui_elements/spinkit_loading_indicator.dart';
import 'widgets/whatapp_image.dart';

enum FormMode { phoneNum, userName, profilePic }

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // viewmodel
  LoginViewModel _model;
  // form global keys
  final GlobalKey<FormState> _formKeyAuth = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyUserName = GlobalKey<FormState>();
  // holds form fields data variables
  String _phoneNum;
  String _userName;
  // holds the current form mode
  FormMode _formMode;

  // response to viewmodel state changes
  Widget _buildStateWidget() {
    return StreamBuilder<ViewState>(
      stream: _model.viewState,
      builder: (context, snapshot) {
        switch (snapshot.data) {
          case ViewState.initial:
            return _buildPhoneNumForm();
            break;
          case ViewState.busy:
            return _buildProgressBarIndicator();
            break;
          case ViewState.phone:
            return _buildPhoneNumForm();
            break;
          case ViewState.username:
            return _buildUserNameForm();
            break;
          case ViewState.profilePic:
            return _buildUserProfile();
            break;
          default:
            return _buildProgressBarIndicator();
        }
      },
    );
  }

  // build progress indicator widget
  Widget _buildProgressBarIndicator() {
    return SpinkitLoadingIndicator();
  }

  // build phone number text field
  Widget _buildPhoneNumFormField() {
    return TextFormField(
        autofocus: false,
        initialValue: '+9720587675744',
        decoration: InputDecoration(
            hintText: 'Enter your phone number',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(width: .7)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                    width: .7, color: Theme.of(context).accentColor))),
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (!value.contains(
              RegExp(r'^\+?(972|0)(\-)?0?(([23489]{1}\d{7})|[5]{1}\d{8})$'))) {
            return 'Invalid phone number';
          }
          return null;
        },
        onSaved: (value) {
          _phoneNum = value;
        });
  }

  // build phone number text field
  Widget _buildUserNameFormField() {
    return TextFormField(
        key: ValueKey('UsernameFormField'),
        autofocus: false,
        initialValue: 'omer gamliel',
        decoration: InputDecoration(
            hintText: 'Enter username',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(width: .7)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                    width: .7, color: Theme.of(context).accentColor))),
        keyboardType: TextInputType.text,
        validator: (value) {
          if (!value.contains(
              RegExp(r"""^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*$"""))) {
            return 'Invalid username';
          }
          return null;
        },
        onSaved: (value) {
          _userName = value;
        });
  }

  // build continue button
  Widget _buildContinueButton() {
    return RaisedButton(
      key: const ValueKey('CONTINUE'),
      onPressed: _submitForm,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      padding: const EdgeInsets.all(0.0),
      child: Ink(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[kPrimaryColor, Colors.green],
          ),
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        child: Container(
          width: 150,
          constraints: const BoxConstraints(minWidth: 88.0, minHeight: 36.0),
          alignment: Alignment.center,
          child: Text(
            'CONTINUE',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  // build Form phone num auth
  Widget _buildPhoneNumForm() {
    _formMode = FormMode.phoneNum;
    return Form(
      key: _formKeyAuth,
      child: Container(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: _buildPhoneNumFormField(),
      ),
    );
  }

  // build user name form
  Widget _buildUserNameForm() {
    _formMode = FormMode.userName;
    return Form(
      key: _formKeyUserName,
      child: Container(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: _buildUserNameFormField(),
      ),
    );
  }

  // build user profile
  Widget _buildUserProfile() {
    _formMode = FormMode.profilePic;
    return Container(
      padding: const EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey,
            minRadius: 45,
          ),
          SizedBox(height: 10.0),
          FlatButton(
              child: Text('PICK PROFILE PIC'), onPressed: () => print('pick')),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [

          //     SizedBox(width: 5.0),
          //     FlatButton(child: Text('TAKE A NEW PICTURE'), onPressed: null),
          //   ],
          // )
        ],
      ),
    );
  }

  // submit form according to formMode [PhoneNum/UserName]
  void _submitForm() {
    if (_formMode == FormMode.phoneNum) {
      _submitPhoneNumForm();
    } else if (_formMode == FormMode.userName) {
      _submitUserNameForm();
    } else if (_formMode == FormMode.profilePic) {
      _model.submitProfilePic();
    }
  }

  //  submit phone num form
  void _submitPhoneNumForm() async {
    // validate phone num field
    if (_formKeyAuth.currentState.validate()) {
      // save phone num value
      _formKeyAuth.currentState.save();
      _model.submitPhoneAuth(_phoneNum);
    }
  }

  // submit user name form
  void _submitUserNameForm() async {
    // validate username field
    if (_formKeyUserName.currentState.validate()) {
      _formKeyUserName.currentState.save();
      _model.submitUsernameAuth(_userName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoginViewModel>.nonReactive(
        viewModelBuilder: () => LoginViewModel(),
        builder: (context, model, child) {
          _model = model;
          return SafeArea(
            top: false,
            child: Scaffold(
                body: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          'ACCOUNT SETUP',
                          style: GoogleFonts.raleway().copyWith(fontSize: 30),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        child: _buildStateWidget(),
                      ),
                      const SizedBox(height: 15),
                      Align(
                          alignment: Alignment.center,
                          child: _buildContinueButton())
                    ],
                  ),
                ),
                Align(alignment: Alignment.bottomCenter, child: WhatsAppImage())
              ],
            )),
          );
        });
  }
}
