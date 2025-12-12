import 'package:bienestar_integral_app/core/error/exception.dart';
// Ya no necesitamos importar datasource o repository impl aquí
import 'package:bienestar_integral_app/features/payments/domain/usecase/create_donation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum PaymentStatus { initial, loading, success, error }

class PaymentProvider extends ChangeNotifier {
  final CreateDonation _createDonation;

  PaymentStatus _status = PaymentStatus.initial;
  String? _errorMessage;

  PaymentProvider(this._createDonation);

  PaymentStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == PaymentStatus.loading;

  Future<bool> makeDonation({
    required int kitchenId,
    required double amount,
    String? description,
  }) async {
    _status = PaymentStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final paymentIntent = await _createDonation(
        kitchenId: kitchenId,
        amount: amount,
        description: description,
      );

      await _launchPaymentUrl(paymentIntent.paymentUrl);

      _status = PaymentStatus.success;
      notifyListeners();
      return true;

    } on ServerException catch (e) {
      _errorMessage = e.message;
      _status = PaymentStatus.error;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _status = PaymentStatus.error;
    } catch (e) {
      _errorMessage = 'Ocurrió un error inesperado al iniciar la donación.';
      _status = PaymentStatus.error;
    } finally {
      if (_status != PaymentStatus.success) {
        notifyListeners();
      }
    }
    return false;
  }

  Future<void> _launchPaymentUrl(String urlString) async {
    if (urlString.isEmpty) {
      throw ServerException("La URL de pago recibida no es válida.");
    }

    final uri = Uri.parse(urlString);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    else {
      try {
        bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched) {
          throw ServerException("No se encontró una aplicación para abrir el pago.");
        }
      } catch (e) {
        throw ServerException("No se pudo abrir el navegador para completar el pago.");
      }
    }
  }
}