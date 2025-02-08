part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationState {}

final class AuthenticationInitial extends AuthenticationState {}

final class AuthenticationLoading extends AuthenticationState {}

class AuthenticationSuccessfull extends AuthenticationState {
  final VerifyOtpResponse verifyOtpResponse;

  // Include access token directly in the state
  String get accessToken => verifyOtpResponse.data?.accessToken ?? '';

  AuthenticationSuccessfull({required this.verifyOtpResponse});
}

final class AuthenticationFailed extends AuthenticationState {
  final VerifyOtpResponse verifyOtpResponse;
  AuthenticationFailed({required this.verifyOtpResponse});
}

class AuthenticationError extends AuthenticationState {
  final String? message;
  AuthenticationError({this.message});
}

class GetOTPLoaded extends AuthenticationState {
  final OTPLoginResponse otpResponse;
  GetOTPLoaded({
    required this.otpResponse,
  });

  List<Object> get props => [otpResponse];
}

class GetOTPError extends AuthenticationState {
  final OTPLoginResponse otpResponse;
  GetOTPError({
    required this.otpResponse,
  });
  List<Object> get props => [otpResponse];
}
