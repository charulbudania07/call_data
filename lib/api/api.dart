import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  late Dio _dio;

  Api() {
    const String uri = "https://callme4.com:8443/CM4API/telecaller/";

    BaseOptions options = BaseOptions(
      baseUrl: uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      responseType: ResponseType.json,
      connectTimeout: Duration(milliseconds: 120000),
      receiveTimeout: Duration(milliseconds: 300000),
    );

    _dio = Dio(options);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token') ?? "";

        if (token.isNotEmpty) {
          options.headers['Authorization'] = '$token';
        }

        print('Request Data: ${options.data}');
        print('Request Headers: ${options.headers}');

        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('Response: ${response.realUri}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('Dio Error: ${e.response?.statusCode}');
        print('Dio Error Response: ${e.response}');

        String errorMessage = "Something went wrong. Please try again.";

        if (e.response != null && e.response?.data != null) {
          if (e.response?.data["errors"] != null) {
            errorMessage = e.response?.data["errors"]; // Combine all errors into one message
          } else if (e.response?.data["message"] != null) {
            errorMessage = e.response?.data["message"];
          }
        }

        return handler.reject(DioException(
          requestOptions: e.requestOptions,
          error: errorMessage, // Pass extracted error message
        ));
      },
    ));
  }

  Future<dynamic> get(String path, [List<dynamic>? headers]) async {
    try {
      headers?.forEach(
              (header) => _dio.options.headers[header['key']] = header['headers']);
      Response response = await _dio.get(path);
      return response;
    } on DioException catch (e) {
      print(e.error); // ✅ Prints only the 'error' field from DioException
      throw e.error!;  // ✅ Throws only the meaningful error, not the entire exception
    }
  }

  Future<Response> post(String endpoint, dynamic data) async {
    try {
      return await _dio.post(endpoint, data: data);
    } on DioException catch (e) {
      print(e.error); // ✅ Prints only the 'error' field from DioException
      throw e.error!;  // ✅ Throws only the meaningful error, not the entire exception
    }
  }



  Future<dynamic> put(String path, Map<String, dynamic> data) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      print(e.error); // ✅ Prints only the 'error' field from DioException
      throw e.error!;  // ✅ Throws only the meaningful error, not the entire exception
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      print(e.error); // ✅ Prints only the 'error' field from DioException
      throw e.error!;  // ✅ Throws only the meaningful error, not the entire exception
    }
  }
}
