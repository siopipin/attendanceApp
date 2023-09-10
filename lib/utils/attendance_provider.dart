import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:presensi_app/utils/global_config.dart';

enum StatePage { initial, loading, loaded, error, nulled }

class AttendanceProvider with ChangeNotifier {
  initial() {
    setKartuTerdeteksi = false;
    setStatePage = StatePage.initial;
    setResultData = "Tidak ada kartu yang terdeteksi";
    // setText = "";

    //kartu
    setNoKartu = "";
  }

  String? _noKartu = "";
  String get noKartu => _noKartu!;
  set setNoKartu(val) {
    _noKartu = val;
    notifyListeners();
  }

  // TextEditingController ctrl = TextEditingController();
  // set setText(val) {
  //   ctrl = TextEditingController(text: val);
  //   notifyListeners();
  // }

  String _resultData = "Tidak ada kartu yang terdeteksi";
  String get resultData => _resultData;
  set setResultData(val) {
    _resultData = val;
    notifyListeners();
  }

  bool _kartuTerdeteksi = false;
  bool get statusKartu => _kartuTerdeteksi;
  set setKartuTerdeteksi(val) {
    _kartuTerdeteksi = val;
    notifyListeners();
  }

  StatePage _statePage = StatePage.initial;
  StatePage get statePage => _statePage;
  set setStatePage(val) {
    _statePage = val;
    notifyListeners();
  }

  // API action
  Future<List> apiPostAttendance({
    required String no_kartu,
    required String capture,
  }) async {
    List result = [];
    try {
      setStatePage = StatePage.loading;
      var url = Uri.parse('${Config().baseURL}absensi_siswa');
      var request = http.MultipartRequest("POST", url);
      request.fields['no_kartu'] = no_kartu;
      request.files.add(await http.MultipartFile.fromPath('capture', capture,
          contentType: MediaType('image', 'jpeg')));
      await request.send().then((response) async {
        print("Data: $no_kartu dan response= ${response.statusCode}");
        setKartuTerdeteksi = false;
        var data = json.decode(await response.stream.bytesToString());
        result = [data['statuscode'], data['message']];
        setStatePage = StatePage.loaded;
        // ctrl.clear();
      });
    } catch (e) {
      result = [0, "-"];
      setStatePage = StatePage.error;
    }

    return result;
  }
}
