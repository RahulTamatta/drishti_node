import 'package:bloc/bloc.dart';
import 'package:srisridrishti/handler/responses/verify_otp_response.dart';
import 'package:meta/meta.dart';
import 'package:srisridrishti/utils/shared_preference_helper.dart';

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

  Future<void> _otpVerification(
      OTPVerification event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    try {
      // Validate OTP
      if (event.otp.isEmpty || event.otp.length != 6) {
        return emit(AuthenticationFailed(
          verifyOtpResponse: VerifyOtpResponse(
            success: false,
            message: "Invalid OTP format",
          ),
        ));
      }

      // Perform OTP verification
      final VerifyOtpResponse? response = await _authRepository.verifyOTP(
        event.otp,
        event.phone,
        event.data,
        event.deviceToken,
      );

// More detailed error handling
      if (response == null) {
        return emit(AuthenticationFailed(
          verifyOtpResponse: VerifyOtpResponse(
            success: false,
            message: "Network error: No server response",
          ),
        ));
      }

      if (!response.success) {
        return emit(AuthenticationFailed(
          verifyOtpResponse: response,
        ));
      }
      // Successful verification with valid access token
      if (response.success &&
          response.data?.accessToken != null &&
          response.data!.accessToken!.isNotEmpty) {
        // Save access token
        await SharedPreferencesHelper.saveAccessToken(
          response.data!.accessToken!,
        );

        // Emit successful state
        emit(AuthenticationSuccessfull(verifyOtpResponse: response));
      } else {
        // Failed verification
        emit(AuthenticationFailed(
          verifyOtpResponse: VerifyOtpResponse(
            success: false,
            message: response.message ?? "Verification failed",
          ),
        ));
      }
    } catch (error) {
      // Catch and emit any unexpected errors
      emit(AuthenticationFailed(
        verifyOtpResponse: VerifyOtpResponse(
          success: false,
          message: "Verification error: ${error.toString()}",
        ),
      ));
    }
  }
}
