import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:idee_pet/app/app.dart';

class BaseRepository extends GetConnect {
  BaseRepository({
    this.timeOut = const Duration(seconds: 30),
    this.allowBypass = false,
    this.redirect = true,
  });

  final Duration timeOut;
  bool allowBypass;
  bool redirect;
  final _navigationService = Get.find<NavigationService>();

  @override
  void onInit() {
    super.onInit();

    httpClient
      //..baseUrl = 'https://petserviceapiprodv2-721852722464.us-central1.run.app'
      // ..baseUrl = 'https://api.ideepet.com.br'
      ..baseUrl =
          'https://api-backend-v2-staging-721852722464.us-central1.run.app'
      ..timeout = timeOut
      ..maxAuthRetries = 4
      ..userAgent = ''
      ..addRequestModifier<Object?>((final request) async {
        if (!allowBypass) {
          request.headers
              .addAll(await _setAuthorizationAndRefreshToken(request));
        }
        return request;
      })
      ..addResponseModifier<Object?>((final request, final response) async {
        return Response(
          body: response.body,
          statusCode: response.statusCode,
          // bodyString: response.body as String? ?? '',
        );
      });
  }

  // BaseRepository.dart

  @override
  Future<Response<T>> get<T>(
    String url, // Corrigindo a assinatura aqui também para ser String?
    {
    String? contentType,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    Decoder<T>? decoder,
  }) {
    // Usamos uma arrow function (closure) para envolver a chamada super.get
    return _runRequest<T>(
      () => super.get<T>(
        url,
        contentType: contentType,
        query: query,
        headers: headers,
        decoder: decoder,
      ),
      url,
      'GET',
    );
  }

  // BaseRepository.dart

  @override
  Future<Response<T>> post<T>(
    String? url,
    dynamic body, {
    String? contentType,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    T Function(dynamic data)? decoder,
    dynamic Function(double)? uploadProgress,
  }) {
    return _runRequest<T>(
      () => super.post<T>(
        url,
        body,
        contentType: contentType,
        query: query,
        headers: headers,
        decoder: decoder,
        uploadProgress: uploadProgress,
      ),
      url,
      'POST',
    );
  }

  // BaseRepository.dart

  @override
  Future<Response<T>> put<T>(
    String url, // Lembre-se, o put também precisa ser String?
    dynamic body, {
    String? contentType,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    T Function(dynamic data)? decoder,
    dynamic Function(double)? uploadProgress,
  }) {
    return _runRequest<T>(
      () => super.put<T>(
        url,
        body,
        contentType: contentType,
        query: query,
        headers: headers,
        decoder: decoder,
        uploadProgress: uploadProgress,
      ),
      url,
      'PUT',
    );
  }

  // BaseRepository.dart

  @override
  Future<Response<T>> delete<T>(
    String url, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    String? contentType,
    T Function(dynamic data)? decoder,
  }) {
    return _runRequest<T>(
      () => super.delete<T>(
        url,
        query: query,
        headers: headers,
        contentType: contentType,
        decoder: decoder,
      ),
      url,
      'DELETE',
    );
  }

  Future<Response<T>> _runRequest<T>(
    Future<Response<T>> Function() request,
    String? url,
    String method,
  ) async {
    try {
      // 1. Executa a requisição passada (super.get, super.post, etc.)
      final response = await request();
      debugPrint('@@@ API $method $url -> status: ${response.statusCode}');
      debugPrint('@@@ API $method $url -> body: ${response.body}');
      return response;
    } on SocketException catch (e, s) {
      // 2. CAPTURA: Erro de rede
      BugTracking().send(
        'Network Error (SocketException): Failed host lookup or unreachable network',
        e,
        s,
        'URL: ${url ?? 'N/A'}',
        'SocketException/NoInternet',
      );

      // Retorna uma Response controlada com status 0
      return Response<T>(
        statusCode: 0,
        statusText: 'No Internet Connection or DNS Failure',
        body: {
          'errorMessages': ['Verifique sua conexão com a internet.']
        } as T,
      );
    } catch (e, s) {
      // 3. Captura qualquer outra exceção inesperada
      BugTracking().send(
        'Unexpected Exception during Request',
        e,
        s,
        'URL: ${url ?? 'N/A'}',
        'Unexpected Error',
      );

      return Response<T>(
        statusCode: 0,
        statusText: 'Unexpected Client Error',
        body: {
          'errorMessages': ['Ocorreu um erro inesperado. Tente novamente.']
        } as T,
      );
    }
  }

  Future<Map<String, String>> _setAuthorizationAndRefreshToken(
      final request) async {
    //add logica de refresh token
    final TokenService tokenStorage = Get.find<TokenService>();
    final token = await tokenStorage.getToken();

    if (token == null && redirect) {
      _navigationService.offAllNamed(LoginRoutes.login);
    }

    debugPrint('@@@ $token');

    return {
      'Authorization': 'Bearer $token',
      'Accept': '*/*',
    };
  }
}
