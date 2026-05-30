class VerifyOtpResult {
  final String resetToken;

  VerifyOtpResult({required this.resetToken});

  factory VerifyOtpResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return VerifyOtpResult(
      resetToken: data['reset_token']?.toString() ?? '',
    );
  }
}