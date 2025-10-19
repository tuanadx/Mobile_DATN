class OtpVerifyRequest {
  final String phoneNumber;
  final String otpCode;

  OtpVerifyRequest({
    required this.phoneNumber,
    required this.otpCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'otp_code': otpCode,
    };
  }

  factory OtpVerifyRequest.fromJson(Map<String, dynamic> json) {
    return OtpVerifyRequest(
      phoneNumber: json['phone_number'] ?? '',
      otpCode: json['otp_code'] ?? '',
    );
  }
}
