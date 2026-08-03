import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'usecase.dart';

/// Verifies an OTP code to complete phone sign-in.
class VerifyPhoneOtp implements UseCase<UserEntity, OtpVerificationParams> {
  const VerifyPhoneOtp(this._repository);
  final AuthRepository _repository;

  @override
  Future<UserEntity> call(OtpVerificationParams params) {
    return _repository.verifyPhoneOtp(
      verificationId: params.verificationId,
      otpCode: params.otpCode,
    );
  }
}
