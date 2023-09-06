// ignore_for_file: prefer_typing_uninitialized_variables, no_leading_underscores_for_local_identifiers

import 'dart:io';
import 'package:http/http.dart';
import 'package:presensi_app/utils/global_config.dart';
import 'package:presensi_app/utils/shared_preferences.dart';

class ApiBaseHelper {
  Client http = Client();

  Future<String> getToken() async {
    return await SharedData().showToken();
  }

  Future<dynamic> get({required String url, bool needToken = false}) async {
    var responseJson;
    try {
      var _token = await getToken();
      var header = needToken
          ? {
              HttpHeaders.contentTypeHeader: 'application/json',
              "Authorization": "Bearer $_token"
            }
          : null;
      print("url: ${Uri.parse(Config().baseURL + url)}");
      final response =
          await http.get(Uri.parse(Config().baseURL + url), headers: header);

      responseJson = [response.statusCode, response.body];
    } on SocketException {
      responseJson = [null, null];
    }

    return responseJson;
  }

  Future<dynamic> post(
      {required String url, required data, bool needToken = false}) async {
    var responseJson;
    try {
      var _token = await getToken();
      var header = needToken
          ? {
              // HttpHeaders.contentTypeHeader: 'multipart/form-data',
              'Authorization': 'Bearer $_token'
            }
          : null;
      print("url: ${Uri.parse(Config().baseURL + url)}");
      print('Header: $header');
      print('Data: $data');
      final response = await http.post(Uri.parse(Config().baseURL + url),
          body: data, headers: header);
      print('StatusCode: ${response.statusCode}');
      responseJson = [response.statusCode, response.body];
    } on SocketException {
      responseJson = [null, null];
    }

    return responseJson;
  }

  Future<dynamic> postLogin(
      {required String url, required data, bool needToken = false}) async {
    var responseJson;
    try {
      print("Url: ${Uri.parse(Config().baseURL + url)}");
      print('Data: $data');
      final response =
          await http.post(Uri.parse(Config().baseURL + url), body: data);
      print('StatusCode: ${response.statusCode}');
      responseJson = [response.statusCode, response.body];
    } on SocketException {
      responseJson = [null, null];
    }

    return responseJson;
  }
}
