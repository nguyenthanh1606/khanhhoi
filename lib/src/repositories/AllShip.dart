import 'dart:async';
import 'package:sea_demo01/generated/l10n.dart';
import 'package:sea_demo01/src/model/shipuser_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class AllShip{
  List<AllShipByUserId> allShipByUserId = [];
  Future<void> getAllShipByUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('token');
    String ApiKey = data.toString().replaceAll('"',"");
    var url = Uri.parse('https://i-sea.khanhhoi.net/api/Ship/getAllship/4');
    Map<String, String> requestHeaders = {
       'ClientIP': '192.168.2.54',
       'ApiKey': ApiKey,
     };
    var response = await http.get(url,headers:requestHeaders);
    var jsonData = convert.jsonDecode(response.body);
    List<dynamic> body = convert.jsonDecode(response.body);
    allShipByUserId = body.map((dynamic item) => AllShipByUserId.fromJson(item)).toList();
  }
}