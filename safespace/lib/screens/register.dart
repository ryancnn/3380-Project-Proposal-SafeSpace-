import 'package:flutter/material.dart';
import 'package:safespace/variables.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String? email, username, password, confirmPassword;

  register() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      auth
          .createUserWithEmailAndPassword(email: email!, password: password!)
          .then((signedUser) {
        usercollection.doc(signedUser.user!.uid).set({
          'username': username,
          'profile_picture':
              "https://uwm.edu/police/wp-content/plugins/uwmpeople/images/profile-default.jpg",
          'bio': "",
        });
        database
            .child("users")
            .child(signedUser.user!.uid)
            .set({'username': username, 'groups': ""});
        auth.signInWithEmailAndPassword(
          email: email!,
          password: password!,
        );
        Navigator.pop(context);
        return {
          auth.currentUser!.updateDisplayName(username),
          auth.currentUser!.updatePhotoURL(
              "https://uwm.edu/police/wp-content/plugins/uwmpeople/images/profile-default.jpg"),
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Color(0xffAC6EC3),
                Color(0xff4A7BA4),
                Color(0xff584C9D)
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            ),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              SizedBox(height: 50),
              SizedBox(height: 20),
              Text("TakeOne",
                  style: fontStyle(25, Colors.black, FontWeight.w700)),
              SizedBox(height: 10),
              Form(
                  key: _formKey,
                  child: Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      child: Column(mainAxisSize: MainAxisSize.min, children: <
                          Widget>[
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "Username",
                            prefixIcon: Icon(Icons.lock, color: Colors.white),
                            labelStyle: fontStyle(20, Colors.white),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 3.0),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                )),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                          ),
                          validator: (input) =>
                              !(input!.length > 4) && input.trim().isEmpty
                                  ? 'Username Invalid'
                                  : null,
                          onSaved: (input) => username = input!,
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email, color: Colors.white),
                            labelStyle: fontStyle(20, Colors.white),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 3.0),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                )),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                          ),
                          validator: (input) => !input!.contains('@')
                              ? 'Please enter a valid email'
                              : null,
                          onSaved: (input) => email = input!,
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: Icon(Icons.lock, color: Colors.white),
                            labelStyle: fontStyle(20, Colors.white),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 3.0),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                )),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                          ),
                          validator: (input) => input!.length < 6
                              ? 'Password must be at least 6 characters'
                              : null,
                          onSaved: (input) => password = input!,
                          obscureText: true,
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            prefixIcon: Icon(Icons.lock, color: Colors.white),
                            labelStyle: fontStyle(20, Colors.white),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 3.0),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                )),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                          ),
                          validator: (input) => confirmPassword == password
                              ? null
                              : 'Passwords must match',
                          onSaved: (input) => confirmPassword = input!,
                          obscureText: true,
                        ),
                        SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ElevatedButton(
                              onPressed: register,
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.blue),
                              child: Text('Register',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                  ))),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: fontStyle(15),
                            ),
                            SizedBox(height: 20),
                            InkWell(
                                onTap: () => Navigator.pop(context),
                                child: Text("Login",
                                    style: fontStyle(15, Colors.cyan)))
                          ],
                        )
                      ])))
            ])));
  }
}
