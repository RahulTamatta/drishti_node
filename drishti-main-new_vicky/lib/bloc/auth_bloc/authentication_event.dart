part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationEvent {
  const AuthenticationEvent();

  List<Object> get props => [];
}

class GetOTP extends AuthenticationEvent {
  const GetOTP(
      {required this.phone, required this.countryCode, required this.type});
  final String phone;
  final String countryCode;
  final String type;

  @override
  List<Object> get props => [phone, countryCode, type];
}

class OTPVerification extends AuthenticationEvent {
  const OTPVerification(
      {required this.otp,
      required this.data,
      required this.deviceToken,
      required this.phone});

  final String otp;
  final String data;
  final String deviceToken;
  final String phone;
  @override
  List<Object> get props => [otp, data, deviceToken];
}

class Reset extends AuthenticationEvent {
  const Reset();

  @override
  List<Object> get props => [];
}
