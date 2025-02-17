class OtpData {
  final String? otp;
  final String? verificationData; // Rename for clarity

  OtpData({this.otp, this.verificationData});

  factory OtpData.fromJson(Map<String, dynamic> json) {
    return OtpData(
      otp: json['otp']?.toString(),
      verificationData: json['data']?.toString(), // Convert to String
    );
  }
}

class DataContent {
  final String someKey;

  DataContent({required this.someKey});

  factory DataContent.fromJson(Map<String, dynamic> json) {
    return DataContent(
      someKey: json['someKey'] as String,
    );
  }
}
