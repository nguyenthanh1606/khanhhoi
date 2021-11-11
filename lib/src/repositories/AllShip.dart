import 'dart:async';
import 'package:sea_demo01/generated/l10n.dart';
import 'package:sea_demo01/src/model/infouser_model.dart';
import 'package:sea_demo01/src/model/shipuser_model.dart';
import 'package:sea_demo01/src/repositories/InfoUserByUserName.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class AllShip{
  List<AllShipByUserId> allShipByUserId = [];
  Future<void> getAllShipByUserId() async {
    final prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('token');
    var data_ = prefs.getString('_id');
    String ApiKey = data.toString().replaceAll('"',"");
    String _id = data_.toString();
    var url = Uri.parse('https://i-sea.khanhhoi.net/api/Ship/getAllship/'+_id);
    final String ip = await Ipify.ipv4().toString();
    Map<String, String> requestHeaders = {
       'ClientIP': ip,
       'ApiKey': ApiKey,
     };
    var response = await http.get(url,headers:requestHeaders);
    
    var jsonData = convert.jsonDecode(response.body);
    List<dynamic> body = convert.jsonDecode(response.body);
    allShipByUserId = body.map((dynamic item) => AllShipByUserId.fromJson(item)).toList();
  }
}