import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

class SeboApiClient {
  SeboApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      baseUrl = _normalizeBaseUrl(baseUrl ?? defaultBaseUrl);

  static const defaultBaseUrl = String.fromEnvironment(
    'SEBO_API_URL',
    defaultValue: 'https://sebo-digital-site-production.up.railway.app',
  );

  final http.Client _client;
  final String baseUrl;

  Future<List<Book>> fetchBooks({
    String? search,
    String? category,
    bool? freeShipping,
    bool? offer,
    bool? bestSeller,
    bool? newRelease,
  }) async {
    final json = await _request<List<dynamic>>(
      '/api/livros',
      query: {
        if (isFilled(search)) 'busca': search!.trim(),
        if (isFilled(category)) 'categoria': category!.trim(),
        if (freeShipping != null) 'freteGratis': '$freeShipping',
        if (offer != null) 'oferta': '$offer',
        if (bestSeller != null) 'maisVendido': '$bestSeller',
        if (newRelease != null) 'lancamento': '$newRelease',
      },
    );
    return json
        .map((item) => Book.fromJson(asMap(item)))
        .toList(growable: false);
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final json = await _request<Map<String, dynamic>>(
      '/api/auth/login',
      method: 'POST',
      body: {'email': email.trim(), 'senha': password},
    );
    return AuthSession.fromJson(json);
  }

  Future<AuthSession> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final json = await _request<Map<String, dynamic>>(
      '/api/auth/cadastro',
      method: 'POST',
      body: {'nome': name.trim(), 'email': email.trim(), 'senha': password},
    );
    return AuthSession.fromJson(json);
  }

  Future<User> me(String token) async {
    final json = await _request<Map<String, dynamic>>(
      '/api/auth/me',
      token: token,
    );
    return User.fromJson(json);
  }

  Future<List<Order>> fetchOrders(String token) async {
    final json = await _request<List<dynamic>>('/api/pedidos', token: token);
    return json
        .map((item) => Order.fromJson(asMap(item)))
        .toList(growable: false);
  }

  Future<Order> createOrder({
    required String token,
    required CheckoutPayload payload,
  }) async {
    final json = await _request<Map<String, dynamic>>(
      '/api/pedidos',
      method: 'POST',
      token: token,
      body: payload.toJson(),
    );
    return Order.fromJson(json);
  }

  Future<T> _request<T>(
    String path, {
    String method = 'GET',
    Map<String, String> query = const {},
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: query.isEmpty ? null : query);
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (isFilled(token)) 'Authorization': 'Bearer $token',
    };

    late final http.Response response;
    try {
      final request = switch (method) {
        'POST' => _client.post(uri, headers: headers, body: jsonEncode(body)),
        _ => _client.get(uri, headers: headers),
      };
      response = await request.timeout(const Duration(seconds: 25));
    } on TimeoutException {
      throw const ApiException(
        'A API demorou para responder. Tente novamente.',
      );
    } catch (_) {
      throw const ApiException(
        'Nao foi possivel acessar o Sebo Digital agora.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_errorMessage(response));
    }

    if (response.statusCode == 204 || response.body.trim().isEmpty) {
      return null as T;
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    return decoded as T;
  }

  String _errorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map && isFilled(decoded['erro']?.toString())) {
        return decoded['erro'].toString();
      }
      if (decoded is Map && isFilled(decoded['message']?.toString())) {
        return decoded['message'].toString();
      }
    } catch (_) {
      // The API can return empty error bodies for infrastructure failures.
    }

    if (response.statusCode == 401) {
      return 'Sua sessao expirou. Entre novamente para continuar.';
    }
    return 'Nao foi possivel concluir a operacao.';
  }

  void close() => _client.close();

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return defaultBaseUrl;
    return trimmed.replaceAll(RegExp(r'/+$'), '');
  }
}
