import 'package:flutter/material.dart';
import 'package:safespace/screens/register.dart';
import 'package:safespace/variables.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String? email, password;

  submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      auth.signInWithEmailAndPassword(
        email: email!,
        password: password!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
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
                SizedBox(height: 15),
                Text("SafeSpace",
                    style: fontStyle(25, Colors.black, FontWeight.w700)),
                SizedBox(height: 20),
                Form(
                    key: _formKey,
                    child: Container(
                        margin: EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  prefixIcon:
                                      Icon(Icons.email, color: Colors.white),
                                  labelStyle: fontStyle(20, Colors.white),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.blue, width: 3.0),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      )),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 1),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                ),
                                onSaved: (input) => email = input!,
                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  prefixIcon:
                                      Icon(Icons.lock, color: Colors.white),
                                  labelStyle: fontStyle(20, Colors.white),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.blue, width: 3.0),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      )),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 1),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                ),
                                onSaved: (input) => password = input!,
                                obscureText: true,
                              ),
                              SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ElevatedButton(
                                    onPressed: submit,
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.blue),
                                    child: Text('Login',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                        ))),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: fontStyle(15),
                                  ),
                                  SizedBox(height: 20),
                                  InkWell(
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  RegisterPage())),
                                      child: Text("Register",
                                          style: fontStyle(15, Colors.cyan)))
                                ],
                              )
                            ])))
              ])),
        ));
  }
}
