import 'package:bloc/bloc.dart';

import 'package:meta/meta.dart';
import 'package:srisridrishti/handler/responses/verify_otp_response.dart';

import '../../handler/responses/otp_login_response.dart';
import '../../repos/auth_repo/auth_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthRepository _authRepository;
  AuthenticationBloc(this._authRepository) : super(AuthenticationInitial()) {
    on<GetOTP>(_getOtpEvent);
    on<OTPVerification>(_otpVerification);
  }

  _getOtpEvent(GetOTP event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    try {
      final OTPLoginResponse? response = await _authRepository.getOTP(
          event.phone, event.countryCode, event.type);
      if (response != null && response.success) {
        return emit(GetOTPLoaded(otpResponse: response));
      } else {
        return emit(GetOTPError(otpResponse: response!));
      }
    } catch (error) {
      return emit(
        GetOTPError(
            otpResponse: OTPLoginResponse(
                success: false, errorMessage: error.toString())),
      );
    }
  }

  _otpVerification(
      OTPVerification event, Emitter<AuthenticationState> emit) async {
    try {
      emit(AuthenticationLoading());

      final response = await _authRepository.verifyOTP(
        event.otp,
        event.data, // This is now encrypted data
        event.deviceToken,
      );

      if (response != null && response.success == true) {
        return emit(AuthenticationSuccessfull(verifyOtpResponse: response));
      } else {
        return emit(AuthenticationFailed(
            verifyOtpResponse: response ??
                VerifyOtpResponse(
                    success: false, message: "Verification failed")));
      }
    } catch (error) {
      print('OTP verification error: $error');
      return emit(AuthenticationFailed(
        verifyOtpResponse: VerifyOtpResponse(
          success: false,
          message: error.toString(),
        ),
      ));
    }
  }
}
