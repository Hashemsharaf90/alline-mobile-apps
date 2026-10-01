import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' as foundation;
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:sixvalley_delivery_boy/data/models/response/error_response.dart';
import 'package:sixvalley_delivery_boy/utill/app_constants.dart';

class ApiClient extends GetxService {
  final String appBaseUrl;
  final SharedPreferences sharedPreferences;
  static const String noInternetMessage = 'Connection to API server failed due to internet connection';
  final int timeoutInSeconds = 30;

  String? token;
  late Map<String, String>? _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    token = sharedPreferences.getString(AppConstants.token);
    updateHeader(token, sharedPreferences.getString(AppConstants.languageCode));
  }

  void updateHeader(String? token, String? languageCode) {
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      AppConstants.localizationKey: languageCode ?? AppConstants.languages[0].languageCode ?? 'en',
      'Authorization': 'Bearer $token'
    };
  }

  Future<Response> getData(String uri, {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    try {
      if (foundation.kDebugMode) {
        debugPrint('====> API GET: $uri');
      }
      http.Response _response = await http.get(
        Uri.parse(appBaseUrl+uri),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(_response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postData(String uri, dynamic body, {Map<String, String>? headers}) async {
    try {
      if (foundation.kDebugMode) {
        debugPrint('====> API POST: $uri');
      }
      http.Response _response = await http.post(
        Uri.parse(appBaseUrl+uri),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(_response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postMultipartData(String uri, Map<String, String> body, List<MultipartBody> multipartBody, {Map<String, String>? headers, List<PlatformFile>? platformFile}) async {
    try {
      if (foundation.kDebugMode) {
        debugPrint('====> API Multipart: $uri with ${multipartBody.length} files');
      }
      http.MultipartRequest _request = http.MultipartRequest('POST', Uri.parse(appBaseUrl+uri));
      _request.headers.addAll(headers ?? _mainHeaders as Map<String, String>);
      for(MultipartBody multipart in multipartBody) {
        if(foundation.kIsWeb) {
          Uint8List _list = await multipart.file.readAsBytes();
          http.MultipartFile _part = http.MultipartFile(
            multipart.key, multipart.file.readAsBytes().asStream(), _list.length,
            filename: basename(multipart.file.path), contentType: MediaType('image', 'jpg'),
          );
          _request.files.add(_part);
        }else {
          File _file = File(multipart.file.path);
          _request.files.add(http.MultipartFile(
            multipart.key, _file.readAsBytes().asStream(), _file.lengthSync(), filename: _file.path.split('/').last,
          ));
        }
      }

      if(platformFile != null ) {
        if(platformFile.isNotEmpty){
          for(PlatformFile pfile in platformFile) {
            _request.files.add(http.MultipartFile('file[]', pfile.readStream!, pfile.size, filename: basename(pfile.name)));
          }
        }
      }

      _request.fields.addAll(body);
      http.Response response = await http.Response.fromStream(await _request.send());
      return handleResponse(response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> putData(String uri, dynamic body, {Map<String, String>? headers}) async {
    try {
      if (foundation.kDebugMode) {
        debugPrint('====> API PUT: $uri');
      }
      http.Response _response = await http.put(
        Uri.parse(appBaseUrl+uri),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(_response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> putMultipartData(String uri, Map<String, String> body, List<MultipartBody> multipartBody, {Map<String, String>? headers}) async {
    try {
      if (foundation.kDebugMode) {
        debugPrint('====> API PUT Multipart: $uri with ${multipartBody.length} files');
      }
      http.MultipartRequest _request = http.MultipartRequest('POST', Uri.parse(appBaseUrl+uri));
      _request.headers.addAll(headers ?? _mainHeaders as Map<String, String>);
      _request.fields.addAll(body);
      _request.fields['_method'] = 'PUT';
      for(MultipartBody multipart in multipartBody) {
        File _file = File(multipart.file.path);
        _request.files.add(http.MultipartFile(
          multipart.key, _file.readAsBytes().asStream(), _file.lengthSync(), filename: _file.path.split('/').last,
        ));
      }
      http.Response response = await http.Response.fromStream(await _request.send());
      return handleResponse(response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> deleteData(String uri, {Map<String, String>? headers}) async {
    try {
      if (foundation.kDebugMode) {
        debugPrint('====> API DELETE: $uri');
      }
      http.Response _response = await http.delete(
        Uri.parse(appBaseUrl+uri),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(_response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Response handleResponse(http.Response response, String uri) {

    dynamic _body;
    try {
      _body = jsonDecode(response.body);
    }catch(e) {
      // Body is not JSON (e.g. raw HTML or plain text)
      _body = null;
    }
    Response _response = Response(
      body: _body ?? response.body, bodyString: response.body.toString(),
      headers: response.headers, statusCode: response.statusCode, statusText: response.reasonPhrase,
    );
    if(_response.statusCode != 200 && _response.body != null && _response.body is !String) {
      if(_response.body.toString().startsWith('{errors: [{code:')) {
        ErrorResponse _errorResponse = ErrorResponse.fromJson(_response.body);
        _response = Response(statusCode: _response.statusCode, body: _response.body, statusText: _errorResponse.errors![0].message);
      } else if(_response.body.toString().startsWith('{errors: [{error_code:')) {
        ErrorResponse _errorResponse = ErrorResponse.fromJson(_response.body);
        _response = Response(statusCode: _response.statusCode, body: _response.body, statusText: _errorResponse.errors![0].message);
      } else if(_response.body.toString().startsWith('{message')) {
        _response = Response(statusCode: _response.statusCode, body: _response.body, statusText: _response.body['message']);
      }
    }else if(_response.statusCode != 200 && _response.body is String && _response.body.toString().trim().startsWith('<')) {
      _response = Response(statusCode: _response.statusCode, body: null, statusText: 'Something went wrong. Please try again.');
    }else if(_response.statusCode != 200 && _response.body == null) {
      _response = const Response(statusCode: 0, statusText: noInternetMessage);
    }
    if (foundation.kDebugMode) {
      debugPrint('====> API Response: [${_response.statusCode}] $uri');
    }
    return _response;
  }
}

class MultipartBody {
  String key;
  XFile file;

  MultipartBody(this.key, this.file);
}