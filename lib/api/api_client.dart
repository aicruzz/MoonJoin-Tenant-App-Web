import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
// ignore: implementation_imports
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:moonjoin_cloud/api/api_checker.dart';
import 'package:moonjoin_cloud/common/models/error_response.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient extends GetxService {
  final String appBaseUrl;
  final SharedPreferences sharedPreferences;
  static String noInternetMessage = 'connection_to_api_server_failed'.tr;
  final int timeoutInSeconds = 40;

  String? token;
  late Map<String, String> _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    token = sharedPreferences.getString(AppConstants.token);
    if (kDebugMode) {
      // ignore: avoid_print
      print('Token: $token');
    }
    updateHeader(
      token,
      sharedPreferences.getString(AppConstants.languageCode),
    );
  }

  Map<String, String> updateHeader(
    String? token,
    String? languageCode, {
    bool setHeader = true,
  }) {
    final Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      AppConstants.localizationKey: languageCode ?? 'en',
    };
    if (token != null && token.isNotEmpty) {
      header[AppConstants.authorization] = 'Bearer $token';
    }
    if (setHeader) {
      _mainHeaders = header;
    }
    return header;
  }

  Future<Response> getData(
    String uri, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool handleError = true,
  }) async {
    try {
      if (kDebugMode) {
        // ignore: avoid_print
        print('====> API Call: $uri\nHeader: ${headers ?? _mainHeaders}');
      }
      final response = await http
          .get(
            Uri.parse(appBaseUrl + uri).replace(
              queryParameters: query?.map(
                (key, value) => MapEntry(key, value.toString()),
              ),
            ),
            headers: headers ?? _mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('------------${e.toString()}');
      }
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postData(
    String uri,
    dynamic body, {
    Map<String, String>? headers,
    int? timeout,
    bool handleError = true,
  }) async {
    try {
      if (kDebugMode) {
        // ignore: avoid_print
        print('====> API Call: $uri\nHeader: ${headers ?? _mainHeaders}');
        // ignore: avoid_print
        print('====> API Body: $body');
      }
      final response = await http
          .post(
            Uri.parse(appBaseUrl + uri),
            body: jsonEncode(body),
            headers: headers ?? _mainHeaders,
          )
          .timeout(Duration(seconds: timeout ?? timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (_) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postMultipartData(
    String uri,
    Map<String, String> body,
    List<MultipartBody> multipartBody, {
    Map<String, String>? headers,
    bool handleError = true,
  }) async {
    try {
      final request = http.MultipartRequest(
          'POST', Uri.parse(appBaseUrl + uri));
      request.headers.addAll(headers ?? _mainHeaders);
      for (final multipart in multipartBody) {
        if (multipart.file != null) {
          final list = await multipart.file!.readAsBytes();
          request.files.add(http.MultipartFile(
            multipart.key,
            multipart.file!.readAsBytes().asStream(),
            list.length,
            filename: '${DateTime.now().toString()}.png',
          ));
        }
      }
      request.fields.addAll(body);
      final response = await http.Response.fromStream(await request.send());
      return handleResponse(response, uri, handleError);
    } catch (_) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> putData(
    String uri,
    dynamic body, {
    Map<String, String>? headers,
    bool handleError = true,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse(appBaseUrl + uri),
            body: jsonEncode(body),
            headers: headers ?? _mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (_) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> deleteData(
    String uri, {
    Map<String, String>? headers,
    bool handleError = true,
  }) async {
    try {
      final response = await http
          .delete(
            Uri.parse(appBaseUrl + uri),
            headers: headers ?? _mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (_) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Response handleResponse(http.Response response, String uri, bool handleError) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {}
    var response0 = Response(
      body: body ?? response.body,
      bodyString: response.body.toString(),
      request: response.request != null
          ? Request(
              headers: response.request!.headers,
              method: response.request!.method,
              url: response.request!.url,
            )
          : null,
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
    );
    if (response0.statusCode != 200 &&
        response0.body != null &&
        response0.body is! String) {
      final bodyText = response0.body.toString();
      if (bodyText.startsWith('{errors: [{code:')) {
        final errorResponse = ErrorResponse.fromJson(response0.body);
        response0 = Response(
          statusCode: response0.statusCode,
          body: response0.body,
          statusText: errorResponse.errors![0].message,
        );
      } else if (bodyText.startsWith('{message')) {
        final dynamic raw = response0.body;
        final String? message =
            raw is Map ? raw['message']?.toString() : null;
        response0 = Response(
          statusCode: response0.statusCode,
          body: response0.body,
          statusText: message,
        );
      }
    } else if (response0.statusCode != 200 && response0.body == null) {
      response0 = Response(statusCode: 0, statusText: noInternetMessage);
    }
    if (kDebugMode) {
      // ignore: avoid_print
      print('====> API Response: [${response0.statusCode}] $uri');
    }
    if (handleError) {
      if (response0.statusCode == 200) {
        return response0;
      } else {
        ApiChecker.checkApi(response0);
        return const Response();
      }
    }
    return response0;
  }
}

class MultipartBody {
  final String key;
  final XFile? file;
  MultipartBody(this.key, this.file);
}
