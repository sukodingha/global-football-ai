import '../repositories/auth_repository.dart';
import 'usecase.dart';

/// Sends a verification code to a phone number.
class SendPhoneVerificationCode
    implements UseCase<Future<void>, PhoneCodeParams> {
  const SendPhoneVerificationCode(this._repository);
  final AuthRepository _repository;

  @override
  Future<void> call(PhoneCodeParams params) {
    return _repository.sendPhoneVerificationCode(
      phoneNumber: params.phoneNumber,
      onCodeSent: params.onCodeSent,
    );
  }
}
