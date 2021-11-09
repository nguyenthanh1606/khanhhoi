import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sea_demo01/generated/l10n.dart';
import 'package:sea_demo01/src/ui/compoment/compoment.dart';
import 'package:sea_demo01/src/ui/screen.dart';
import 'package:sea_demo01/src/ui/themes/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'index.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  double _headerHeight = 250;
  Key _formKey = GlobalKey<FormState>();
  bool _isLoading = false; 
  TextEditingController _userControler = new TextEditingController();
  TextEditingController _passControler = new TextEditingController();

  signIn(String UserName,String PassWord, int Type) async{
    var url = Uri.parse('https://i-sea.khanhhoi.net/home/login');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final String internal = await Ipify.ipv4().toString();
    Map<String, String> requestHeaders = {
       'ClientIP': '192.168.2.54',
     };
    Map body = {"UserName_": UserName, "pass_": PassWord, "type_": Type};
    var jsonResponse;
    var res = await http.post(url,headers:requestHeaders,body:json.encode(body));
    if(res.statusCode ==200){
      jsonResponse = json.decode(res.body);
      if(jsonResponse != null){
        setState(() {
          _isLoading = false;
        });
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', jsonResponse);
        Navigator.push(context, MaterialPageRoute(builder: (context) =>  ScreenMain())
      );
      }else{
        showDialog(context: context,
         builder: (context) => AlertDialog(
          title: Text("Cảnh báo đăng nhập"),
          content: Text("Sai tài khoản hoặc mật khẩu vui lòng kiểm tra lại"),
          actions: [
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                      "Yes",
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 16,
                          fontFamily: "Arial"),
                    ),)
          ],
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: _headerHeight,
              child: HeaderCompoment(_headerHeight, true,
                  Icons.login_rounded), //let's create a common header widget
            ),
            SafeArea(
              child: Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  margin: EdgeInsets.fromLTRB(
                      20, 10, 20, 10), // This will be the login form
                  child: Column(
                    children: [
                      Text(
                        'Hello',
                        style: TextStyle(
                            fontSize: 60, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Signin into your account',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 30.0),
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Container(
                                child: TextField(
                                  controller: _userControler,
                                  decoration: ThemeHelper().textInputDecoration(
                                      'User Name', 'Enter your user name'),
                                ),
                                decoration:
                                    ThemeHelper().inputBoxDecorationShaddow(),
                              ),
                              SizedBox(height: 30.0),
                              Container(
                                child: TextField(
                                  obscureText: true,
                                  controller: _passControler,
                                  decoration: ThemeHelper().textInputDecoration(
                                    S.of(context).authPageInputPassword,
                                    S
                                        .of(context)
                                        .authPageValidatorEmptyPassword,
                                  ),
                                ),
                                decoration:
                                    ThemeHelper().inputBoxDecorationShaddow(),
                              ),
                              SizedBox(height: 15.0),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 10, 20),
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ForgotPasswordPage()),
                                    );
                                  },
                                  child: const Text(
                                    "Forgot your password?",
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                decoration:
                                    ThemeHelper().buttonBoxDecoration(context),
                                child: ElevatedButton(
                                  style: ThemeHelper().buttonStyle(),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(40, 10, 40, 10),
                                    child: Text(
                                      S
                                          .of(context)
                                          .authPageButtonLogin
                                          .toUpperCase(),
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  onPressed: () {
                                    //After successful login we will redirect to profile page. Let's create profile page now
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    signIn(_userControler.text, _passControler.text, 3);
                                  },
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
                                //child: Text('Don\'t have an account? Create'),
                                child: Text.rich(TextSpan(children: [
                                  TextSpan(text: "Don\'t have an account? "),
                                  TextSpan(
                                    text: 'Create',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    RegistrationPage()));
                                      },
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).accentColor),
                                  ),
                                ])),
                              ),
                            ],
                          )),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
