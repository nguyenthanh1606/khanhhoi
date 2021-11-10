import 'package:sea_demo01/src/model/infouser_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class InfoUserByUserName{
    late Future<InfoUser> _InfoUserByUserName;
    Future<InfoUser> getInfoUserByUserName() async {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('token');
      final _data = prefs.getString('user');
      var url = Uri.parse(
          'https://i-sea.khanhhoi.net/api/user/getInfobyUsername/'+_data.toString());
      String ApiKey = data.toString().replaceAll('"', "");
      Map<String, String> requestHeaders = {
        'ClientIP': '192.168.2.54',
        'ApiKey': ApiKey,
      };
      final response = await http.get(url, headers: requestHeaders);
      if (response.statusCode == 200) {
        return InfoUser.fromJson(convert.jsonDecode(response.body));
      } else {
        throw Exception('Failed to load info user');
      }
    }
}