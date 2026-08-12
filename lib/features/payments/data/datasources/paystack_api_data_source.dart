import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import   '../../../../core/config/app_config.dart';
import   '../../../../core/errors/exceptions.dart';
import '../../domain/entities/payment_plan_entity.dart';
import '../../domain/entities/transaction_entity.dart';

/// Paystack REST API client.
///
/// Initializes transactions (hosted checkout) and verifies payments by
/// reference. Uses the secret key for verification and the public key for
/// client-side checkout.
class PaystackApiDataSource {
  PaystackApiDataSource({
    http.Client? client,
    String? baseUrl,
    String? secretKey,
    String? publicKey,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.paystackBaseUrl,
        _secretKey =
            secretKey ?? AppConfig.paystackSecretKey,
        _publicKey =
            publicKey ?? AppConfig.paystackPublicKey;

  final http.Client _client;
  final String _baseUrl;
  final String _secretKey;
  final String _publicKey;

  /// Guard against unconfigured Paystack keys.
  void _guardKeys() {
    if (_secretKey.isEmpty ||
        _secretKey == 'YOUR_PAYSTACK_SECRET_KEY' ||
        _publicKey.isEmpty ||
        _publicKey == 'YOUR_PAYSTACK_PUBLIC_KEY') {
      throw const NetworkException(
        'Paystack keys not configured. Set PAYSTACK_PUBLIC_KEY and '
        'PAYSTACK_SECRET_KEY in AppConfig.',
      );
    }
  }

  /// Initializes a transaction and returns the checkout access code + URL.
  Future<TransactionEntity> initializeTransaction({
    required String userId,
    required PaymentPlanEntity plan,
    String? email,
  }) async {
    _guardKeys();
    final reference = 'REF_${DateTime.now().millisecondsSinceEpoch}_$userId';

    final body = <String, dynamic>{
      'email': email ?? 'user@example.com',
      'amount': plan.amountKobo,
      'currency': plan.currency,
      'reference': reference,
      'metadata': {
        'userId': userId,
        'planId': plan.id,
        'planName': plan.name,
      },
      'channels': ['card', 'bank', 'ussd', 'qr', 'mobile_money', 'bank_transfer'],
    };

    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/transaction/initialize'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_secretKey',
        },
        body: jsonEncode(body),
      );

      final json = _decode(response);
      if (json['status'] != true) {
        throw const ServerException('Paystack initialization failed.');
      }

      final data = json['data'] as Map<String, dynamic>? ?? const {};
      return TransactionEntity(
        reference: reference,
        userId: userId,
        planId: plan.id,
        planName: plan.name,
        amountKobo: plan.amountKobo,
        currency: plan.currency,
        status: TransactionStatus.pending,
        createdAt: DateTime.now(),
        accessCode: data['access_code'] as String?,
        authorizationUrl: data['authorization_url'] as String?,
      );
    } on AppException {
      rethrow;
    } on SocketException {
      throw const NetworkException(
        'Cannot connect to Paystack. Check your internet connection.',
      );
    } on TimeoutException {
      throw const NetworkException('Paystack request timed out. Please try again.');
    } catch (e) {
      throw ServerException('Unable to initialize payment: $e');
    }
  }

  /// Verifies a transaction by reference and returns the verified entity.
  Future<TransactionEntity> verifyTransaction({
    required String userId,
    required String reference,
    required String planId,
    required String planName,
    required int amountKobo,
    required String currency,
  }) async {
    _guardKeys();
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/transaction/verify/$reference'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_secretKey',
        },
      );

      final json = _decode(response);
      final data = json['data'] as Map<String, dynamic>? ?? const {};

      final status = data['status'] as String? ?? '';
      final success = status == 'success';

      return TransactionEntity(
        reference: reference,
        userId: userId,
        planId: planId,
        planName: planName,
        amountKobo: amountKobo,
        currency: currency,
        status: success ? TransactionStatus.success : TransactionStatus.failed,
        createdAt: DateTime.now(),
        verifiedAt: DateTime.now(),
        paidAt: data['paid_at'] != null
            ? DateTime.tryParse(data['paid_at'].toString())
            : null,
      );
    } on AppException {
      rethrow;
    } on SocketException {
      throw const NetworkException(
        'Cannot connect to Paystack. Check your internet connection.',
      );
    } on TimeoutException {
      throw const NetworkException('Paystack request timed out. Please try again.');
    } catch (e) {
      throw ServerException('Unable to verify payment: $e');
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) return body;
      return <String, dynamic>{};
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw const AuthenticationException('Invalid Paystack API key.');
    } else if (response.statusCode == 400) {
      throw const ServerException('Paystack rejected the request.');
    } else if (response.statusCode >= 500) {
      throw const ServerException('Paystack server error. Please try again later.');
    }
    throw const NetworkException('Unexpected response from Paystack.');
  }
}
